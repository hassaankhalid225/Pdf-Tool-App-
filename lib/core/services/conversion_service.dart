import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Service for handling PDF and file conversions
class ConversionService {
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB

  /// Validate file before conversion
  Future<bool> validateFile(File file, List<String> allowedExtensions) async {
    try {
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      if (fileSize > maxFileSize) return false;

      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert PDF to Word document (DOCX)
  /// Uses manual XML construction + Zip to create a valid .docx file
  Future<File> pdfToWord(File pdfFile) async {
    try {
      // 1. Extract text from PDF
      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      final text = textExtractor.extractText();
      document.dispose();

      // 2. Create DOCX structure
      final archive = Archive();

      // [Content_Types].xml
      final contentTypes = XmlBuilder();
      contentTypes.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
      contentTypes.element('Types', namespaces: {'http://schemas.openxmlformats.org/package/2006/content-types': null}, nest: () {
        contentTypes.element('Default', attributes: {'Extension': 'rels', 'ContentType': 'application/vnd.openxmlformats-package.relationships+xml'});
        contentTypes.element('Default', attributes: {'Extension': 'xml', 'ContentType': 'application/xml'});
        contentTypes.element('Override', attributes: {'PartName': '/word/document.xml', 'ContentType': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'});
      });
      archive.addFile(ArchiveFile('[Content_Types].xml', contentTypes.buildDocument().toXmlString().length, utf8.encode(contentTypes.buildDocument().toXmlString())));

      // _rels/.rels
      final rels = XmlBuilder();
      rels.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
      rels.element('Relationships', namespaces: {'http://schemas.openxmlformats.org/package/2006/relationships': null}, nest: () {
        rels.element('Relationship', attributes: {
          'Id': 'rId1',
          'Type': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
          'Target': 'word/document.xml'
        });
      });
      archive.addFile(ArchiveFile('_rels/.rels', rels.buildDocument().toXmlString().length, utf8.encode(rels.buildDocument().toXmlString())));

      // word/document.xml
      final docXml = XmlBuilder();
      docXml.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
      docXml.element('w:document', namespaces: {'xmlns:w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}, nest: () {
        docXml.element('w:body', nest: () {
          // Add paragraphs
          final paragraphs = text.split('\n');
          for (var p in paragraphs) {
            String trimmed = p.trim();
            // Basic XML character checks are handled by xml package usually, but explicit replacements help if using raw strings inside
            // Using xml package .text() handles escaping automatically.
            if (trimmed.isNotEmpty) {
              docXml.element('w:p', nest: () {
                docXml.element('w:r', nest: () {
                  docXml.element('w:t', nest: () {
                    docXml.text(trimmed);
                  });
                });
              });
            }
          }
        });
      });
      
      final docContent = docXml.buildDocument().toXmlString();
      archive.addFile(ArchiveFile('word/document.xml', docContent.length, utf8.encode(docContent)));

      // 3. Save as .docx
      final outputFile = await _createOutputFile(pdfFile, 'docx');
      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive);
      if (zipBytes != null) {
        await outputFile.writeAsBytes(zipBytes);
      } else {
        throw Exception('Failed to encode DOCX');
      }

      return outputFile;

    } catch (e) {
      throw Exception('PDF to Word conversion failed: ${e.toString()}');
    }
  }

  /// Convert PDF to PowerPoint (PPTX)
  Future<File> pdfToPowerPoint(File pdfFile) async {
     try {
      // 1. Extract text
      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      final text = textExtractor.extractText();
      document.dispose();

      // 2. Create minimal PPTX
      final archive = Archive();
      
      final contentTypes = utf8.encode(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>'
        '<Override PartName="/ppt/slides/slide1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>'
        '</Types>'
      );
      archive.addFile(ArchiveFile('[Content_Types].xml', contentTypes.length, contentTypes));

      final rels = utf8.encode(
         '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>'
        '</Relationships>'
      );
      archive.addFile(ArchiveFile('_rels/.rels', rels.length, rels));

      final presentation = utf8.encode(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<p:sldIdLst>'
        '<p:sldId id="256" r:id="rId1"/>'
        '</p:sldIdLst>'
        '<p:sldSz cx="9144000" cy="6858000"/>'
        '<p:notesSz cx="6858000" cy="9144000"/>'
        '</p:presentation>'
      );
      archive.addFile(ArchiveFile('ppt/presentation.xml', presentation.length, presentation));

      final presRels = utf8.encode(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide1.xml"/>'
        '</Relationships>'
      );
      archive.addFile(ArchiveFile('ppt/_rels/presentation.xml.rels', presRels.length, presRels));
      
      final safeText = text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
      final slide = utf8.encode(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">'
        '<p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
        '<p:sp><p:nvSpPr><p:cNvPr id="2" name="TextBox 1"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="457200" y="1600200"/><a:ext cx="8229600" cy="4525963"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr><p:txBody><a:bodyPr rtlCol="0" anchor="t"/><a:lstStyle/><a:p><a:r><a:rPr lang="en-US" dirty="0" smtClean="0"/><a:t>$safeText</a:t></a:r></a:p></p:txBody></p:sp>'
        '</p:spTree></p:cSld>'
        '</p:sld>'
      );
      archive.addFile(ArchiveFile('ppt/slides/slide1.xml', slide.length, slide));

      final outputFile = await _createOutputFile(pdfFile, 'pptx');
      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive);
      if (zipBytes != null) {
        await outputFile.writeAsBytes(zipBytes);
      } else {
        throw Exception('Failed to encode PPTX');
      }

      return outputFile;
    } catch (e) {
      throw Exception('PDF to PowerPoint conversion failed: ${e.toString()}');
    }
  }

  /// Convert PDF to Excel
  Future<File> pdfToExcel(File pdfFile) async {
    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];

      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      
      for (int i = 0; i < document.pages.count; i++) {
        final List<syncfusion.TextLine> lines = textExtractor.extractTextLines(startPageIndex: i, endPageIndex: i);
        for (int j = 0; j < lines.length; j++) {
          final line = lines[j];
          final parts = line.text.split(RegExp(r'\s{2,}'));
          for (int k = 0; k < parts.length; k++) {
            final rowIndex = (i * 50) + j + 1; 
            sheet.getRangeByIndex(rowIndex, k + 1).setText(parts[k].trim());
          }
        }
      }

      final List<int> excelBytes = workbook.saveAsStream();
      workbook.dispose();
      document.dispose();

      final outputFile = await _createOutputFile(pdfFile, 'xlsx');
      await outputFile.writeAsBytes(excelBytes);
      return outputFile;
    } catch (e) {
      throw Exception('PDF to Excel conversion failed: ${e.toString()}');
    }
  }

  /// Convert PDF to Image
  Future<File> pdfToImage(File pdfFile, ImageFormat format, {String quality = 'high'}) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      int dpi = 300;
      if (quality == 'medium') dpi = 150;
      if (quality == 'low') dpi = 72;

      // Currently only converts the FIRST page
      await for (final page in Printing.raster(bytes, pages: [0], dpi: dpi.toDouble())) {
        final imageBytes = await page.toPng();
        final outputFile = await _createOutputFile(pdfFile, 'png');
        await outputFile.writeAsBytes(imageBytes);
        return outputFile;
      }
      
      throw Exception('Failed to render PDF page');
    } catch (e) {
      throw Exception('PDF to Image conversion failed: ${e.toString()}');
    }
  }

  /// Convert PDF to Text
  Future<File> pdfToText(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      final text = textExtractor.extractText();
      
      final outputFile = await _createOutputFile(pdfFile, 'txt');
      await outputFile.writeAsString(text);
      
      document.dispose();
      return outputFile;
    } catch (e) {
      throw Exception('PDF to Text conversion failed: ${e.toString()}');
    }
  }

  /// Convert Image to PDF
  Future<File> imageToPdf(File imageFile, {String quality = 'high'}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
        ),
      );

      final outputFile = await _createOutputFile(imageFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;
    } catch (e) {
      throw Exception('Image to PDF conversion failed: ${e.toString()}');
    }
  }

  /// Convert Word to PDF
  Future<File> wordToPdf(File wordFile) async {
    try {
      String textContent = '';
      try {
        final bytes = await wordFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        final docFile = archive.findFile('word/document.xml');
        if (docFile != null) {
          final content = utf8.decode(docFile.content);
          final xmlDoc = XmlDocument.parse(content);
          textContent = xmlDoc.findAllElements('w:t').map((node) => node.innerText).join('\n');
        }
      } catch (e) {
        debugPrint('Failed to parse docx: $e');
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [pw.Text(textContent.isNotEmpty ? textContent : "Could not parse Word document content.", style: const pw.TextStyle(fontSize: 12))],
        ),
      );

      final outputFile = await _createOutputFile(wordFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;
    } catch (e) {
      throw Exception('Word to PDF conversion failed: ${e.toString()}');
    }
  }

  /// Convert Excel to PDF (Parsing XML)
  Future<File> excelToPdf(File excelFile) async {
    try {
      // Manual XLSX parsing since XlsIO read is limited in Flutter package
      final bytes = await excelFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      List<String> sharedStrings = [];
      List<List<String>> rows = [];

      // 1. Parse Shared Strings
      final sharedStringsFile = archive.findFile('xl/sharedStrings.xml');
      if (sharedStringsFile != null) {
        final content = utf8.decode(sharedStringsFile.content);
        final xml = XmlDocument.parse(content);
        // shared strings often in <si><t>...</t></si>
        sharedStrings = xml.findAllElements('t').map((e) => e.innerText).toList();
      }

      // 2. Parse Sheet 1
      final sheetFile = archive.findFile('xl/worksheets/sheet1.xml');
      if (sheetFile != null) {
        final content = utf8.decode(sheetFile.content);
        final xml = XmlDocument.parse(content);
        final xmlRows = xml.findAllElements('row');
        
        for (var row in xmlRows) {
          List<String> rowData = [];
          final cells = row.findAllElements('c');
          for (var cell in cells) {
            String val = '';
            final vNode = cell.findElements('v').firstOrNull;
            if (vNode != null) {
               val = vNode.innerText;
               final type = cell.getAttribute('t');
               if (type == 's') {
                 // Shared string index
                 final index = int.tryParse(val) ?? -1;
                 if (index >= 0 && index < sharedStrings.length) {
                   val = sharedStrings[index];
                 }
               }
            }
            rowData.add(val);
          }
          if (rowData.isNotEmpty) rows.add(rowData);
          if (rows.length > 50) break; // Limit for demo
        }
      }

      // 3. Generate PDF
      if (rows.isEmpty) {
        rows.add(['No data found in parsed Excel']);
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
             // Handle column count mismatch for table
             int maxCols = 0;
             for (var r in rows) maxCols = r.length > maxCols ? r.length : maxCols;
             
             // Pad rows
             final normalizedRows = rows.map((r) {
               if (r.length < maxCols) {
                 return [...r, ...List.filled(maxCols - r.length, '')];
               }
               return r;
             }).toList();

            return pw.Table.fromTextArray(
              data: normalizedRows,
              border: pw.TableBorder.all(),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            );
          },
        ),
      );

      final outputFile = await _createOutputFile(excelFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;

    } catch (e) {
      throw Exception('Excel to PDF conversion failed: ${e.toString()}');
    }
  }

  Future<File> powerPointToPdf(File pptFile) async {
    try {
      String textContent = '';
      try {
        final bytes = await pptFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        final slideFiles = archive.files.where((f) => f.name.startsWith('ppt/slides/slide') && f.name.endsWith('.xml')).toList();
        slideFiles.sort((a,b) => a.name.compareTo(b.name));
        
        for(var strFile in slideFiles) {
           final content = utf8.decode(strFile.content);
           final xmlDoc = XmlDocument.parse(content);
           final slideText = xmlDoc.findAllElements('a:t').map((n) => n.innerText).join(' ');
           if (slideText.isNotEmpty) {
             textContent += 'Slide: $slideText\n\n';
           }
        }
      } catch (e) {
         debugPrint('Failed to parse pptx: $e');
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [pw.Text(textContent.isNotEmpty ? textContent : "Could not parse PowerPoint content.", style: const pw.TextStyle(fontSize: 12))],
        ),
      );

      final outputFile = await _createOutputFile(pptFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;
    } catch (e) {
      throw Exception('PowerPoint to PDF conversion failed: ${e.toString()}');
    }
  }

  Future<File> textToPdf(File textFile) async {
    try {
      final content = await textFile.readAsString();
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [pw.Text(content, style: const pw.TextStyle(fontSize: 12))],
        ),
      );
      final outputFile = await _createOutputFile(textFile, 'pdf');
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;
    } catch (e) {
      throw Exception('Text to PDF conversion failed: ${e.toString()}');
    }
  }

  Future<File> pdfToHtml(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      final text = textExtractor.extractText();
      
      final outputFile = await _createOutputFile(pdfFile, 'html');
      final html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Converted PDF</title>
<style>body { font-family: sans-serif; padding: 20px; white-space: pre-wrap; }</style>
</head>
<body>
${text.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}
</body>
</html>
''';
      await outputFile.writeAsString(html);
      document.dispose();
      return outputFile;
    } catch (e) {
      throw Exception('PDF to HTML conversion failed: ${e.toString()}');
    }
  }

  Future<File> pdfToEpub(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);
      final text = textExtractor.extractText();
      
      final outputFile = await _createOutputFile(pdfFile, 'epub');
      await outputFile.writeAsString(text); 
      
      document.dispose();
      return outputFile;
    } catch (e) {
      throw Exception('PDF to EPUB conversion failed: ${e.toString()}');
    }
  }

  /// Merge multiple PDF files into one
  Future<File> mergePdfs(List<File> pdfFiles) async {
    try {
      final syncfusion.PdfDocument outputDocument = syncfusion.PdfDocument();
      
      for (final file in pdfFiles) {
        final bytes = await file.readAsBytes();
        final syncfusion.PdfDocument inputDocument = syncfusion.PdfDocument(inputBytes: bytes);
        for (int i = 0; i < inputDocument.pages.count; i++) {
          outputDocument.pages.add().graphics.drawPdfTemplate(
            inputDocument.pages[i].createTemplate(),
            const Offset(0, 0),
          );
        }
        inputDocument.dispose();
      }
      
      final List<int> outputBytes = await outputDocument.save();
      outputDocument.dispose();
      
      final outputFile = await _createOutputFile(pdfFiles.first, 'pdf');
      await outputFile.writeAsBytes(outputBytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Merge PDF failed: ${e.toString()}');
    }
  }

  /// Create output file with new extension
  Future<File> _createOutputFile(File inputFile, String newExtension) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = inputFile.path.split(Platform.pathSeparator).last;
    final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/${nameWithoutExt}_converted_$timestamp.$newExtension';
    return File(outputPath);
  }

  /// Get file size as formatted string
  String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
