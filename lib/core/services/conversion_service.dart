import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:xml/xml.dart';

import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/services/docx_writer.dart';
import 'package:pdf_tool/core/services/epub_writer.dart';
import 'package:pdf_tool/core/services/pdf_content_extractor.dart';
import 'package:pdf_tool/core/services/pptx_writer.dart';

/// Optional progress callback for long-running conversions.
/// Reports a value in `[0,1]` plus an optional status message.
typedef ConversionProgress = void Function(double progress, [String? message]);

/// Result of a multi-output conversion (e.g. PDF → Image with many pages).
class ConversionResult {
  final File primary;
  final List<File> secondary;
  final String? note;

  const ConversionResult(this.primary, {this.secondary = const [], this.note});
}

/// High-level service that performs every conversion supported by the app.
///
/// Each method:
///   * accepts a single input file,
///   * returns a single output file (the user-facing result),
///   * never throws low-level Dart errors — they're wrapped with a friendly
///     message,
///   * cleans up native handles in a `finally` block.
///
/// Heavy work (image rasterisation, OOXML generation) is dispatched off the
/// UI thread via `compute()` where it's safe to do so.
class ConversionService {
  /// 200 MB — large enough for big PDFs / images, small enough to stay safe
  /// on entry-level Android devices.
  static const int maxFileSize = 200 * 1024 * 1024;

  /// Validate a file before conversion. Returns `null` on success or a human
  /// readable error message otherwise.
  Future<String?> validateFileDetailed(
    File file,
    List<String> allowedExtensions,
  ) async {
    try {
      if (!await file.exists()) return 'File could not be found.';

      final size = await file.length();
      if (size == 0) return 'The file is empty.';
      if (size > maxFileSize) {
        return 'File is too large (max ${(maxFileSize / (1024 * 1024)).round()} MB).';
      }

      final ext = _ext(file);
      if (allowedExtensions.isNotEmpty &&
          !allowedExtensions.contains(ext)) {
        return 'Unsupported file type ".${ext.isEmpty ? '?' : ext}".';
      }
      return null;
    } catch (e) {
      return 'Could not read this file (${e.toString()}).';
    }
  }

  /// Back-compat boolean wrapper used elsewhere in the codebase.
  Future<bool> validateFile(File file, List<String> allowedExtensions) async =>
      await validateFileDetailed(file, allowedExtensions) == null;

  // ─────────────────────────────────────────────────────────────────
  // PDF → Word
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToWord(File pdfFile, {ConversionProgress? onProgress}) async {
    try {
      onProgress?.call(0.10, 'Reading PDF…');
      final content = await PdfContentExtractor.extract(pdfFile);
      onProgress?.call(0.55, 'Rebuilding document…');

      final title = p.basenameWithoutExtension(content.fileName);
      final paragraphs = <DocxParagraph>[];

      if (!content.hasSelectableText) {
        paragraphs.add(DocxParagraph(
          styleId: 'Heading1',
          align: DocxAlign.center,
          runs: [DocxRun(title)],
        ));
        paragraphs.add(const DocxParagraph(
          align: DocxAlign.center,
          runs: [
            DocxRun(
              'This PDF appears to be a scanned document and contains no '
              'selectable text. Run OCR on the PDF first, then convert it '
              'again to get an editable Word document.',
              italic: true,
            ),
          ],
        ));
      } else {
        paragraphs.addAll(DocxWriter.paragraphsFromPdf(content));
      }

      onProgress?.call(0.85, 'Writing .docx…');
      final bytes = DocxWriter.buildFromParagraphs(
        title: title,
        paragraphs: paragraphs,
      );
      final outputFile = await _createOutputFile(pdfFile, 'docx');
      await outputFile.writeAsBytes(bytes);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to Word conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PDF → PowerPoint
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToPowerPoint(
    File pdfFile, {
    ConversionProgress? onProgress,
  }) async {
    try {
      onProgress?.call(0.10, 'Reading PDF…');
      final content = await PdfContentExtractor.extract(pdfFile);
      final title = p.basenameWithoutExtension(content.fileName);

      onProgress?.call(0.5, 'Building slides…');
      final slides = <PptxSlide>[];

      if (!content.hasSelectableText) {
        slides.add(PptxSlide(
          title: title,
          bullets: const [
            'This PDF has no selectable text.',
            'Run OCR on the PDF first, then convert it again.',
          ],
        ));
      } else {
        // Use median font size to pick a title per page (the biggest line),
        // everything else becomes bullets.
        final allSizes = <double>[];
        for (final page in content.pages) {
          for (final l in page.lines) {
            if (l.fontSize > 0) allSizes.add(l.fontSize);
          }
        }
        final bodySize = _median(allSizes, fallback: 11);

        for (final page in content.pages) {
          if (page.lines.isEmpty) {
            slides.add(PptxSlide(
              title: 'Page ${page.pageNumber}',
              bullets: const ['[No text on this page]'],
            ));
            continue;
          }

          final sorted = [...page.lines]
            ..sort((a, b) => a.bounds.top.compareTo(b.bounds.top));

          // Heuristic: largest line at the top of the page = title.
          String slideTitle;
          List<PdfTextLine> bodyLines;
          final first = sorted.first;
          if (first.fontSize >= bodySize * 1.25 ||
              (first.isBold && first.fontSize >= bodySize * 1.05)) {
            slideTitle = first.text;
            bodyLines = sorted.skip(1).toList();
          } else {
            slideTitle = 'Page ${page.pageNumber}';
            bodyLines = sorted;
          }

          final bullets = bodyLines
              .map((l) => l.text.replaceAll(RegExp(r'\s+'), ' ').trim())
              .where((t) => t.isNotEmpty)
              .toList();

          slides.add(PptxSlide(title: slideTitle, bullets: bullets));
        }
      }

      onProgress?.call(0.85, 'Writing .pptx…');
      final bytes = PptxWriter.build(title: title, slides: slides);
      final outputFile = await _createOutputFile(pdfFile, 'pptx');
      await outputFile.writeAsBytes(bytes);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to PowerPoint conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PDF → Excel
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToExcel(File pdfFile, {ConversionProgress? onProgress}) async {
    xlsio.Workbook? workbook;
    try {
      onProgress?.call(0.10, 'Reading PDF…');
      final content = await PdfContentExtractor.extract(pdfFile);

      workbook = xlsio.Workbook();
      final firstSheet = workbook.worksheets[0];

      if (!content.hasSelectableText || content.pages.isEmpty) {
        firstSheet.name = 'Notice';
        firstSheet.getRangeByIndex(1, 1).setText(
              'No selectable text was found in this PDF. '
              'If it is a scanned document, run OCR first and try again.',
            );
        firstSheet.autoFitColumn(1);
      } else {
        for (var p = 0; p < content.pages.length; p++) {
          onProgress?.call(
            0.15 + 0.75 * (p / content.pages.length),
            'Extracting page ${p + 1} of ${content.pages.length}…',
          );
          final page = content.pages[p];
          final sheetName = _safeSheetName('Page ${page.pageNumber}', p + 1);
          final sheet = p == 0
              ? (firstSheet..name = sheetName)
              : workbook.worksheets.addWithName(sheetName);
          _writePageToSheet(sheet, page);
        }
      }

      onProgress?.call(0.95, 'Writing .xlsx…');
      final outputFile = await _createOutputFile(pdfFile, 'xlsx');
      final excelBytes = workbook.saveAsStream();
      await outputFile.writeAsBytes(excelBytes);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to Excel conversion failed: ${e.toString()}');
    } finally {
      workbook?.dispose();
    }
  }

  /// Reconstructs the table on a single PDF page into an Excel sheet.
  ///
  /// Algorithm (similar to what Tabula / Camelot use offline):
  ///   1. Group lines by their vertical position → rows.
  ///   2. For each row, split into cells either by word bounds (when
  ///      Syncfusion gives us per-word geometry) or by runs of 2+ spaces in
  ///      the raw text (fallback for older PDFs).
  ///   3. Build column boundaries by clustering the X positions across rows.
  ///   4. Assign every cell to the nearest column and write to the sheet.
  void _writePageToSheet(xlsio.Worksheet sheet, PdfPageContent page) {
    final rows = _groupLinesIntoRows(page.lines);
    if (rows.isEmpty) {
      sheet.getRangeByIndex(1, 1).setText('[No text on this page]');
      return;
    }

    // Per-row cells with their X centers (for column assignment).
    final rowCells = <List<_Cell>>[];
    for (final lineGroup in rows) {
      final cells = <_Cell>[];
      for (final line in lineGroup) {
        if (line.words.isNotEmpty) {
          // Cluster words within a line into cells when the gap > 1.5em.
          final emWidth = line.fontSize * 0.5;
          final wordsSorted = [...line.words]
            ..sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
          var currentText = StringBuffer(wordsSorted.first.text);
          var currentLeft = wordsSorted.first.bounds.left;
          var currentRight = wordsSorted.first.bounds.right;
          for (var i = 1; i < wordsSorted.length; i++) {
            final w = wordsSorted[i];
            final gap = w.bounds.left - currentRight;
            if (gap > emWidth * 3) {
              cells.add(_Cell(
                text: currentText.toString(),
                left: currentLeft,
                right: currentRight,
              ));
              currentText = StringBuffer(w.text);
              currentLeft = w.bounds.left;
              currentRight = w.bounds.right;
            } else {
              currentText.write(' ${w.text}');
              currentRight = w.bounds.right;
            }
          }
          cells.add(_Cell(
            text: currentText.toString(),
            left: currentLeft,
            right: currentRight,
          ));
        } else {
          // Fallback: split on 2+ whitespace.
          final parts = line.text.split(RegExp(r'\s{2,}'));
          for (var i = 0; i < parts.length; i++) {
            final pieceWidth =
                line.bounds.width / math.max(parts.length, 1);
            cells.add(_Cell(
              text: parts[i].trim(),
              left: line.bounds.left + i * pieceWidth,
              right: line.bounds.left + (i + 1) * pieceWidth,
            ));
          }
        }
      }
      rowCells.add(cells);
    }

    // Cluster all cell centers into columns.
    final centers = <double>[];
    for (final r in rowCells) {
      for (final c in r) {
        centers.add((c.left + c.right) / 2);
      }
    }
    centers.sort();
    final columnBounds = _clusterColumns(centers, page.pageWidth);

    if (columnBounds.isEmpty) {
      // Single-column page — just dump each line as one cell.
      for (var i = 0; i < rowCells.length; i++) {
        sheet.getRangeByIndex(i + 1, 1).setText(
              rowCells[i].map((c) => c.text).join(' '),
            );
      }
      sheet.autoFitColumn(1);
      return;
    }

    // Heading style for first row, if the largest font size is markedly bigger
    // than the rest.
    bool firstRowIsHeader = false;
    if (rowCells.length > 1) {
      final firstHeight = rows.first.first.fontSize;
      final restHeights = rows
          .skip(1)
          .expand((g) => g)
          .map((l) => l.fontSize)
          .where((s) => s > 0)
          .toList();
      final restMed = _median(restHeights, fallback: firstHeight);
      firstRowIsHeader =
          firstHeight >= restMed * 1.15 || rows.first.first.isBold;
    }

    for (var r = 0; r < rowCells.length; r++) {
      for (final c in rowCells[r]) {
        final colIndex = _columnIndexFor(c, columnBounds) + 1;
        final existing = sheet.getRangeByIndex(r + 1, colIndex).getText();
        final value = (existing == null || existing.isEmpty)
            ? c.text
            : '$existing ${c.text}';
        sheet.getRangeByIndex(r + 1, colIndex).setText(value);
      }
      if (r == 0 && firstRowIsHeader) {
        final headerRange = sheet.getRangeByIndex(
          1,
          1,
          1,
          columnBounds.length,
        );
        headerRange.cellStyle.bold = true;
        headerRange.cellStyle.backColor = '#E0E7FF';
      }
    }

    for (var c = 1; c <= columnBounds.length; c++) {
      sheet.autoFitColumn(c);
    }
  }

  /// Group consecutive PdfTextLines into rows by vertical proximity.
  List<List<PdfTextLine>> _groupLinesIntoRows(List<PdfTextLine> lines) {
    if (lines.isEmpty) return const [];
    final sorted = [...lines]
      ..sort((a, b) => a.bounds.top.compareTo(b.bounds.top));

    final rows = <List<PdfTextLine>>[];
    var current = <PdfTextLine>[sorted.first];
    var rowBottom = sorted.first.bounds.bottom;
    var rowHeight = sorted.first.bounds.height > 0
        ? sorted.first.bounds.height
        : sorted.first.fontSize;
    for (var i = 1; i < sorted.length; i++) {
      final line = sorted[i];
      if (line.bounds.top - rowBottom < rowHeight * 0.5) {
        current.add(line);
        rowBottom = math.max(rowBottom, line.bounds.bottom);
        rowHeight = math.max(rowHeight, line.bounds.height);
      } else {
        rows.add(current);
        current = [line];
        rowBottom = line.bounds.bottom;
        rowHeight = line.bounds.height > 0 ? line.bounds.height : line.fontSize;
      }
    }
    rows.add(current);
    return rows;
  }

  /// Cluster a sorted list of X centers into column ranges.
  List<_ColumnRange> _clusterColumns(List<double> centers, double pageWidth) {
    if (centers.isEmpty) return const [];
    final threshold = pageWidth > 0 ? pageWidth * 0.04 : 18.0;
    final clusters = <List<double>>[];
    var bucket = <double>[centers.first];
    for (var i = 1; i < centers.length; i++) {
      if (centers[i] - bucket.last <= threshold) {
        bucket.add(centers[i]);
      } else {
        clusters.add(bucket);
        bucket = <double>[centers[i]];
      }
    }
    clusters.add(bucket);
    return clusters
        .map((c) => _ColumnRange(min: c.first, max: c.last, mid: c[c.length ~/ 2]))
        .toList();
  }

  int _columnIndexFor(_Cell cell, List<_ColumnRange> cols) {
    final mid = (cell.left + cell.right) / 2;
    var bestIndex = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < cols.length; i++) {
      final d = (cols[i].mid - mid).abs();
      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  String _safeSheetName(String name, int fallbackIndex) {
    var cleaned = name.replaceAll(RegExp(r'[\[\]:*?/\\]'), '').trim();
    if (cleaned.length > 31) cleaned = cleaned.substring(0, 31);
    if (cleaned.isEmpty) cleaned = 'Sheet$fallbackIndex';
    return cleaned;
  }

  double _median(List<double> values, {required double fallback}) {
    if (values.isEmpty) return fallback;
    final s = [...values]..sort();
    final m = s.length ~/ 2;
    if (s.length.isOdd) return s[m];
    return (s[m - 1] + s[m]) / 2;
  }

  // ─────────────────────────────────────────────────────────────────
  // PDF → Image (single or multi-page)
  // ─────────────────────────────────────────────────────────────────

  /// Returns a ZIP of PNG/JPG pages when the PDF has more than one page,
  /// otherwise returns the single rendered image file.
  ///
  /// `quality` controls the render DPI ("low" / "medium" / "high").
  Future<File> pdfToImage(
    File pdfFile,
    ImageFormat format, {
    String quality = 'high',
    ConversionProgress? onProgress,
  }) async {
    syncfusion.PdfDocument? document;
    try {
      onProgress?.call(0.05, 'Opening PDF…');
      final bytes = await pdfFile.readAsBytes();
      document = syncfusion.PdfDocument(inputBytes: bytes);
      final pageCount = document.pages.count;
      if (pageCount == 0) {
        throw Exception('No pages found in this PDF.');
      }

      final ext = (format == ImageFormat.jpg || format == ImageFormat.jpeg)
          ? 'jpg'
          : format.extension;
      final isJpeg = ext == 'jpg';

      var requestedDpi = _dpiForQuality(quality);

      // Pre-rasterise everything via the `printing` plugin in one stream
      // (fast — single FFI handshake), with adaptive DPI fallback for memory.
      final renderedPages = <Uint8List>[];
      for (var i = 0; i < pageCount; i++) {
        onProgress?.call(
          0.10 + 0.75 * (i / pageCount),
          'Rendering page ${i + 1}/$pageCount…',
        );
        final safeDpi = _safeDpiForPage(document.pages[i], requestedDpi);
        final png = await _rasterPdfPage(bytes, i, safeDpi);
        final encoded = isJpeg ? _encodeJpeg(png, quality: 85) : png;
        renderedPages.add(encoded);
      }

      onProgress?.call(0.92, 'Saving…');
      if (renderedPages.length == 1) {
        final outputFile = await _createOutputFile(pdfFile, ext);
        await outputFile.writeAsBytes(renderedPages.first);
        onProgress?.call(1.0, 'Done');
        return outputFile;
      }

      // Multi-page → zip every page so the user gets a single download.
      final base = p.basenameWithoutExtension(pdfFile.path);
      final archive = Archive();
      for (var i = 0; i < renderedPages.length; i++) {
        final name = '${base}_page_${(i + 1).toString().padLeft(3, '0')}.$ext';
        archive.addFile(
          ArchiveFile(name, renderedPages[i].length, renderedPages[i]),
        );
      }
      final zip = ZipEncoder().encode(archive);
      final outputFile = await _createOutputFile(pdfFile, 'zip');
      await outputFile.writeAsBytes(zip);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      final message = e.toString();
      if (message.contains('allocate') || message.contains('OOM')) {
        throw Exception(
          'PDF is too large to render at this quality. '
          'Try again with Low quality from Settings, or use a smaller PDF.',
        );
      }
      throw Exception('PDF to Image conversion failed: $message');
    } finally {
      document?.dispose();
    }
  }

  double _dpiForQuality(String quality) {
    switch (quality) {
      case 'low':
        return 72;
      case 'medium':
        return 110;
      default:
        return 150;
    }
  }

  double _safeDpiForPage(syncfusion.PdfPage page, double requestedDpi) {
    const maxEdgePixels = 2400;
    final widthPt = page.size.width;
    final heightPt = page.size.height;
    if (widthPt <= 0 || heightPt <= 0) {
      return requestedDpi.clamp(72.0, 200.0);
    }
    final dpiW = (maxEdgePixels * 72) / widthPt;
    final dpiH = (maxEdgePixels * 72) / heightPt;
    final cap = math.min(dpiW, dpiH);
    return math.min(requestedDpi, cap).clamp(72.0, 220.0);
  }

  Future<Uint8List> _rasterPdfPage(
    List<int> pdfBytes,
    int pageIndex,
    double dpi,
  ) async {
    var attemptDpi = dpi;
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        await for (final page in Printing.raster(
          Uint8List.fromList(pdfBytes),
          pages: [pageIndex],
          dpi: attemptDpi,
        )) {
          return await page.toPng();
        }
        throw Exception('No raster returned for page ${pageIndex + 1}');
      } catch (e) {
        lastError = e;
        final msg = e.toString().toLowerCase();
        final isMemory = msg.contains('allocate') ||
            msg.contains('oom') ||
            msg.contains('out of memory') ||
            msg.contains('memory');
        if (!isMemory || attempt == 3) rethrow;
        attemptDpi = (attemptDpi * 0.65).clamp(72.0, 200.0);
      }
    }
    throw Exception(lastError?.toString() ?? 'Rasterisation failed');
  }

  Uint8List _encodeJpeg(Uint8List pngBytes, {int quality = 85}) {
    final decoded = img.decodePng(pngBytes);
    if (decoded == null) return pngBytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
  }

  // ─────────────────────────────────────────────────────────────────
  // PDF → Text
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToText(File pdfFile, {ConversionProgress? onProgress}) async {
    try {
      onProgress?.call(0.20, 'Extracting text…');
      final content = await PdfContentExtractor.extract(pdfFile);
      onProgress?.call(0.85, 'Saving file…');
      final outputFile = await _createOutputFile(pdfFile, 'txt');
      await outputFile.writeAsString(
        content.hasSelectableText
            ? content.fullText
            : 'No selectable text found. This PDF may be image-based (scanned).',
        flush: true,
      );
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to Text conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PDF → HTML (layout-aware)
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToHtml(File pdfFile, {ConversionProgress? onProgress}) async {
    try {
      onProgress?.call(0.20, 'Extracting text…');
      final content = await PdfContentExtractor.extract(pdfFile);
      onProgress?.call(0.65, 'Building HTML…');

      final paragraphs = DocxWriter.paragraphsFromPdf(content);
      final title = p.basenameWithoutExtension(content.fileName);

      final body = StringBuffer();
      for (final para in paragraphs) {
        final tag = switch (para.styleId) {
          'Heading1' => 'h1',
          'Heading2' => 'h2',
          'Heading3' => 'h3',
          _ => 'p',
        };
        final align = switch (para.align) {
          DocxAlign.center => ' style="text-align:center"',
          DocxAlign.right => ' style="text-align:right"',
          DocxAlign.justify => ' style="text-align:justify"',
          DocxAlign.left => '',
        };
        final inner = StringBuffer();
        for (final run in para.runs) {
          if (run.text == '\n') {
            inner.write('<br/>');
            continue;
          }
          var t = _escapeHtml(run.text);
          if (run.bold) t = '<strong>$t</strong>';
          if (run.italic) t = '<em>$t</em>';
          inner.write(t);
        }
        body.writeln('<$tag$align>$inner</$tag>');
      }

      if (!content.hasSelectableText) {
        body.writeln(
          '<p class="notice"><em>No selectable text in PDF. Scanned documents '
          'need OCR first.</em></p>',
        );
      }

      final outputFile = await _createOutputFile(pdfFile, 'html');
      await outputFile.writeAsString('''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>${_escapeHtml(title)}</title>
<style>
  :root { color-scheme: light dark; }
  body {
    font-family: -apple-system, "Segoe UI", Roboto, sans-serif;
    max-width: 820px; margin: 0 auto; padding: 32px 24px;
    line-height: 1.65; color: #1f2937; background: #ffffff;
  }
  h1 { font-size: 1.75rem; color: #1F3864; margin-bottom: 0.4rem; }
  h2 { font-size: 1.35rem; color: #2F5496; margin: 1.4rem 0 0.4rem; }
  h3 { font-size: 1.15rem; color: #1F3864; margin: 1.2rem 0 0.3rem; }
  p  { margin: 0.6rem 0; }
  .notice { color: #b45309; }
  @media (prefers-color-scheme: dark) {
    body { background: #0f172a; color: #e2e8f0; }
    h1 { color: #93c5fd; } h2, h3 { color: #c7d2fe; }
  }
</style>
</head>
<body>
<h1>${_escapeHtml(title)}</h1>
$body
</body>
</html>''', flush: true);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to HTML conversion failed: ${e.toString()}');
    }
  }

  String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  // ─────────────────────────────────────────────────────────────────
  // PDF → EPUB
  // ─────────────────────────────────────────────────────────────────

  Future<File> pdfToEpub(File pdfFile, {ConversionProgress? onProgress}) async {
    try {
      onProgress?.call(0.15, 'Reading PDF…');
      final content = await PdfContentExtractor.extract(pdfFile);
      final title = p.basenameWithoutExtension(content.fileName);

      onProgress?.call(0.55, 'Building chapters…');
      final chapters = <EpubChapter>[];

      if (!content.hasSelectableText) {
        chapters.add(EpubChapter(
          title: title,
          blocks: const [
            EpubBlock(
              'This PDF appears to be a scanned document and contains no '
              'selectable text. Run OCR on the PDF first, then convert it '
              'again to get an EPUB.',
              EpubBlockType.paragraph,
            ),
          ],
        ));
      } else {
        // One EPUB chapter per "section" — a section starts at a heading.
        final paragraphs = DocxWriter.paragraphsFromPdf(content);
        var currentBlocks = <EpubBlock>[];
        var currentTitle = title;

        EpubBlockType blockFor(String? style) => switch (style) {
              'Heading1' => EpubBlockType.heading1,
              'Heading2' => EpubBlockType.heading2,
              'Heading3' => EpubBlockType.heading3,
              _ => EpubBlockType.paragraph,
            };

        void flush() {
          if (currentBlocks.isNotEmpty) {
            chapters.add(EpubChapter(title: currentTitle, blocks: currentBlocks));
            currentBlocks = [];
          }
        }

        for (final para in paragraphs) {
          final text = para.runs
              .map((r) => r.text == '\n' ? ' ' : r.text)
              .join(' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (text.isEmpty) continue;

          final type = blockFor(para.styleId);
          if (type == EpubBlockType.heading1 && currentBlocks.isNotEmpty) {
            flush();
            currentTitle = text;
            continue;
          }
          if (type == EpubBlockType.heading1) {
            currentTitle = text;
            continue;
          }
          currentBlocks.add(EpubBlock(text, type));
        }
        flush();
        if (chapters.isEmpty) {
          chapters.add(EpubChapter(
            title: title,
            blocks: const [EpubBlock('[Empty document]')],
          ));
        }
      }

      onProgress?.call(0.9, 'Writing .epub…');
      final bytes = EpubWriter.build(title: title, chapters: chapters);
      final outputFile = await _createOutputFile(pdfFile, 'epub');
      await outputFile.writeAsBytes(bytes);
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PDF to EPUB conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Image → PDF
  // ─────────────────────────────────────────────────────────────────

  /// Convert one image to a single-page PDF, picking page size and
  /// orientation automatically from the image's aspect ratio.
  Future<File> imageToPdf(
    File imageFile, {
    String quality = 'high',
    ConversionProgress? onProgress,
  }) async {
    return imagesToPdf([imageFile], quality: quality, onProgress: onProgress);
  }

  /// Combine many images into one multi-page PDF. The page format and
  /// orientation are chosen per image. JPEGs are re-encoded at the requested
  /// quality to keep the file small.
  Future<File> imagesToPdf(
    List<File> imageFiles, {
    String quality = 'high',
    ConversionProgress? onProgress,
  }) async {
    if (imageFiles.isEmpty) {
      throw Exception('No image files supplied.');
    }
    try {
      final pdf = pw.Document();
      final jpegQuality = switch (quality) {
        'low' => 60,
        'medium' => 78,
        _ => 92,
      };

      for (var i = 0; i < imageFiles.length; i++) {
        onProgress?.call(
          0.05 + 0.85 * (i / imageFiles.length),
          'Adding image ${i + 1}/${imageFiles.length}…',
        );

        final bytes = await imageFiles[i].readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded == null) {
          throw Exception('Cannot decode "${p.basename(imageFiles[i].path)}".');
        }
        // Respect EXIF orientation if present (many phone photos rely on this).
        final oriented = img.bakeOrientation(decoded);

        // Down-scale absurdly large images to keep the PDF reasonable.
        const maxDim = 2400;
        final scaled = (oriented.width > maxDim || oriented.height > maxDim)
            ? img.copyResize(
                oriented,
                width: oriented.width >= oriented.height ? maxDim : null,
                height: oriented.height > oriented.width ? maxDim : null,
              )
            : oriented;

        final jpgBytes = Uint8List.fromList(
          img.encodeJpg(scaled, quality: jpegQuality),
        );
        final pdfImage = pw.MemoryImage(jpgBytes);

        final orientation = scaled.width >= scaled.height
            ? pw.PageOrientation.landscape
            : pw.PageOrientation.portrait;

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            orientation: orientation,
            margin: const pw.EdgeInsets.all(24),
            build: (context) => pw.Center(
              child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }

      onProgress?.call(0.95, 'Saving PDF…');
      final outputFile = await _createOutputFile(imageFiles.first, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('Image to PDF conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Word (.docx) → PDF
  // ─────────────────────────────────────────────────────────────────

  Future<File> wordToPdf(File wordFile, {ConversionProgress? onProgress}) async {
    try {
      final ext = _ext(wordFile);
      if (ext == 'doc') {
        throw Exception('Legacy .doc is not supported. Please save as .docx in Word first.');
      }

      onProgress?.call(0.15, 'Reading document…');
      final bytes = await wordFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final docFile = archive.findFile('word/document.xml');

      final paragraphs = <_DocxParaPreview>[];
      if (docFile != null) {
        final content = utf8.decode(docFile.content);
        final xmlDoc = XmlDocument.parse(content);
        for (final para in xmlDoc.findAllElements('w:p')) {
          final pPr = para.findElements('w:pPr').firstOrNull;
          String? styleId;
          pw.TextAlign? align;
          if (pPr != null) {
            styleId = pPr.findElements('w:pStyle').firstOrNull?.getAttribute('w:val');
            switch (pPr.findElements('w:jc').firstOrNull?.getAttribute('w:val')) {
              case 'center':
                align = pw.TextAlign.center;
                break;
              case 'right':
                align = pw.TextAlign.right;
                break;
              case 'both':
                align = pw.TextAlign.justify;
                break;
            }
          }

          final spans = <_DocxRunPreview>[];
          for (final run in para.findElements('w:r')) {
            final rPr = run.findElements('w:rPr').firstOrNull;
            final bold = rPr?.findElements('w:b').isNotEmpty ?? false;
            final italic = rPr?.findElements('w:i').isNotEmpty ?? false;
            final szAttr =
                rPr?.findElements('w:sz').firstOrNull?.getAttribute('w:val');
            final size = szAttr != null
                ? (int.tryParse(szAttr) ?? 22) / 2
                : null;
            final text =
                run.findElements('w:t').map((t) => t.innerText).join();
            if (text.isEmpty &&
                run.findElements('w:br').isEmpty &&
                run.findElements('w:tab').isEmpty) {
              continue;
            }
            spans.add(_DocxRunPreview(
              text: text,
              bold: bold,
              italic: italic,
              fontSize: size,
            ));
          }
          paragraphs.add(_DocxParaPreview(
            styleId: styleId,
            align: align,
            spans: spans,
          ));
        }
      }

      onProgress?.call(0.6, 'Rendering PDF…');
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(56, 64, 56, 64),
          build: (context) {
            if (paragraphs.isEmpty) {
              return [
                pw.Text(
                  'Could not read text from this document.',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ];
            }
            return paragraphs
                .where((p) => p.spans.any((s) => s.text.trim().isNotEmpty))
                .map(_renderDocxParagraph)
                .toList();
          },
        ),
      );

      final outputFile = await _createOutputFile(wordFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('Word to PDF conversion failed: ${e.toString()}');
    }
  }

  pw.Widget _renderDocxParagraph(_DocxParaPreview para) {
    double headingSize;
    switch (para.styleId) {
      case 'Heading1':
      case 'Title':
        headingSize = 22;
        break;
      case 'Heading2':
        headingSize = 18;
        break;
      case 'Heading3':
        headingSize = 14;
        break;
      default:
        headingSize = 0;
    }

    final children = <pw.InlineSpan>[];
    for (final s in para.spans) {
      final size = headingSize > 0 ? headingSize : (s.fontSize ?? 11);
      children.add(pw.TextSpan(
        text: s.text,
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: (s.bold || headingSize > 0)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          fontStyle: s.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
          color: headingSize > 0 ? PdfColor.fromInt(0xFF1F3864) : null,
        ),
      ));
    }

    final isHeading = headingSize > 0;
    return pw.Padding(
      padding: pw.EdgeInsets.only(
        top: isHeading ? 10 : 0,
        bottom: isHeading ? 6 : 8,
      ),
      child: pw.RichText(
        text: pw.TextSpan(children: children),
        textAlign: para.align ?? pw.TextAlign.left,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Excel (.xlsx) → PDF
  // ─────────────────────────────────────────────────────────────────

  Future<File> excelToPdf(File excelFile, {ConversionProgress? onProgress}) async {
    try {
      final ext = _ext(excelFile);
      if (ext == 'xls') {
        throw Exception('Legacy .xls files are not supported. Please save as .xlsx in Excel first.');
      }

      onProgress?.call(0.10, 'Reading workbook…');
      final bytes = await excelFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Shared strings.
      final sharedStrings = <String>[];
      final sharedFile = archive.findFile('xl/sharedStrings.xml');
      if (sharedFile != null) {
        final xml = XmlDocument.parse(utf8.decode(sharedFile.content));
        for (final si in xml.findAllElements('si')) {
          final buffer = StringBuffer();
          for (final t in si.findAllElements('t')) {
            buffer.write(t.innerText);
          }
          sharedStrings.add(buffer.toString());
        }
      }

      // Find all sheets in declared order.
      final workbook = archive.findFile('xl/workbook.xml');
      final sheetEntries = <_SheetEntry>[];
      if (workbook != null) {
        final xml = XmlDocument.parse(utf8.decode(workbook.content));
        // Relationship resolution: r:id → target file.
        final relsFile = archive.findFile('xl/_rels/workbook.xml.rels');
        final relMap = <String, String>{};
        if (relsFile != null) {
          final rxml = XmlDocument.parse(utf8.decode(relsFile.content));
          for (final r in rxml.findAllElements('Relationship')) {
            final id = r.getAttribute('Id');
            final target = r.getAttribute('Target');
            if (id != null && target != null) relMap[id] = target;
          }
        }
        for (final s in xml.findAllElements('sheet')) {
          final name = s.getAttribute('name') ?? 'Sheet';
          final rid = s.getAttribute('r:id') ?? s.getAttribute('id');
          final target = (rid != null && relMap.containsKey(rid))
              ? 'xl/${relMap[rid]!.replaceFirst(RegExp(r'^/?xl/'), '')}'
              : 'xl/worksheets/sheet1.xml';
          sheetEntries.add(_SheetEntry(name: name, path: target));
        }
      }
      if (sheetEntries.isEmpty) {
        sheetEntries.add(_SheetEntry(name: 'Sheet1', path: 'xl/worksheets/sheet1.xml'));
      }

      final allSheets = <_ParsedSheet>[];
      for (var s = 0; s < sheetEntries.length; s++) {
        onProgress?.call(
          0.20 + 0.6 * (s / sheetEntries.length),
          'Parsing ${sheetEntries[s].name}…',
        );
        final sheetFile = archive.findFile(sheetEntries[s].path);
        if (sheetFile == null) continue;
        final xml = XmlDocument.parse(utf8.decode(sheetFile.content));
        final rows = <List<String>>[];
        for (final row in xml.findAllElements('row')) {
          final rowData = <String>[];
          for (final cell in row.findAllElements('c')) {
            String val = '';
            final type = cell.getAttribute('t');
            if (type == 'inlineStr') {
              val = cell.findElements('is').firstOrNull?.innerText ?? '';
            } else {
              final v = cell.findElements('v').firstOrNull?.innerText ?? '';
              if (type == 's') {
                final idx = int.tryParse(v) ?? -1;
                val = (idx >= 0 && idx < sharedStrings.length)
                    ? sharedStrings[idx]
                    : '';
              } else {
                val = v;
              }
            }
            rowData.add(val);
          }
          if (rowData.any((c) => c.trim().isNotEmpty)) rows.add(rowData);
        }
        allSheets.add(_ParsedSheet(name: sheetEntries[s].name, rows: rows));
      }

      if (allSheets.every((s) => s.rows.isEmpty)) {
        allSheets
          ..clear()
          ..add(_ParsedSheet(
            name: 'Sheet1',
            rows: [
              ['This spreadsheet appears to be empty.'],
            ],
          ));
      }

      onProgress?.call(0.85, 'Rendering PDF…');
      final pdf = pw.Document();
      for (final sheet in allSheets) {
        final maxCols = sheet.rows.fold<int>(
          0,
          (m, r) => r.length > m ? r.length : m,
        );
        final normalised = sheet.rows
            .map((r) => r.length < maxCols
                ? [...r, ...List.filled(maxCols - r.length, '')]
                : r)
            .toList();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(28),
            header: (ctx) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    sheet.name,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF1F3864),
                    ),
                  ),
                  pw.Text(
                    '${ctx.pageNumber} / ${ctx.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            build: (ctx) => [
              pw.TableHelper.fromTextArray(
                data: normalised,
                border: pw.TableBorder.all(
                  color: PdfColor.fromInt(0xFFCBD5E1),
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1F2937),
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0E7FF),
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 3,
                ),
              ),
            ],
          ),
        );
      }

      final outputFile = await _createOutputFile(excelFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('Excel to PDF conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PowerPoint (.pptx) → PDF
  // ─────────────────────────────────────────────────────────────────

  Future<File> powerPointToPdf(
    File pptFile, {
    ConversionProgress? onProgress,
  }) async {
    try {
      final ext = _ext(pptFile);
      if (ext == 'ppt') {
        throw Exception('Legacy .ppt files are not supported. Please save as .pptx first.');
      }

      onProgress?.call(0.10, 'Reading presentation…');
      final bytes = await pptFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final slideFiles = archive.files
          .where((f) =>
              f.name.startsWith('ppt/slides/slide') && f.name.endsWith('.xml'))
          .toList()
        ..sort((a, b) => _natCompare(a.name, b.name));

      final slides = <_ParsedSlide>[];
      for (var i = 0; i < slideFiles.length; i++) {
        onProgress?.call(
          0.15 + 0.55 * (i / math.max(slideFiles.length, 1)),
          'Parsing slide ${i + 1}/${slideFiles.length}…',
        );
        try {
          final content = utf8.decode(slideFiles[i].content);
          final xml = XmlDocument.parse(content);
          String? title;
          final bullets = <String>[];

          for (final sp in xml.findAllElements('p:sp')) {
            final ph = sp.findAllElements('p:ph').firstOrNull;
            final phType = ph?.getAttribute('type');
            final isTitle = phType == 'title' || phType == 'ctrTitle';
            final paragraphs = sp.findAllElements('a:p');
            for (final paraEl in paragraphs) {
              final text = paraEl
                  .findAllElements('a:t')
                  .map((t) => t.innerText)
                  .join();
              final trimmed = text.trim();
              if (trimmed.isEmpty) continue;
              if (isTitle && title == null) {
                title = trimmed;
              } else {
                bullets.add(trimmed);
              }
            }
          }
          slides.add(_ParsedSlide(
            title: title ?? 'Slide ${i + 1}',
            bullets: bullets,
          ));
        } catch (e) {
          debugPrint('Failed to parse slide ${i + 1}: $e');
          slides.add(_ParsedSlide(
            title: 'Slide ${i + 1}',
            bullets: const ['[Could not parse this slide]'],
          ));
        }
      }

      if (slides.isEmpty) {
        slides.add(const _ParsedSlide(
          title: 'Empty presentation',
          bullets: ['No slides found in this file.'],
        ));
      }

      onProgress?.call(0.78, 'Rendering PDF…');
      final pdf = pw.Document();
      for (var i = 0; i < slides.length; i++) {
        final s = slides[i];
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 36),
            build: (ctx) => pw.Stack(
              children: [
                pw.Positioned(
                  bottom: 8,
                  right: 8,
                  child: pw.Text(
                    'Slide ${i + 1} / ${slides.length}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColor.fromInt(0xFF6B7280),
                    ),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      s.title,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF1F3864),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      height: 2,
                      width: 80,
                      color: PdfColor.fromInt(0xFF4F46E5),
                    ),
                    pw.SizedBox(height: 18),
                    ...s.bullets.map((b) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 3),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '•  ',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  b,
                                  style: const pw.TextStyle(
                                    fontSize: 12,
                                    lineSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      final outputFile = await _createOutputFile(pptFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('PowerPoint to PDF conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Text → PDF
  // ─────────────────────────────────────────────────────────────────

  Future<File> textToPdf(File textFile, {ConversionProgress? onProgress}) async {
    try {
      onProgress?.call(0.20, 'Reading text…');
      String content;
      try {
        content = await textFile.readAsString(encoding: utf8);
      } catch (_) {
        content = await textFile.readAsString(encoding: latin1);
      }

      // Strip characters that can't be drawn by the default Helvetica font
      // (we have no embedded Unicode font here).
      final ascii = content.replaceAll(RegExp(r'[^\x00-\x7F]'), '?');
      final title = p.basenameWithoutExtension(textFile.path);

      onProgress?.call(0.55, 'Rendering PDF…');
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(48, 56, 48, 56),
          header: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF1F3864),
                  ),
                ),
                pw.Text(
                  '${ctx.pageNumber} / ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          build: (ctx) => [
            pw.Text(
              ascii.isEmpty ? '[Empty file]' : ascii,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4),
            ),
          ],
        ),
      );

      final outputFile = await _createOutputFile(textFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      onProgress?.call(1.0, 'Done');
      return outputFile;
    } catch (e) {
      throw Exception('Text to PDF conversion failed: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Merge PDFs
  // ─────────────────────────────────────────────────────────────────

  Future<File> mergePdfs(
    List<File> pdfFiles, {
    ConversionProgress? onProgress,
  }) async {
    if (pdfFiles.length < 2) {
      throw Exception('Select at least 2 PDF files to merge.');
    }
    syncfusion.PdfDocument? output;
    try {
      output = syncfusion.PdfDocument();
      for (var i = 0; i < pdfFiles.length; i++) {
        onProgress?.call(
          0.1 + 0.8 * (i / pdfFiles.length),
          'Merging ${i + 1}/${pdfFiles.length}: ${p.basename(pdfFiles[i].path)}',
        );
        final bytes = await pdfFiles[i].readAsBytes();
        syncfusion.PdfDocument? input;
        try {
          input = syncfusion.PdfDocument(inputBytes: bytes);
          for (var j = 0; j < input.pages.count; j++) {
            output.pages.add().graphics.drawPdfTemplate(
                  input.pages[j].createTemplate(),
                  const Offset(0, 0),
                );
          }
        } finally {
          input?.dispose();
        }
      }

      onProgress?.call(0.95, 'Saving merged PDF…');
      final bytes = await output.save();
      final outputFile = await _createOutputFile(pdfFiles.first, 'pdf');
      final mergedName = p.join(
        p.dirname(outputFile.path),
        'merged_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final finalFile = File(mergedName);
      await finalFile.writeAsBytes(bytes);
      onProgress?.call(1.0, 'Done');
      return finalFile;
    } catch (e) {
      throw Exception('Merge PDF failed: ${e.toString()}');
    } finally {
      output?.dispose();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // helpers
  // ─────────────────────────────────────────────────────────────────

  String _ext(File file) =>
      p.extension(file.path).replaceFirst('.', '').toLowerCase();

  /// Create an output file in the app temp directory using the input's name.
  Future<File> _createOutputFile(File inputFile, String newExtension) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basename(inputFile.path);
    final dotIndex = fileName.lastIndexOf('.');
    final nameWithoutExt =
        dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(
      tempDir.path,
      '${nameWithoutExt}_$timestamp.$newExtension',
    );
    return File(outputPath);
  }

  /// Natural string comparison so `slide2.xml` comes before `slide10.xml`.
  int _natCompare(String a, String b) {
    final reg = RegExp(r'(\d+)|(\D+)');
    final aTokens = reg.allMatches(a).toList();
    final bTokens = reg.allMatches(b).toList();
    for (var i = 0; i < math.min(aTokens.length, bTokens.length); i++) {
      final ax = aTokens[i].group(0)!;
      final bx = bTokens[i].group(0)!;
      final aNum = int.tryParse(ax);
      final bNum = int.tryParse(bx);
      if (aNum != null && bNum != null) {
        final cmp = aNum.compareTo(bNum);
        if (cmp != 0) return cmp;
      } else {
        final cmp = ax.compareTo(bx);
        if (cmp != 0) return cmp;
      }
    }
    return a.length.compareTo(b.length);
  }

  /// Human-readable file size used by the provider for display.
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

// ─────────────────────── private helpers ───────────────────────

class _Cell {
  final String text;
  final double left;
  final double right;
  _Cell({required this.text, required this.left, required this.right});
}

class _ColumnRange {
  final double min;
  final double max;
  final double mid;
  _ColumnRange({required this.min, required this.max, required this.mid});
}

class _SheetEntry {
  final String name;
  final String path;
  _SheetEntry({required this.name, required this.path});
}

class _ParsedSheet {
  final String name;
  final List<List<String>> rows;
  _ParsedSheet({required this.name, required this.rows});
}

class _ParsedSlide {
  final String title;
  final List<String> bullets;
  const _ParsedSlide({required this.title, required this.bullets});
}

class _DocxParaPreview {
  final String? styleId;
  final pw.TextAlign? align;
  final List<_DocxRunPreview> spans;
  _DocxParaPreview({
    required this.styleId,
    required this.align,
    required this.spans,
  });
}

class _DocxRunPreview {
  final String text;
  final bool bold;
  final bool italic;
  final double? fontSize;
  _DocxRunPreview({
    required this.text,
    required this.bold,
    required this.italic,
    required this.fontSize,
  });
}
