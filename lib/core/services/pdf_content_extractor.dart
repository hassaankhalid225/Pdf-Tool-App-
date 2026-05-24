import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// Structured PDF content extracted via Syncfusion.
///
/// Layout-aware: every line and word carries its bounding rectangle and
/// typographic metadata so downstream converters (DOCX, XLSX, EPUB, HTML,
/// PPTX) can reconstruct the original document instead of emitting a flat
/// text dump.
class PdfExtractedContent {
  final String fileName;
  final int pageCount;
  final List<PdfPageContent> pages;
  final bool hasSelectableText;

  const PdfExtractedContent({
    required this.fileName,
    required this.pageCount,
    required this.pages,
    required this.hasSelectableText,
  });

  String get fullText {
    final buffer = StringBuffer();
    for (var i = 0; i < pages.length; i++) {
      if (i > 0) buffer.writeln();
      buffer.writeln('--- Page ${pages[i].pageNumber} ---');
      for (final line in pages[i].lines) {
        buffer.writeln(line.text);
      }
    }
    return buffer.toString().trim();
  }
}

class PdfPageContent {
  final int pageNumber;
  final List<PdfTextLine> lines;
  final double pageWidth;
  final double pageHeight;

  const PdfPageContent({
    required this.pageNumber,
    required this.lines,
    this.pageWidth = 0,
    this.pageHeight = 0,
  });
}

class PdfTextLine {
  final String text;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final String fontName;
  final Rect bounds;
  final List<PdfTextWord> words;

  const PdfTextLine({
    required this.text,
    this.fontSize = 11,
    this.isBold = false,
    this.isItalic = false,
    this.fontName = '',
    this.bounds = Rect.zero,
    this.words = const [],
  });
}

class PdfTextWord {
  final String text;
  final Rect bounds;
  final double fontSize;
  final bool isBold;
  final bool isItalic;

  const PdfTextWord({
    required this.text,
    required this.bounds,
    this.fontSize = 11,
    this.isBold = false,
    this.isItalic = false,
  });
}

/// Centralised PDF text extraction using Syncfusion.
class PdfContentExtractor {
  static Future<PdfExtractedContent> extract(File pdfFile) async {
    sf.PdfDocument? document;
    try {
      final bytes = await pdfFile.readAsBytes();
      document = sf.PdfDocument(inputBytes: bytes);
      final fileName = pdfFile.path.split(Platform.pathSeparator).last;
      final pages = <PdfPageContent>[];
      final extractor = sf.PdfTextExtractor(document);
      final pageCount = document.pages.count;

      for (var pageIndex = 0; pageIndex < pageCount; pageIndex++) {
        final pageRef = document.pages[pageIndex];
        final lines = <PdfTextLine>[];
        final textLines = extractor.extractTextLines(
          startPageIndex: pageIndex,
          endPageIndex: pageIndex,
        );

        if (textLines.isNotEmpty) {
          for (final line in textLines) {
            final trimmed = line.text.trim();
            if (trimmed.isEmpty) continue;

            final styleSet = line.fontStyle;
            final fontNameLower = line.fontName.toLowerCase();

            bool isBold(List<sf.PdfFontStyle> styles, String fontNm) =>
                styles.contains(sf.PdfFontStyle.bold) ||
                fontNm.contains('bold') ||
                fontNm.contains('black') ||
                fontNm.contains('heavy');
            bool isItalic(List<sf.PdfFontStyle> styles, String fontNm) =>
                styles.contains(sf.PdfFontStyle.italic) ||
                fontNm.contains('italic') ||
                fontNm.contains('oblique');

            final words = <PdfTextWord>[];
            for (final w in line.wordCollection) {
              final wt = w.text.trim();
              if (wt.isEmpty) continue;
              final fontLower = w.fontName.toLowerCase();
              words.add(PdfTextWord(
                text: wt,
                bounds: w.bounds,
                fontSize: w.fontSize > 0 ? w.fontSize : line.fontSize,
                isBold: isBold(w.fontStyle, fontLower),
                isItalic: isItalic(w.fontStyle, fontLower),
              ));
            }

            lines.add(PdfTextLine(
              text: trimmed,
              fontSize: line.fontSize > 0 ? line.fontSize : 11,
              isBold: isBold(styleSet, fontNameLower),
              isItalic: isItalic(styleSet, fontNameLower),
              fontName: line.fontName,
              bounds: line.bounds,
              words: words,
            ));
          }
        } else {
          final fallback = extractor
              .extractText(startPageIndex: pageIndex, endPageIndex: pageIndex)
              .trim();
          if (fallback.isNotEmpty) {
            for (final part in fallback.split(RegExp(r'\r?\n'))) {
              final trimmed = part.trim();
              if (trimmed.isNotEmpty) {
                lines.add(PdfTextLine(text: trimmed));
              }
            }
          }
        }

        pages.add(PdfPageContent(
          pageNumber: pageIndex + 1,
          lines: lines,
          pageWidth: pageRef.size.width,
          pageHeight: pageRef.size.height,
        ));
      }

      final hasText = pages.any((p) => p.lines.isNotEmpty);

      return PdfExtractedContent(
        fileName: fileName,
        pageCount: pageCount,
        pages: pages,
        hasSelectableText: hasText,
      );
    } finally {
      document?.dispose();
    }
  }
}
