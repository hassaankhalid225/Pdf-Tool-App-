import 'dart:convert';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:pdf_tool/core/services/pdf_content_extractor.dart';

/// Paragraph alignment in the generated DOCX.
enum DocxAlign { left, center, right, justify }

/// A single run inside a paragraph (homogeneous formatting).
class DocxRun {
  final String text;
  final bool bold;
  final bool italic;
  final double? fontSize; // half-points are computed at serialization
  final String? fontName;

  const DocxRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.fontSize,
    this.fontName,
  });
}

/// A paragraph composed of runs.
class DocxParagraph {
  final List<DocxRun> runs;
  final DocxAlign align;
  final String? styleId; // e.g. Heading1, Heading2, Normal
  final bool pageBreakBefore;

  const DocxParagraph({
    required this.runs,
    this.align = DocxAlign.left,
    this.styleId,
    this.pageBreakBefore = false,
  });
}

/// Builds a real .docx (Office Open XML) file from extracted PDF content.
///
/// The output is the same minimal-but-valid OOXML structure that Microsoft
/// Word, Google Docs, LibreOffice and online tools (Smallpdf, iLovePDF,
/// Adobe Acrobat) emit. This produces a Word file that opens cleanly in
/// every major editor instead of the flat single-style output you get from
/// quick "text → docx" wrappers.
class DocxWriter {
  /// Build a .docx from already-grouped paragraphs.
  static List<int> buildFromParagraphs({
    required String title,
    required List<DocxParagraph> paragraphs,
  }) {
    final archive = Archive();

    _add(archive, '[Content_Types].xml', _contentTypes());
    _add(archive, '_rels/.rels', _rootRels());
    _add(archive, 'docProps/core.xml', _coreProps(title));
    _add(archive, 'docProps/app.xml', _appProps());
    _add(archive, 'word/_rels/document.xml.rels', _documentRels());
    _add(archive, 'word/styles.xml', _styles());
    _add(archive, 'word/settings.xml', _settings());
    _add(archive, 'word/fontTable.xml', _fontTable());
    _add(archive, 'word/webSettings.xml', _webSettings());
    _add(archive, 'word/theme/theme1.xml', _theme());
    _add(archive, 'word/document.xml', _document(paragraphs));

    final bytes = ZipEncoder().encode(archive);
    if (bytes.isEmpty) {
      throw StateError('Failed to encode .docx archive');
    }
    return bytes;
  }

  /// Convert extracted PDF content into well-structured DOCX paragraphs.
  ///
  /// The reconstruction works the same way commercial tools do:
  ///  1. Sort lines top-to-bottom on every page.
  ///  2. Estimate the document's body font size as the median.
  ///  3. Group consecutive lines into paragraphs (large vertical gap → new
  ///     paragraph; small gap → same paragraph).
  ///  4. Detect headings (font size noticeably larger than body) and map
  ///     them to `Heading 1` / `Heading 2`.
  ///  5. Detect alignment from the line's horizontal position on the page.
  ///  6. Preserve bold / italic per run.
  static List<DocxParagraph> paragraphsFromPdf(PdfExtractedContent content) {
    final paragraphs = <DocxParagraph>[];

    final allSizes = <double>[];
    for (final page in content.pages) {
      for (final line in page.lines) {
        if (line.fontSize > 0) allSizes.add(line.fontSize);
      }
    }
    final bodySize = _median(allSizes, fallback: 11);

    for (var p = 0; p < content.pages.length; p++) {
      final page = content.pages[p];

      final sorted = [...page.lines]
        ..sort((a, b) {
          final ay = a.bounds.top;
          final by = b.bounds.top;
          if ((ay - by).abs() < 0.5) {
            return a.bounds.left.compareTo(b.bounds.left);
          }
          return ay.compareTo(by);
        });

      // Group lines into visual paragraphs. A new paragraph starts when
      // the vertical gap to the previous line exceeds ~1.6 line-heights,
      // or when the font size / weight changes significantly.
      final groups = <List<PdfTextLine>>[];
      List<PdfTextLine> current = [];
      double? prevBottom;
      double? prevSize;

      for (final line in sorted) {
        final size = line.fontSize > 0 ? line.fontSize : bodySize;
        final top = line.bounds.top;
        final prevBottomVal = prevBottom;
        final shouldBreak = prevBottomVal != null &&
            ((top - prevBottomVal) > size * 0.9 ||
                (prevSize != null && (size - prevSize).abs() > 2.5));

        if (shouldBreak && current.isNotEmpty) {
          groups.add(current);
          current = [];
        }
        current.add(line);
        prevBottom = line.bounds.bottom;
        prevSize = size;
      }
      if (current.isNotEmpty) groups.add(current);

      for (var g = 0; g < groups.length; g++) {
        final group = groups[g];
        final repSize = _median(
          group.map((l) => l.fontSize).where((s) => s > 0).toList(),
          fallback: bodySize,
        );

        String? styleId;
        if (repSize >= bodySize * 1.7) {
          styleId = 'Heading1';
        } else if (repSize >= bodySize * 1.3) {
          styleId = 'Heading2';
        } else if (repSize >= bodySize * 1.12 &&
            group.every((l) => l.isBold)) {
          styleId = 'Heading3';
        }

        final align = _detectAlignment(group, page.pageWidth);
        final isFirstParagraphOfNewPage = g == 0 && p > 0;

        // Merge consecutive runs with the same formatting; insert soft line
        // breaks between original lines so wrapping in Word looks correct.
        final runs = <DocxRun>[];
        for (var i = 0; i < group.length; i++) {
          final line = group[i];
          if (i > 0) {
            runs.add(const DocxRun('\n'));
          }
          runs.add(DocxRun(
            line.text,
            bold: line.isBold,
            italic: line.isItalic,
            fontSize: line.fontSize > 0 ? line.fontSize : null,
            fontName: line.fontName.isNotEmpty ? line.fontName : null,
          ));
        }

        paragraphs.add(DocxParagraph(
          runs: _mergeRuns(runs),
          align: align,
          styleId: styleId,
          pageBreakBefore: isFirstParagraphOfNewPage,
        ));
      }
    }

    if (paragraphs.isEmpty) {
      paragraphs.add(const DocxParagraph(runs: [DocxRun('')]));
    }
    return paragraphs;
  }

  // ───────────────────────── helpers ─────────────────────────

  static List<DocxRun> _mergeRuns(List<DocxRun> runs) {
    if (runs.length <= 1) return runs;
    final merged = <DocxRun>[];
    for (final r in runs) {
      if (merged.isEmpty) {
        merged.add(r);
        continue;
      }
      final last = merged.last;
      if (last.bold == r.bold &&
          last.italic == r.italic &&
          last.fontSize == r.fontSize &&
          last.fontName == r.fontName &&
          !last.text.endsWith('\n') &&
          !r.text.startsWith('\n')) {
        merged[merged.length - 1] = DocxRun(
          '${last.text} ${r.text}',
          bold: last.bold,
          italic: last.italic,
          fontSize: last.fontSize,
          fontName: last.fontName,
        );
      } else {
        merged.add(r);
      }
    }
    return merged;
  }

  static DocxAlign _detectAlignment(List<PdfTextLine> group, double pageWidth) {
    if (pageWidth <= 0) return DocxAlign.left;
    double leftSum = 0;
    double rightSum = 0;
    var count = 0;
    for (final l in group) {
      if (l.bounds == Rect.zero) continue;
      leftSum += l.bounds.left;
      rightSum += l.bounds.right;
      count++;
    }
    if (count == 0) return DocxAlign.left;
    final avgLeft = leftSum / count;
    final avgRight = rightSum / count;
    final leftMargin = avgLeft;
    final rightMargin = pageWidth - avgRight;
    final lineWidth = avgRight - avgLeft;

    if (leftMargin > pageWidth * 0.18 &&
        rightMargin > pageWidth * 0.18 &&
        (leftMargin - rightMargin).abs() < pageWidth * 0.08) {
      return DocxAlign.center;
    }
    if (rightMargin < pageWidth * 0.08 &&
        leftMargin > pageWidth * 0.18) {
      return DocxAlign.right;
    }
    if (group.length >= 2 &&
        lineWidth > pageWidth * 0.7 &&
        leftMargin < pageWidth * 0.1) {
      return DocxAlign.justify;
    }
    return DocxAlign.left;
  }

  static double _median(List<double> values, {required double fallback}) {
    if (values.isEmpty) return fallback;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  static void _add(Archive a, String path, String xml) {
    final bytes = utf8.encode(xml);
    a.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  // ───────────────────────── OOXML parts ─────────────────────────

  static String _contentTypes() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
      '<Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>'
      '<Override PartName="/word/webSettings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"/>'
      '<Override PartName="/word/fontTable.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"/>'
      '<Override PartName="/word/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>'
      '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
      '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
      '</Types>';

  static String _rootRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
      '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
      '</Relationships>';

  static String _documentRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>'
      '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings" Target="webSettings.xml"/>'
      '<Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable" Target="fontTable.xml"/>'
      '<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>'
      '</Relationships>';

  static String _coreProps(String title) {
    final now = DateTime.now().toUtc().toIso8601String();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" '
        'xmlns:dcterms="http://purl.org/dc/terms/" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        '<dc:title>${_escape(title)}</dc:title>'
        '<dc:creator>PDF Tools Pro</dc:creator>'
        '<cp:lastModifiedBy>PDF Tools Pro</cp:lastModifiedBy>'
        '<dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created>'
        '<dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified>'
        '</cp:coreProperties>';
  }

  static String _appProps() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
      'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
      '<Application>PDF Tools Pro</Application>'
      '<DocSecurity>0</DocSecurity>'
      '<ScaleCrop>false</ScaleCrop>'
      '<SharedDoc>false</SharedDoc>'
      '<HyperlinksChanged>false</HyperlinksChanged>'
      '<AppVersion>1.0000</AppVersion>'
      '</Properties>';

  static String _settings() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:zoom w:percent="100"/>'
      '<w:defaultTabStop w:val="720"/>'
      '<w:characterSpacingControl w:val="doNotCompress"/>'
      '<w:compat>'
      '<w:compatSetting w:name="compatibilityMode" '
      'w:uri="http://schemas.microsoft.com/office/word" w:val="15"/>'
      '</w:compat>'
      '</w:settings>';

  static String _webSettings() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:webSettings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:optimizeForBrowser/>'
      '</w:webSettings>';

  static String _fontTable() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:fonts xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:font w:name="Calibri"><w:panose1 w:val="020F0502020204030204"/>'
      '<w:charset w:val="00"/><w:family w:val="swiss"/><w:pitch w:val="variable"/></w:font>'
      '<w:font w:name="Times New Roman"><w:panose1 w:val="02020603050405020304"/>'
      '<w:charset w:val="00"/><w:family w:val="roman"/><w:pitch w:val="variable"/></w:font>'
      '<w:font w:name="Arial"><w:panose1 w:val="020B0604020202020204"/>'
      '<w:charset w:val="00"/><w:family w:val="swiss"/><w:pitch w:val="variable"/></w:font>'
      '<w:font w:name="Cambria"><w:panose1 w:val="02040503050406030204"/>'
      '<w:charset w:val="00"/><w:family w:val="roman"/><w:pitch w:val="variable"/></w:font>'
      '</w:fonts>';

  static String _theme() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office">'
      '<a:themeElements>'
      '<a:clrScheme name="Office">'
      '<a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>'
      '<a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>'
      '<a:dk2><a:srgbClr val="44546A"/></a:dk2>'
      '<a:lt2><a:srgbClr val="E7E6E6"/></a:lt2>'
      '<a:accent1><a:srgbClr val="4472C4"/></a:accent1>'
      '<a:accent2><a:srgbClr val="ED7D31"/></a:accent2>'
      '<a:accent3><a:srgbClr val="A5A5A5"/></a:accent3>'
      '<a:accent4><a:srgbClr val="FFC000"/></a:accent4>'
      '<a:accent5><a:srgbClr val="5B9BD5"/></a:accent5>'
      '<a:accent6><a:srgbClr val="70AD47"/></a:accent6>'
      '<a:hlink><a:srgbClr val="0563C1"/></a:hlink>'
      '<a:folHlink><a:srgbClr val="954F72"/></a:folHlink>'
      '</a:clrScheme>'
      '<a:fontScheme name="Office">'
      '<a:majorFont><a:latin typeface="Calibri Light"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont>'
      '<a:minorFont><a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont>'
      '</a:fontScheme>'
      '<a:fmtScheme name="Office">'
      '<a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:fillStyleLst>'
      '<a:lnStyleLst>'
      '<a:ln w="6350"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>'
      '<a:ln w="12700"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>'
      '<a:ln w="19050"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>'
      '</a:lnStyleLst>'
      '<a:effectStyleLst>'
      '<a:effectStyle><a:effectLst/></a:effectStyle>'
      '<a:effectStyle><a:effectLst/></a:effectStyle>'
      '<a:effectStyle><a:effectLst/></a:effectStyle>'
      '</a:effectStyleLst>'
      '<a:bgFillStyleLst>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '</a:bgFillStyleLst>'
      '</a:fmtScheme>'
      '</a:themeElements>'
      '</a:theme>';

  static String _styles() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:docDefaults>'
      '<w:rPrDefault><w:rPr>'
      '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>'
      '<w:sz w:val="22"/><w:szCs w:val="22"/>'
      '<w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/>'
      '</w:rPr></w:rPrDefault>'
      '<w:pPrDefault><w:pPr>'
      '<w:spacing w:after="160" w:line="276" w:lineRule="auto"/>'
      '</w:pPr></w:pPrDefault>'
      '</w:docDefaults>'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
      '<w:name w:val="Normal"/><w:qFormat/>'
      '</w:style>'
      '<w:style w:type="paragraph" w:styleId="Heading1">'
      '<w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/>'
      '<w:uiPriority w:val="9"/><w:qFormat/>'
      '<w:pPr><w:keepNext/><w:keepLines/>'
      '<w:spacing w:before="240" w:after="120"/>'
      '<w:outlineLvl w:val="0"/></w:pPr>'
      '<w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:hAnsiTheme="majorHAnsi"/>'
      '<w:b/><w:bCs/><w:color w:val="1F3864"/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr>'
      '</w:style>'
      '<w:style w:type="paragraph" w:styleId="Heading2">'
      '<w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/>'
      '<w:uiPriority w:val="9"/><w:qFormat/>'
      '<w:pPr><w:keepNext/><w:keepLines/>'
      '<w:spacing w:before="200" w:after="80"/>'
      '<w:outlineLvl w:val="1"/></w:pPr>'
      '<w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:hAnsiTheme="majorHAnsi"/>'
      '<w:b/><w:bCs/><w:color w:val="2F5496"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>'
      '</w:style>'
      '<w:style w:type="paragraph" w:styleId="Heading3">'
      '<w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/>'
      '<w:uiPriority w:val="9"/><w:qFormat/>'
      '<w:pPr><w:keepNext/><w:keepLines/>'
      '<w:spacing w:before="160" w:after="60"/>'
      '<w:outlineLvl w:val="2"/></w:pPr>'
      '<w:rPr><w:rFonts w:asciiTheme="majorHAnsi" w:hAnsiTheme="majorHAnsi"/>'
      '<w:b/><w:bCs/><w:color w:val="1F3864"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
      '</w:style>'
      '</w:styles>';

  static String _document(List<DocxParagraph> paragraphs) {
    final body = StringBuffer();
    for (final p in paragraphs) {
      body.write(_serializeParagraph(p));
    }
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<w:body>'
        '$body'
        '<w:sectPr>'
        '<w:pgSz w:w="12240" w:h="15840"/>'
        '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
        'w:header="720" w:footer="720" w:gutter="0"/>'
        '<w:cols w:space="720"/>'
        '<w:docGrid w:linePitch="360"/>'
        '</w:sectPr>'
        '</w:body>'
        '</w:document>';
  }

  static String _serializeParagraph(DocxParagraph p) {
    final pPr = StringBuffer('<w:pPr>');
    if (p.pageBreakBefore) {
      pPr.write('<w:pageBreakBefore/>');
    }
    if (p.styleId != null) {
      pPr.write('<w:pStyle w:val="${p.styleId}"/>');
    }
    switch (p.align) {
      case DocxAlign.center:
        pPr.write('<w:jc w:val="center"/>');
        break;
      case DocxAlign.right:
        pPr.write('<w:jc w:val="right"/>');
        break;
      case DocxAlign.justify:
        pPr.write('<w:jc w:val="both"/>');
        break;
      case DocxAlign.left:
        break;
    }
    pPr.write('</w:pPr>');

    final runs = StringBuffer();
    for (final run in p.runs) {
      runs.write(_serializeRun(run, isHeading: p.styleId != null));
    }

    return '<w:p>${pPr.toString()}$runs</w:p>';
  }

  static String _serializeRun(DocxRun run, {bool isHeading = false}) {
    // Soft line break placeholder.
    if (run.text == '\n') {
      return '<w:r><w:br/></w:r>';
    }

    final rPr = StringBuffer('<w:rPr>');
    if (run.bold && !isHeading) rPr.write('<w:b/><w:bCs/>');
    if (run.italic) rPr.write('<w:i/><w:iCs/>');
    if (run.fontSize != null && !isHeading) {
      final halfPt = (run.fontSize! * 2).round().clamp(8, 144);
      rPr.write('<w:sz w:val="$halfPt"/><w:szCs w:val="$halfPt"/>');
    }
    rPr.write('</w:rPr>');

    // Split on real line breaks just in case.
    final parts = run.text.split('\n');
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) buffer.write('<w:br/>');
      final text = parts[i];
      if (text.isEmpty) continue;
      final needsSpacePreserve = text.startsWith(' ') || text.endsWith(' ');
      buffer.write(
        '<w:t${needsSpacePreserve ? ' xml:space="preserve"' : ''}>${_escape(text)}</w:t>',
      );
    }

    return '<w:r>$rPr$buffer</w:r>';
  }
}
