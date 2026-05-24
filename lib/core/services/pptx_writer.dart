import 'dart:convert';

import 'package:archive/archive.dart';

/// A single slide for the PPTX writer.
class PptxSlide {
  final String title;
  final List<String> bullets;

  const PptxSlide({required this.title, required this.bullets});
}

/// Builds a valid PowerPoint (.pptx) file from in-memory slide data.
///
/// The generated package follows the Office Open XML (ECMA-376) PresentationML
/// schema with the minimum parts needed for PowerPoint, Keynote, Google Slides
/// and LibreOffice Impress to open the file cleanly:
///
///   * `[Content_Types].xml`
///   * `_rels/.rels`
///   * `ppt/presentation.xml` (+ rels)
///   * `ppt/slideMasters/slideMaster1.xml` (+ rels)
///   * `ppt/slideLayouts/slideLayout1.xml` (+ rels)
///   * `ppt/theme/theme1.xml`
///   * `ppt/slides/slide{N}.xml` (+ rels)
class PptxWriter {
  static List<int> build({
    required String title,
    required List<PptxSlide> slides,
  }) {
    if (slides.isEmpty) {
      slides = [const PptxSlide(title: 'Empty Document', bullets: [])];
    }

    final archive = Archive();
    final n = slides.length;

    _add(archive, '[Content_Types].xml', _contentTypes(n));
    _add(archive, '_rels/.rels', _rootRels());
    _add(archive, 'docProps/core.xml', _coreProps(title));
    _add(archive, 'docProps/app.xml', _appProps(n));
    _add(archive, 'ppt/presentation.xml', _presentation(n));
    _add(archive, 'ppt/_rels/presentation.xml.rels', _presentationRels(n));
    _add(archive, 'ppt/theme/theme1.xml', _theme());
    _add(archive, 'ppt/slideMasters/slideMaster1.xml', _slideMaster());
    _add(archive, 'ppt/slideMasters/_rels/slideMaster1.xml.rels', _slideMasterRels());
    _add(archive, 'ppt/slideLayouts/slideLayout1.xml', _slideLayout());
    _add(archive, 'ppt/slideLayouts/_rels/slideLayout1.xml.rels', _slideLayoutRels());

    for (var i = 0; i < n; i++) {
      _add(archive, 'ppt/slides/slide${i + 1}.xml', _slide(slides[i]));
      _add(archive, 'ppt/slides/_rels/slide${i + 1}.xml.rels', _slideRels());
    }

    final bytes = ZipEncoder().encode(archive);
    if (bytes.isEmpty) throw StateError('Failed to encode .pptx archive');
    return bytes;
  }

  static void _add(Archive a, String path, String xml) {
    final bytes = utf8.encode(xml);
    a.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  // ─────────────────────── package parts ───────────────────────

  static String _contentTypes(int n) {
    final overrides = StringBuffer()
      ..write('<Override PartName="/ppt/presentation.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>')
      ..write('<Override PartName="/ppt/slideMasters/slideMaster1.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>')
      ..write('<Override PartName="/ppt/slideLayouts/slideLayout1.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>')
      ..write('<Override PartName="/ppt/theme/theme1.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>')
      ..write('<Override PartName="/docProps/core.xml" '
          'ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>')
      ..write('<Override PartName="/docProps/app.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>');
    for (var i = 0; i < n; i++) {
      overrides.write('<Override PartName="/ppt/slides/slide${i + 1}.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>');
    }
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '$overrides'
        '</Types>';
  }

  static String _rootRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
      '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
      '</Relationships>';

  static String _coreProps(String title) {
    final now = DateTime.now().toUtc().toIso8601String();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" '
        'xmlns:dcterms="http://purl.org/dc/terms/" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        '<dc:title>${_esc(title)}</dc:title>'
        '<dc:creator>PDF Tools Pro</dc:creator>'
        '<cp:lastModifiedBy>PDF Tools Pro</cp:lastModifiedBy>'
        '<dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created>'
        '<dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified>'
        '</cp:coreProperties>';
  }

  static String _appProps(int n) => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
      'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
      '<Application>PDF Tools Pro</Application>'
      '<PresentationFormat>Widescreen</PresentationFormat>'
      '<Slides>$n</Slides>'
      '<Notes>0</Notes>'
      '<HiddenSlides>0</HiddenSlides>'
      '<MMClips>0</MMClips>'
      '<ScaleCrop>false</ScaleCrop>'
      '<LinksUpToDate>false</LinksUpToDate>'
      '<SharedDoc>false</SharedDoc>'
      '<HyperlinksChanged>false</HyperlinksChanged>'
      '<AppVersion>1.0000</AppVersion>'
      '</Properties>';

  static String _presentation(int n) {
    final sldIdLst = StringBuffer();
    for (var i = 0; i < n; i++) {
      sldIdLst.write('<p:sldId id="${256 + i}" r:id="rId${i + 2}"/>');
    }
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" saveSubsetFonts="1">'
        '<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>'
        '<p:sldIdLst>$sldIdLst</p:sldIdLst>'
        '<p:sldSz cx="12192000" cy="6858000" type="screen16x9"/>'
        '<p:notesSz cx="6858000" cy="9144000"/>'
        '<p:defaultTextStyle><a:defPPr><a:defRPr lang="en-US"/></a:defPPr></p:defaultTextStyle>'
        '</p:presentation>';
  }

  static String _presentationRels(int n) {
    final rels = StringBuffer()
      ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
      ..write('<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">')
      ..write('<Relationship Id="rId1" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" '
          'Target="slideMasters/slideMaster1.xml"/>');
    for (var i = 0; i < n; i++) {
      rels.write('<Relationship Id="rId${i + 2}" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" '
          'Target="slides/slide${i + 1}.xml"/>');
    }
    rels.write('<Relationship Id="rId${n + 2}" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" '
        'Target="theme/theme1.xml"/>');
    rels.write('</Relationships>');
    return rels.toString();
  }

  static String _theme() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">'
      '<a:themeElements>'
      '<a:clrScheme name="Office">'
      '<a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1>'
      '<a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1>'
      '<a:dk2><a:srgbClr val="1F3864"/></a:dk2>'
      '<a:lt2><a:srgbClr val="E7E6E6"/></a:lt2>'
      '<a:accent1><a:srgbClr val="4F46E5"/></a:accent1>'
      '<a:accent2><a:srgbClr val="7C3AED"/></a:accent2>'
      '<a:accent3><a:srgbClr val="F59E0B"/></a:accent3>'
      '<a:accent4><a:srgbClr val="10B981"/></a:accent4>'
      '<a:accent5><a:srgbClr val="EF4444"/></a:accent5>'
      '<a:accent6><a:srgbClr val="06B6D4"/></a:accent6>'
      '<a:hlink><a:srgbClr val="0563C1"/></a:hlink>'
      '<a:folHlink><a:srgbClr val="954F72"/></a:folHlink>'
      '</a:clrScheme>'
      '<a:fontScheme name="Office">'
      '<a:majorFont><a:latin typeface="Calibri Light"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont>'
      '<a:minorFont><a:latin typeface="Calibri"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont>'
      '</a:fontScheme>'
      '<a:fmtScheme name="Office">'
      '<a:fillStyleLst>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>'
      '</a:fillStyleLst>'
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

  static String _slideMaster() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
      'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">'
      '<p:cSld><p:bg><p:bgRef idx="1001"><a:schemeClr val="bg1"/></p:bgRef></p:bg>'
      '<p:spTree>'
      '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>'
      '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
      '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
      '</p:spTree></p:cSld>'
      '<p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" '
      'accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>'
      '<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst>'
      '<p:txStyles>'
      '<p:titleStyle>'
      '<a:lvl1pPr algn="l"><a:defRPr sz="3600" b="1"><a:solidFill><a:schemeClr val="tx1"/></a:solidFill>'
      '<a:latin typeface="+mj-lt"/></a:defRPr></a:lvl1pPr>'
      '</p:titleStyle>'
      '<p:bodyStyle>'
      '<a:lvl1pPr><a:defRPr sz="2000"><a:solidFill><a:schemeClr val="tx1"/></a:solidFill>'
      '<a:latin typeface="+mn-lt"/></a:defRPr></a:lvl1pPr>'
      '<a:lvl2pPr indent="-228600" marL="457200">'
      '<a:defRPr sz="1800"><a:solidFill><a:schemeClr val="tx1"/></a:solidFill></a:defRPr></a:lvl2pPr>'
      '</p:bodyStyle>'
      '<p:otherStyle/>'
      '</p:txStyles>'
      '</p:sldMaster>';

  static String _slideMasterRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>'
      '</Relationships>';

  static String _slideLayout() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
      'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" type="obj" preserve="1">'
      '<p:cSld name="Title and Content">'
      '<p:spTree>'
      '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>'
      '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
      '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
      '</p:spTree></p:cSld>'
      '<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>'
      '</p:sldLayout>';

  static String _slideLayoutRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>'
      '</Relationships>';

  static String _slideRels() => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>'
      '</Relationships>';

  static String _slide(PptxSlide slide) {
    final body = StringBuffer();
    if (slide.bullets.isEmpty) {
      body.write('<a:p><a:endParaRPr lang="en-US"/></a:p>');
    } else {
      for (final bullet in slide.bullets) {
        if (bullet.trim().isEmpty) continue;
        body.write('<a:p>'
            '<a:pPr marL="285750" indent="-285750"><a:buFont typeface="Arial" panose="020B0604020202020204" pitchFamily="34" charset="0"/><a:buChar char="•"/></a:pPr>'
            '<a:r><a:rPr lang="en-US" sz="1800" dirty="0"/><a:t>${_esc(bullet)}</a:t></a:r>'
            '</a:p>');
      }
    }

    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">'
        '<p:cSld><p:spTree>'
        '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>'
        '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/>'
        '<a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
        '<p:sp>'
        '<p:nvSpPr><p:cNvPr id="2" name="Title"/><p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>'
        '<p:nvPr><p:ph type="title"/></p:nvPr></p:nvSpPr>'
        '<p:spPr>'
        '<a:xfrm><a:off x="838200" y="365125"/><a:ext cx="10515600" cy="1325563"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></p:spPr>'
        '<p:txBody><a:bodyPr/><a:lstStyle/>'
        '<a:p><a:r><a:rPr lang="en-US" sz="3600" b="1"><a:solidFill><a:srgbClr val="1F3864"/></a:solidFill></a:rPr>'
        '<a:t>${_esc(slide.title)}</a:t></a:r></a:p>'
        '</p:txBody>'
        '</p:sp>'
        '<p:sp>'
        '<p:nvSpPr><p:cNvPr id="3" name="Content"/><p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>'
        '<p:nvPr><p:ph idx="1"/></p:nvPr></p:nvSpPr>'
        '<p:spPr>'
        '<a:xfrm><a:off x="838200" y="1825625"/><a:ext cx="10515600" cy="4351338"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></p:spPr>'
        '<p:txBody><a:bodyPr/><a:lstStyle/>$body</p:txBody>'
        '</p:sp>'
        '</p:spTree></p:cSld>'
        '</p:sld>';
  }
}
