/// Enum representing different conversion types supported by the app
enum ConversionType {
  // From PDF conversions
  pdfToWord,
  pdfToExcel,
  pdfToPowerPoint,
  pdfToImage,
  pdfToText,
  pdfToHtml,
  pdfToEpub,
  
  // To PDF conversions
  imageToPdf,
  wordToPdf,
  excelToPdf,
  powerPointToPdf,
  textToPdf,
  mergePdf,
}

/// Enum representing the current status of a conversion
enum ConversionStatus {
  idle,
  uploading,
  converting,
  completed,
  error,
}

/// Enum representing image formats for PDF to Image conversion
enum ImageFormat {
  png,
  jpg,
  jpeg,
  webp,
}

/// Extension methods for ConversionType enum
extension ConversionTypeExtension on ConversionType {
  /// Get display name for the conversion type
  String get displayName {
    switch (this) {
      case ConversionType.pdfToWord:
        return 'PDF to Word';
      case ConversionType.pdfToExcel:
        return 'PDF to Excel';
      case ConversionType.pdfToPowerPoint:
        return 'PDF to PowerPoint';
      case ConversionType.pdfToImage:
        return 'PDF to Image';
      case ConversionType.pdfToText:
        return 'PDF to Text';
      case ConversionType.pdfToHtml:
        return 'PDF to HTML';
      case ConversionType.pdfToEpub:
        return 'PDF to EPUB';
      case ConversionType.imageToPdf:
        return 'Image to PDF';
      case ConversionType.wordToPdf:
        return 'Word to PDF';
      case ConversionType.excelToPdf:
        return 'Excel to PDF';
      case ConversionType.powerPointToPdf:
        return 'PowerPoint to PDF';
      case ConversionType.textToPdf:
        return 'Text to PDF';
      case ConversionType.mergePdf:
        return 'Merge PDF';
    }
  }

  /// Get description for the conversion type
  String get description {
    switch (this) {
      case ConversionType.pdfToWord:
        return 'Convert PDF to editable Word document';
      case ConversionType.pdfToExcel:
        return 'Extract tables and data to Excel';
      case ConversionType.pdfToPowerPoint:
        return 'Convert PDF to presentation';
      case ConversionType.pdfToImage:
        return 'Convert PDF pages to images';
      case ConversionType.pdfToText:
        return 'Extract text from PDF';
      case ConversionType.pdfToHtml:
        return 'Convert PDF to web page';
      case ConversionType.pdfToEpub:
        return 'Convert PDF to eBook format';
      case ConversionType.imageToPdf:
        return 'Convert images to PDF document';
      case ConversionType.wordToPdf:
        return 'Convert Word document to PDF';
      case ConversionType.excelToPdf:
        return 'Convert Excel spreadsheet to PDF';
      case ConversionType.powerPointToPdf:
        return 'Convert presentation to PDF';
      case ConversionType.textToPdf:
        return 'Convert text file to PDF';
      case ConversionType.mergePdf:
        return 'Combine multiple PDF files into one';
    }
  }

  /// Get supported input file extensions
  List<String> get supportedInputFormats {
    switch (this) {
      case ConversionType.pdfToWord:
      case ConversionType.pdfToExcel:
      case ConversionType.pdfToPowerPoint:
      case ConversionType.pdfToImage:
      case ConversionType.pdfToText:
      case ConversionType.pdfToHtml:
      case ConversionType.pdfToEpub:
        return ['pdf'];
      case ConversionType.imageToPdf:
        return ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'];
      case ConversionType.wordToPdf:
        return ['doc', 'docx'];
      case ConversionType.excelToPdf:
        return ['xls', 'xlsx'];
      case ConversionType.powerPointToPdf:
        return ['ppt', 'pptx'];
      case ConversionType.textToPdf:
        return ['txt'];
      case ConversionType.mergePdf:
        return ['pdf'];
    }
  }

  /// Get output file extension
  String get outputFormat {
    switch (this) {
      case ConversionType.pdfToWord:
        return 'docx';
      case ConversionType.pdfToExcel:
        return 'xlsx';
      case ConversionType.pdfToPowerPoint:
        return 'pptx';
      case ConversionType.pdfToImage:
        return 'png';
      case ConversionType.pdfToText:
        return 'txt';
      case ConversionType.pdfToHtml:
        return 'html';
      case ConversionType.pdfToEpub:
        return 'epub';
      case ConversionType.imageToPdf:
      case ConversionType.wordToPdf:
      case ConversionType.excelToPdf:
      case ConversionType.powerPointToPdf:
      case ConversionType.textToPdf:
      case ConversionType.mergePdf:
        return 'pdf';
    }
  }

  /// Check if this is a "From PDF" conversion
  bool get isFromPdf {
    return this == ConversionType.pdfToWord ||
        this == ConversionType.pdfToExcel ||
        this == ConversionType.pdfToPowerPoint ||
        this == ConversionType.pdfToImage ||
        this == ConversionType.pdfToText ||
        this == ConversionType.pdfToHtml ||
        this == ConversionType.pdfToEpub;
  }

  /// Check if this is a "To PDF" conversion
  bool get isToPdf {
    return !isFromPdf;
  }
}

/// Extension methods for ConversionStatus enum
extension ConversionStatusExtension on ConversionStatus {
  /// Get display name for the conversion status
  String get displayName {
    switch (this) {
      case ConversionStatus.idle:
        return 'Ready';
      case ConversionStatus.uploading:
        return 'Uploading';
      case ConversionStatus.converting:
        return 'Converting';
      case ConversionStatus.completed:
        return 'Completed';
      case ConversionStatus.error:
        return 'Error';
    }
  }

  /// Check if conversion is in progress
  bool get isInProgress {
    return this == ConversionStatus.uploading ||
        this == ConversionStatus.converting;
  }

  /// Check if conversion is complete
  bool get isComplete {
    return this == ConversionStatus.completed;
  }

  /// Check if there's an error
  bool get hasError {
    return this == ConversionStatus.error;
  }

  /// Check if idle
  bool get isIdle {
    return this == ConversionStatus.idle;
  }
}

/// Extension methods for ImageFormat enum
extension ImageFormatExtension on ImageFormat {
  /// Get file extension for the image format
  String get extension {
    switch (this) {
      case ImageFormat.png:
        return 'png';
      case ImageFormat.jpg:
      case ImageFormat.jpeg:
        return 'jpg';
      case ImageFormat.webp:
        return 'webp';
    }
  }

  /// Get MIME type for the image format
  String get mimeType {
    switch (this) {
      case ImageFormat.png:
        return 'image/png';
      case ImageFormat.jpg:
      case ImageFormat.jpeg:
        return 'image/jpeg';
      case ImageFormat.webp:
        return 'image/webp';
    }
  }
}
