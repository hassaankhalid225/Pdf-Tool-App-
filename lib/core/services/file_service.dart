import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling file operations
class FileService {
  /// Pick a file with specified extensions
  Future<File?> pickFile(List<String> extensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick file: ${e.toString()}');
    }
  }

  /// Pick multiple files with specified extensions
  Future<List<File>> pickFiles(List<String> extensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: true,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to pick files: ${e.toString()}');
    }
  }

  /// Save file to downloads directory
  Future<void> saveFile(File file, String fileName) async {
    try {
      // Get downloads directory
      final directory = await getDownloadPath();
      
      // Create destination path
      final destinationPath = '$directory/$fileName';
      
      // Copy file to downloads
      await file.copy(destinationPath);
    } catch (e) {
      throw Exception('Failed to save file: ${e.toString()}');
    }
  }

  /// Share file using platform share sheet
  Future<void> shareFile(File file) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(file.path)],
      );

      if (result.status == ShareResultStatus.unavailable) {
        throw Exception('Sharing is not available on this platform');
      }
    } catch (e) {
      throw Exception('Failed to share file: ${e.toString()}');
    }
  }

  /// Open file with default application
  Future<void> openFile(File file) async {
    try {
      final result = await OpenFile.open(file.path);
      
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      throw Exception('Failed to open file: ${e.toString()}');
    }
  }

  /// Delete a file
  Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  /// Get download directory path
  Future<String> getDownloadPath() async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, use external storage directory
        directory = await getExternalStorageDirectory();
        
        // Navigate to Downloads folder
        if (directory != null) {
          final downloadPath = directory.path.replaceAll('Android/data/com.example.pdf_tool/files', 'Download');
          final downloadDir = Directory(downloadPath);
          
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          
          return downloadPath;
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms, use downloads directory
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find download directory');
      }

      return directory.path;
    } catch (e) {
      throw Exception('Failed to get download path: ${e.toString()}');
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      throw Exception('Failed to get file size: ${e.toString()}');
    }
  }

  /// Get file extension
  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// Get file name without extension
  String getFileNameWithoutExtension(File file) {
    final fileName = file.path.split('/').last;
    return fileName.substring(0, fileName.lastIndexOf('.'));
  }

  /// Get file name with extension
  String getFileName(File file) {
    return file.path.split('/').last;
  }

  /// Check if file exists
  Future<bool> fileExists(File file) async {
    return await file.exists();
  }

  /// Get file modified date
  Future<DateTime> getFileModifiedDate(File file) async {
    try {
      final stat = await file.stat();
      return stat.modified;
    } catch (e) {
      throw Exception('Failed to get file modified date: ${e.toString()}');
    }
  }

  /// Format file size to human-readable string
  String formatFileSize(int bytes) {
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

  /// Create temporary file
  Future<File> createTempFile(String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      return File(filePath);
    } catch (e) {
      throw Exception('Failed to create temp file: ${e.toString()}');
    }
  }

  /// Get application documents directory
  Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }
}
