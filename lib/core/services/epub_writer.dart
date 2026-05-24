import 'dart:convert';

import 'package:archive/archive.dart';

/// A logical chapter inside the generated EPUB.
class EpubChapter {
  final String title;
  final List<EpubBlock> blocks;

  const EpubChapter({required this.title, required this.blocks});
}

/// A single block of typed content (paragraph or heading).
class EpubBlock {
  final String text;
  final EpubBlockType type;

  const EpubBlock(this.text, [this.type = EpubBlockType.paragraph]);
}

enum EpubBlockType { heading1, heading2, heading3, paragraph }

/// Builds a valid EPUB 3 package from in-memory chapter data.
///
/// Structure:
///   * `mimetype`               – stored uncompressed, first entry
///   * `META-INF/container.xml` – points to the OPF
///   * `OEBPS/content.opf`      – package metadata + manifest + spine
///   * `OEBPS/nav.xhtml`        – navigation document (table of contents)
///   * `OEBPS/styles.css`       – book styles
///   * `OEBPS/chapter{N}.xhtml` – one XHTML file per chapter
class EpubWriter {
  static List<int> build({
    required String title,
    required List<EpubChapter> chapters,
    String author = 'PDF Tools Pro',
    String language = 'en',
  }) {
    if (chapters.isEmpty) {
      chapters = [
        const EpubChapter(title: 'Untitled', blocks: [
          EpubBlock('This document is empty.'),
        ]),
      ];
    }

    final archive = Archive();

    // mimetype MUST be the first file and stored uncompressed.
    final mimeBytes = utf8.encode('application/epub+zip');
    archive.addFile(
      ArchiveFile.noCompress('mimetype', mimeBytes.length, mimeBytes),
    );

    _add(archive, 'META-INF/container.xml', _container());
    _add(archive, 'OEBPS/styles.css', _styles());
    _add(archive, 'OEBPS/content.opf', _opf(title, author, language, chapters));
    _add(archive, 'OEBPS/nav.xhtml', _nav(title, chapters));

    for (var i = 0; i < chapters.length; i++) {
      _add(archive, 'OEBPS/chapter${i + 1}.xhtml',
          _chapter(chapters[i], i + 1));
    }

    final bytes = ZipEncoder().encode(archive);
    if (bytes.isEmpty) throw StateError('Failed to encode EPUB archive');
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

  static String _uuid(String title) {
    final raw = '${DateTime.now().millisecondsSinceEpoch}-${title.hashCode}';
    return 'urn:uuid:pdftools-${raw.hashCode.abs()}';
  }

  // ───────────────────────── parts ─────────────────────────

  static String _container() => '<?xml version="1.0" encoding="UTF-8"?>'
      '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
      '<rootfiles>'
      '<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>'
      '</rootfiles>'
      '</container>';

  static String _styles() => '''
@charset "UTF-8";
html, body { margin: 0; padding: 0; }
body {
  font-family: Georgia, "Times New Roman", serif;
  line-height: 1.6;
  color: #1f2937;
  padding: 1.2em;
}
h1 { font-size: 1.8em; color: #1F3864; margin: 0.8em 0 0.4em; }
h2 { font-size: 1.4em; color: #2F5496; margin: 1em 0 0.4em; }
h3 { font-size: 1.15em; color: #1F3864; margin: 0.9em 0 0.3em; }
p { margin: 0.5em 0; text-align: justify; text-indent: 1.2em; }
p.lead { text-indent: 0; font-size: 1.05em; }
''';

  static String _opf(
    String title,
    String author,
    String language,
    List<EpubChapter> chapters,
  ) {
    final uid = _uuid(title);
    final manifest = StringBuffer()
      ..write('<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>')
      ..write('<item id="css" href="styles.css" media-type="text/css"/>');
    final spine = StringBuffer();
    for (var i = 0; i < chapters.length; i++) {
      manifest.write('<item id="ch${i + 1}" href="chapter${i + 1}.xhtml" '
          'media-type="application/xhtml+xml"/>');
      spine.write('<itemref idref="ch${i + 1}"/>');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final modified = '${now.substring(0, 19)}Z';

    return '<?xml version="1.0" encoding="UTF-8"?>'
        '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" '
        'unique-identifier="BookID" xml:lang="$language">'
        '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<dc:identifier id="BookID">$uid</dc:identifier>'
        '<dc:title>${_esc(title)}</dc:title>'
        '<dc:creator>${_esc(author)}</dc:creator>'
        '<dc:language>$language</dc:language>'
        '<meta property="dcterms:modified">$modified</meta>'
        '</metadata>'
        '<manifest>$manifest</manifest>'
        '<spine>$spine</spine>'
        '</package>';
  }

  static String _nav(String title, List<EpubChapter> chapters) {
    final items = StringBuffer();
    for (var i = 0; i < chapters.length; i++) {
      items.write('<li><a href="chapter${i + 1}.xhtml">'
          '${_esc(chapters[i].title)}</a></li>');
    }
    return '<?xml version="1.0" encoding="UTF-8"?>'
        '<!DOCTYPE html>'
        '<html xmlns="http://www.w3.org/1999/xhtml" '
        'xmlns:epub="http://www.idpf.org/2007/ops">'
        '<head><meta charset="UTF-8"/><title>${_esc(title)}</title>'
        '<link rel="stylesheet" type="text/css" href="styles.css"/>'
        '</head><body>'
        '<nav epub:type="toc" id="toc"><h1>Contents</h1><ol>$items</ol></nav>'
        '</body></html>';
  }

  static String _chapter(EpubChapter ch, int index) {
    final body = StringBuffer();
    body.write('<h1>${_esc(ch.title)}</h1>');
    for (final block in ch.blocks) {
      final t = _esc(block.text);
      switch (block.type) {
        case EpubBlockType.heading1:
          body.write('<h1>$t</h1>');
          break;
        case EpubBlockType.heading2:
          body.write('<h2>$t</h2>');
          break;
        case EpubBlockType.heading3:
          body.write('<h3>$t</h3>');
          break;
        case EpubBlockType.paragraph:
          body.write('<p>$t</p>');
          break;
      }
    }
    return '<?xml version="1.0" encoding="UTF-8"?>'
        '<!DOCTYPE html>'
        '<html xmlns="http://www.w3.org/1999/xhtml">'
        '<head><meta charset="UTF-8"/><title>${_esc(ch.title)}</title>'
        '<link rel="stylesheet" type="text/css" href="styles.css"/>'
        '</head>'
        '<body>$body</body>'
        '</html>';
  }
}
