import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/core/services/conversion_service.dart';
import 'package:pdf_tool/core/services/file_service.dart';
import 'package:pdf_tool/core/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provider for managing conversion state and operations
class ConversionProvider extends ChangeNotifier {
  final ConversionService _conversionService;
  final FileService _fileService;
  final PermissionService _permissionService;

  ConversionProvider({
    required ConversionService conversionService,
    required FileService fileService,
    required PermissionService permissionService,
  })  : _conversionService = conversionService,
        _fileService = fileService,
        _permissionService = permissionService {
    _loadHistory();
  }

  // State variables
  ConversionModel? _currentConversion;
  final List<ConversionModel> _batchConversions = [];
  final List<ConversionModel> _conversionHistory = [];
  bool _isProcessing = false;

  // Getters
  ConversionModel? get currentConversion => _currentConversion;
  List<ConversionModel> get batchConversions => List.unmodifiable(_batchConversions);
  List<ConversionModel> get conversionHistory => List.unmodifiable(_conversionHistory);
  bool get isProcessing => _isProcessing;
  bool get isBatchProcessing => _batchConversions.isNotEmpty;
  
  ConversionStatus get status => _currentConversion?.status ?? ConversionStatus.idle;
  File? get selectedFile => _currentConversion?.inputFile;
  File? get resultFile => _currentConversion?.outputFile;
  double get progress => _currentConversion?.progress ?? 0.0;
  String? get errorMessage => _currentConversion?.errorMessage;
  bool get hasFile => _currentConversion?.inputFile != null || _batchConversions.isNotEmpty;
  bool get hasResult => _currentConversion?.outputFile != null || _batchConversions.any((c) => c.outputFile != null);

  /// Select a file for conversion
  Future<bool> selectFile(List<String> extensions, ConversionType type) async {
    try {
      final file = await _fileService.pickFile(extensions);
      
      if (file != null) {
        // Validate file
        final isValid = await _conversionService.validateFile(file, extensions);
        
        if (!isValid) {
          _setError('Invalid file format. Please select a valid file.');
          return false;
        }

        // Create new conversion model
        _currentConversion = ConversionModel(
          id: const Uuid().v4(),
          type: type,
          inputFile: file,
          status: ConversionStatus.idle,
          startTime: DateTime.now(),
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to select file: ${e.toString()}');
      return false;
    }
  }

  /// Convert the selected file
  Future<void> convertFile(ConversionType type, {String quality = 'high'}) async {
    if (_currentConversion == null) {
      _setError('No file selected');
      return;
    }

    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    
    try {
      // Update conversion type and status
      _currentConversion = _currentConversion!.copyWith(
        type: type,
        status: ConversionStatus.converting,
        progress: 0.0,
      );
      notifyListeners();

      // Simulate progress updates
      _updateProgress(0.2);
      await Future.delayed(const Duration(milliseconds: 500));

      // Perform conversion based on type
      File? outputFile;
      
      switch (type) {
        case ConversionType.pdfToWord:
          outputFile = await _conversionService.pdfToWord(_currentConversion!.inputFile);
          break;
        case ConversionType.pdfToExcel:
          outputFile = await _conversionService.pdfToExcel(_currentConversion!.inputFile);
          break;
        case ConversionType.pdfToImage:
          outputFile = await _conversionService.pdfToImage(
            _currentConversion!.inputFile,
            ImageFormat.png,
            quality: quality,
          );
          break;
        case ConversionType.pdfToText:
          outputFile = await _conversionService.pdfToText(_currentConversion!.inputFile);
          break;
        case ConversionType.imageToPdf:
          outputFile = await _conversionService.imageToPdf(
            _currentConversion!.inputFile,
            quality: quality,
          );
          break;
        case ConversionType.wordToPdf:
          outputFile = await _conversionService.wordToPdf(_currentConversion!.inputFile);
          break;
        default:
          throw UnimplementedError('Conversion type ${type.displayName} not yet implemented');
      }

      _updateProgress(0.8);
      await Future.delayed(const Duration(milliseconds: 300));

      // Update conversion with result
      _currentConversion = _currentConversion!.copyWith(
        outputFile: outputFile,
        status: ConversionStatus.completed,
        progress: 1.0,
        endTime: DateTime.now(),
      );

      // Add to history
      _conversionHistory.insert(0, _currentConversion!);
      _saveHistory();
      
      notifyListeners();
    } catch (e) {
      _setError('Conversion failed: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// Download the converted file
  Future<void> downloadFile() async {
    if (_currentConversion?.outputFile == null) {
      _setError('No file to download');
      return;
    }

    try {
      final fileName = _currentConversion!.outputFileName ?? 'converted_file';
      await _fileService.saveFile(_currentConversion!.outputFile!, fileName);
    } catch (e) {
      _setError('Failed to download file: ${e.toString()}');
    }
  }

  /// Share the converted file
  Future<void> shareFile() async {
    if (_currentConversion?.outputFile == null) {
      _setError('No file to share');
      return;
    }

    try {
      await _fileService.shareFile(_currentConversion!.outputFile!);
    } catch (e) {
      _setError('Failed to share file: ${e.toString()}');
    }
  }

  /// Download a specific conversion model result
  Future<void> downloadFileModel(ConversionModel model) async {
    if (model.outputFile == null) return;
    try {
      final fileName = model.outputFileName ?? 'converted_file';
      await _fileService.saveFile(model.outputFile!, fileName);
    } catch (e) {
      debugPrint('Failed to download individual file: $e');
    }
  }

  /// Open the converted file
  Future<void> openFile() async {
    if (_currentConversion?.outputFile == null) {
      _setError('No file to open');
      return;
    }

    try {
      await _fileService.openFile(_currentConversion!.outputFile!);
    } catch (e) {
      _setError('Failed to open file: ${e.toString()}');
    }
  }

  /// Reset the conversion state
  void reset() {
    _currentConversion = null;
    _isProcessing = false;
    notifyListeners();
  }

  /// Remove a file from the current conversion
  void removeFile() {
    if (_currentConversion != null) {
      _currentConversion = null;
      notifyListeners();
    }
  }

  /// Clear conversion history
  void clearHistory() {
    _conversionHistory.clear();
    _saveHistory();
    notifyListeners();
  }

  /// Remove a specific conversion from history
  void removeFromHistory(String conversionId) {
    _conversionHistory.removeWhere((c) => c.id == conversionId);
    _saveHistory();
    notifyListeners();
  }

  /// Update progress
  void _updateProgress(double progress) {
    if (_currentConversion != null) {
      _currentConversion = _currentConversion!.copyWith(progress: progress);
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String message) {
    if (_currentConversion != null) {
      _currentConversion = _currentConversion!.copyWith(
        status: ConversionStatus.error,
        errorMessage: message,
        endTime: DateTime.now(),
      );
    }
    _isProcessing = false;
    notifyListeners();
  }

  /// Retry failed conversion
  Future<void> retryConversion() async {
    if (_currentConversion == null) return;
    
    final type = _currentConversion!.type;
    _currentConversion = _currentConversion!.copyWith(
      status: ConversionStatus.idle,
      errorMessage: null,
      progress: 0.0,
    );
    notifyListeners();
    
    await convertFile(type);
  }

  /// Select multiple files for batch conversion
  Future<bool> selectFiles(List<String> extensions, ConversionType type) async {
    try {
      final files = await _fileService.pickFiles(extensions);
      
      if (files.isNotEmpty) {
        _batchConversions.clear();

        // If only one file is selected, treat it as a single conversion
        if (files.length == 1) {
          _currentConversion = ConversionModel(
            id: const Uuid().v4(),
            type: type,
            inputFile: files.first,
            status: ConversionStatus.idle,
            startTime: DateTime.now(),
          );
          notifyListeners();
          return true;
        }

        // Multiple files - use batch mode
        _currentConversion = null;
        for (var file in files) {
          _batchConversions.add(ConversionModel(
            id: const Uuid().v4(),
            type: type,
            inputFile: file,
            status: ConversionStatus.idle,
            startTime: DateTime.now(),
          ));
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to select files: ${e.toString()}');
      return false;
    }
  }

  /// Add more files to the current batch
  Future<void> addMoreFiles(List<String> extensions, ConversionType type) async {
    try {
      // If there's a single conversion already, move it to batch
      if (_currentConversion != null) {
        final exists = _batchConversions.any((c) => c.inputFile.path == _currentConversion!.inputFile.path);
        if (!exists) {
          _batchConversions.add(_currentConversion!);
        }
        _currentConversion = null;
      }

      final files = await _fileService.pickFiles(extensions);
      
      if (files.isNotEmpty) {
        for (var file in files) {
          // Check if file is already in batch
          final exists = _batchConversions.any((c) => c.inputFile.path == file.path);
          if (!exists) {
            _batchConversions.add(ConversionModel(
              id: const Uuid().v4(),
              type: type,
              inputFile: file,
              status: ConversionStatus.idle,
              startTime: DateTime.now(),
            ));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add more files: ${e.toString()}');
    }
  }

  /// Remove a file from the batch
  void removeFromBatch(int index) {
    if (index >= 0 && index < _batchConversions.length) {
      _batchConversions.removeAt(index);
      notifyListeners();
    }
  }

  /// Convert multiple files in a batch
  Future<void> convertBatch(ConversionType type, {String quality = 'high'}) async {
    if (_batchConversions.isEmpty) {
      _setError('No files selected for batch conversion');
      return;
    }

    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    try {
      // Handle Merge PDF specially (merge all into one)
      if (type == ConversionType.mergePdf) {
        final pdfFiles = _batchConversions.map((c) => c.inputFile).toList();
        final outputFile = await _conversionService.mergePdfs(pdfFiles);
        
        // Mark all as completed with the same output file?
        // Or create a new "Result" model. For now, mark them all.
        for (int i = 0; i < _batchConversions.length; i++) {
          _batchConversions[i] = _batchConversions[i].copyWith(
            outputFile: outputFile,
            status: ConversionStatus.completed,
            progress: 1.0,
            endTime: DateTime.now(),
          );
        }
        notifyListeners();
        return;
      }

      for (int i = 0; i < _batchConversions.length; i++) {
        var conversion = _batchConversions[i];
        
        // Update status to converting
        _batchConversions[i] = conversion.copyWith(
          type: type,
          status: ConversionStatus.converting,
          progress: 0.1,
        );
        notifyListeners();

        try {
          // Perform conversion
          final outputFile = await _performConversion(
            type, 
            conversion.inputFile,
            quality: quality,
          );
          
          // Update status to completed
          _batchConversions[i] = _batchConversions[i].copyWith(
            outputFile: outputFile,
            status: ConversionStatus.completed,
            progress: 1.0,
            endTime: DateTime.now(),
          );
          
          // Add to history
          _conversionHistory.insert(0, _batchConversions[i]);
          _saveHistory();
        } catch (e) {
          // Update status to error
          _batchConversions[i] = _batchConversions[i].copyWith(
            status: ConversionStatus.error,
            errorMessage: e.toString(),
            endTime: DateTime.now(),
          );
        }
        notifyListeners();
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Helper to perform actual conversion logic
  Future<File?> _performConversion(
    ConversionType type, 
    File inputFile, {
    String quality = 'high',
  }) async {
    switch (type) {
      case ConversionType.pdfToWord:
        return await _conversionService.pdfToWord(inputFile);
      case ConversionType.pdfToExcel:
        return await _conversionService.pdfToExcel(inputFile);
      case ConversionType.pdfToImage:
        return await _conversionService.pdfToImage(
          inputFile, 
          ImageFormat.png,
          quality: quality,
        );
      case ConversionType.pdfToText:
        return await _conversionService.pdfToText(inputFile);
      case ConversionType.imageToPdf:
        return await _conversionService.imageToPdf(
          inputFile,
          quality: quality,
        );
      case ConversionType.wordToPdf:
        return await _conversionService.wordToPdf(inputFile);
      case ConversionType.textToPdf:
        return await _conversionService.textToPdf(inputFile);
      case ConversionType.pdfToPowerPoint:
        return await _conversionService.pdfToPowerPoint(inputFile);
      case ConversionType.pdfToHtml:
        return await _conversionService.pdfToHtml(inputFile);
      case ConversionType.pdfToEpub:
        return await _conversionService.pdfToEpub(inputFile);
      case ConversionType.excelToPdf:
        return await _conversionService.excelToPdf(inputFile);
      case ConversionType.powerPointToPdf:
        return await _conversionService.powerPointToPdf(inputFile);
      case ConversionType.mergePdf:
        // Merge is handled separately in convertBatch, but for single file it's just the file itself
        return inputFile;
      default:
        throw UnimplementedError('Conversion for ${type.displayName} not implemented yet');
    }
  }

  @override
  void dispose() {
    _currentConversion = null;
    _batchConversions.clear();
    _conversionHistory.clear();
    super.dispose();
  }

  /// Load history from storage
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString('conversion_history');
      if (historyStr != null) {
        final List<dynamic> jsonList = jsonDecode(historyStr);
        _conversionHistory.clear();
        _conversionHistory.addAll(
          jsonList.map((j) => ConversionModel.fromJson(j)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = jsonEncode(
        _conversionHistory.map((c) => c.toJson()).toList(),
      );
      await prefs.setString('conversion_history', historyStr);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
