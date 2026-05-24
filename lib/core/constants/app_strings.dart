/// App-wide string constants
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Information
  static const String appName = 'PDF Tools Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional PDF conversion and management tools';
  
  // Home Screen
  static const String homeTitle = 'PDF Tools Pro';
  static const String welcomeMessage = 'Welcome to PDF Tools';
  static const String welcomeSubtitle = 'Convert your files with ease';
  static const String searchHint = 'Search tools...';
  
  // Tool Categories
  static const String categoryFromPdf = 'From PDF';
  static const String categoryFromPdfDesc = 'Convert PDF files to other formats';
  static const String categoryToPdf = 'To PDF';
  static const String categoryToPdfDesc = 'Convert files to PDF format';
  
  // Tool Names - From PDF
  static const String pdfToWord = 'PDF to Word';
  static const String pdfToWordDesc = 'Convert PDF to editable Word document';
  static const String pdfToExcel = 'PDF to Excel';
  static const String pdfToExcelDesc = 'Extract tables and data to Excel';
  static const String pdfToPowerPoint = 'PDF to PowerPoint';
  static const String pdfToPowerPointDesc = 'Convert PDF to presentation';
  static const String pdfToImage = 'PDF to Image';
  static const String pdfToImageDesc = 'Convert PDF pages to images';
  static const String pdfToText = 'PDF to Text';
  static const String pdfToTextDesc = 'Extract text from PDF';
  static const String pdfToHtml = 'PDF to HTML';
  static const String pdfToHtmlDesc = 'Convert PDF to web page';
  static const String pdfToEpub = 'PDF to EPUB';
  static const String pdfToEpubDesc = 'Convert PDF to eBook format';
  
  // Tool Names - To PDF
  static const String imageToPdf = 'Image to PDF';
  static const String imageToPdfDesc = 'Convert images to PDF document';
  static const String wordToPdf = 'Word to PDF';
  static const String wordToPdfDesc = 'Convert Word document to PDF';
  static const String excelToPdf = 'Excel to PDF';
  static const String excelToPdfDesc = 'Convert Excel spreadsheet to PDF';
  static const String powerPointToPdf = 'PowerPoint to PDF';
  static const String powerPointToPdfDesc = 'Convert presentation to PDF';
  static const String textToPdf = 'Text to PDF';
  static const String textToPdfDesc = 'Convert text file to PDF';
  
  // Button Labels
  static const String uploadFile = 'Upload File';
  static const String selectFile = 'Select File';
  static const String convert = 'Convert';
  static const String converting = 'Converting...';
  static const String download = 'Download';
  static const String downloading = 'Downloading...';
  static const String share = 'Share';
  static const String open = 'Open';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String changeFile = 'Change File';
  static const String convertAnother = 'Convert Another';
  static const String back = 'Back';
  static const String settings = 'Settings';
  static const String about = 'About';
  static const String help = 'Help';
  
  // Status Messages
  static const String uploadingFile = 'Uploading file...';
  static const String preparingFiles = 'Preparing your files...';
  static const String validatingFiles = 'Validating selected files...';
  static const String convertingFile = 'Converting file...';
  static const String conversionComplete = 'Conversion completed successfully!';
  static const String conversionFailed = 'Conversion failed';
  static const String downloadComplete = 'File downloaded successfully';
  static const String downloadFailed = 'Download failed';
  static const String fileShared = 'File shared successfully';
  static const String fileOpened = 'Opening file...';
  
  // Error Messages
  static const String errorFileNotFound = 'File not found';
  static const String errorInvalidFormat = 'Invalid file format';
  static const String errorFileTooLarge = 'File size exceeds maximum limit (50MB)';
  static const String errorConversionFailed = 'Conversion failed. Please try again.';
  static const String errorNoStoragePermission = 'Storage permission denied';
  static const String errorNetworkError = 'Network error. Please check your connection.';
  static const String errorOutOfMemory = 'Insufficient memory to process file';
  static const String errorUnknown = 'An unexpected error occurred';
  static const String errorNoFileSelected = 'No file selected';
  
  // Validation Messages
  static const String validationSelectFile = 'Please select a file first';
  static const String validationInvalidFile = 'Please select a valid file';
  static const String validationFileTooLarge = 'File size must be less than 50MB';
  
  // Empty State Messages
  static const String emptyStateTitle = 'No file selected';
  static const String emptyStateMessage = 'Select a file to get started';
  static const String emptyStateAction = 'Browse Files';
  static const String noRecentConversions = 'No recent conversions';
  static const String noFavorites = 'No favorite tools yet';
  
  // File Upload Widget
  static const String dragDropHint = 'Drag and drop file here';
  static const String orText = 'or';
  static const String clickToBrowse = 'Click to browse';
  static const String supportedFormats = 'Supported formats';
  static const String maxFileSize = 'Max file size: 50MB';
  static const String fileSelected = 'File selected';
  static const String removeFile = 'Remove file';
  
  // Conversion Steps
  static const String step1Upload = 'Upload';
  static const String step2Convert = 'Convert';
  static const String step3Download = 'Download';
  
  // File Info
  static const String fileName = 'File name';
  static const String fileSize = 'File size';
  static const String fileType = 'File type';
  static const String fileDate = 'Date modified';
  static const String pages = 'Pages';
  
  // Tips and Info
  static const String tipQuality = 'Tip: Higher quality means larger file size';
  static const String tipBatch = 'Tip: You can convert multiple files at once';
  static const String tipSecurity = 'Your files are processed locally and securely';
  static const String infoProcessingTime = 'Processing time depends on file size';
  
  // Settings
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'Theme';
  static const String settingsLanguage = 'Language';
  static const String settingsQuality = 'Default Quality';
  static const String settingsStorage = 'Storage Location';
  
  // About
  static const String aboutTitle = 'About';
  static const String aboutVersion = 'Version';
  static const String aboutDeveloper = 'Developed by';
  static const String aboutLicense = 'License';
  static const String aboutPrivacy = 'Privacy Policy';
  static const String aboutTerms = 'Terms of Service';
  
  // Footer
  static const String footerCopyright = '© 2024 PDF Tools Pro';
  static const String footerAllRights = 'All rights reserved';
  
  // Permissions
  static const String permissionStorageTitle = 'Storage Permission Required';
  static const String permissionStorageMessage = 'This app needs storage permission to save converted files';
  static const String permissionGranted = 'Permission granted';
  static const String permissionDenied = 'Permission denied';
  
  // Loading Messages
  static const String loadingPleaseWait = 'Please wait...';
  static const String loadingProcessing = 'Processing your file...';
  static const String loadingAlmostDone = 'Almost done...';
  
  // Success Messages
  static const String successTitle = 'Success!';
  static const String successMessage = 'Your file has been converted successfully';
  
  // Popular Badge
  static const String popularBadge = 'Popular';
  static const String newBadge = 'New';
  static const String proBadge = 'Pro';
  
  // Batch Conversion
  static const String selectMultipleFiles = 'Select Multiple Files';
  static const String convertBatch = 'Convert Batch';
  static const String batchProgress = 'Batch Progress';
  static const String filesInQueue = 'files in queue';
  static const String clearBatch = 'Clear Batch';
}
