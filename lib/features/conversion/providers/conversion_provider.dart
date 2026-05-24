import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/core/services/conversion_service.dart';
import 'package:pdf_tool/core/services/file_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provider for managing conversion state and operations.
/// All tools use the same batch queue: one or many files, one flow.
class ConversionProvider extends ChangeNotifier {
  final ConversionService _conversionService;
  final FileService _fileService;

  ConversionProvider({
    required ConversionService conversionService,
    required FileService fileService,
  })  : _conversionService = conversionService,
        _fileService = fileService {
    _loadHistory();
  }

  final List<ConversionModel> _batchConversions = [];
  final List<ConversionModel> _conversionHistory = [];
  bool _isProcessing = false;
  bool _isSelectingFiles = false;
  String? _loadingMessage;
  String? _globalErrorMessage;

  List<ConversionModel> get batchConversions => List.unmodifiable(_batchConversions);
  List<ConversionModel> get conversionHistory => List.unmodifiable(_conversionHistory);
  bool get isProcessing => _isProcessing;
  bool get isSelectingFiles => _isSelectingFiles;
  bool get isLoading => _isSelectingFiles || _isProcessing;
  String? get loadingMessage => _loadingMessage;
  bool get hasFile => _batchConversions.isNotEmpty;
  bool get hasResult => _batchConversions.any((c) => c.outputFile != null);
  String? get globalErrorMessage => _globalErrorMessage;

  /// Kept for compatibility — same as [hasFile].
  bool get isBatchProcessing => hasFile;

  ConversionStatus get status {
    if (_batchConversions.isEmpty) return ConversionStatus.idle;
    if (_batchConversions.any((c) => c.status == ConversionStatus.converting)) {
      return ConversionStatus.converting;
    }
    if (_batchConversions.every((c) => c.status == ConversionStatus.completed)) {
      return ConversionStatus.completed;
    }
    if (_batchConversions.any((c) => c.status == ConversionStatus.error)) {
      return ConversionStatus.error;
    }
    return ConversionStatus.idle;
  }

  double get progress {
    if (_batchConversions.isEmpty) return 0.0;
    final total = _batchConversions.fold<double>(0, (sum, c) => sum + c.progress);
    return total / _batchConversions.length;
  }

  String? get errorMessage {
    if (_globalErrorMessage != null) return _globalErrorMessage;
    try {
      return _batchConversions.firstWhere((c) => c.errorMessage != null).errorMessage;
    } catch (_) {
      return null;
    }
  }

  int get completedCount =>
      _batchConversions.where((c) => c.status == ConversionStatus.completed).length;

  bool get isAllComplete =>
      _batchConversions.isNotEmpty &&
      _batchConversions.every((c) => c.status == ConversionStatus.completed);

  /// Pick one file and add to the queue (same flow as multiple).
  Future<bool> selectFile(List<String> extensions, ConversionType type) async {
    return selectFiles(extensions, type);
  }

  /// Pick one or more files — always uses the shared batch queue.
  Future<bool> selectFiles(List<String> extensions, ConversionType type) async {
    if (_isSelectingFiles || _isProcessing) return false;

    try {
      _globalErrorMessage = null;
      _isSelectingFiles = true;
      _loadingMessage = AppStrings.preparingFiles;
      notifyListeners();

      final files = await _fileService.pickFiles(extensions);
      if (files.isEmpty) {
        _clearLoading();
        notifyListeners();
        return false;
      }

      _batchConversions.clear();
      _loadingMessage = AppStrings.validatingFiles;
      notifyListeners();

      await _addFilesToBatch(files, type, onProgress: (current, total) {
        _loadingMessage = '${AppStrings.validatingFiles} ($current/$total)';
        notifyListeners();
      });

      _clearLoading();

      if (_batchConversions.isEmpty) {
        _globalErrorMessage = 'No valid files selected. Check format and size (max 50 MB).';
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _clearLoading();
      _globalErrorMessage = 'Failed to select files: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Add more files to the current queue.
  Future<void> addMoreFiles(List<String> extensions, ConversionType type) async {
    if (_isSelectingFiles || _isProcessing) return;

    try {
      _globalErrorMessage = null;
      _isSelectingFiles = true;
      _loadingMessage = AppStrings.preparingFiles;
      notifyListeners();

      final files = await _fileService.pickFiles(extensions);
      if (files.isNotEmpty) {
        _loadingMessage = AppStrings.validatingFiles;
        notifyListeners();
        await _addFilesToBatch(files, type, onProgress: (current, total) {
          _loadingMessage = '${AppStrings.validatingFiles} ($current/$total)';
          notifyListeners();
        });
      }
      _clearLoading();
      notifyListeners();
    } catch (e) {
      _clearLoading();
      _globalErrorMessage = 'Failed to add files: ${e.toString()}';
      notifyListeners();
    }
  }

  void _clearLoading() {
    _isSelectingFiles = false;
    _loadingMessage = null;
  }

  Future<void> _addFilesToBatch(
    List<File> files,
    ConversionType type, {
    void Function(int current, int total)? onProgress,
  }) async {
    final extensions = type.supportedInputFormats;
    final total = files.length;

    for (var i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, total);
      final file = files[i];
      final exists = _batchConversions.any((c) => c.inputFile.path == file.path);
      if (exists) continue;

      final isValid = await _conversionService.validateFile(file, extensions);
      if (!isValid) continue;

      _batchConversions.add(ConversionModel(
        id: const Uuid().v4(),
        type: type,
        inputFile: file,
        status: ConversionStatus.idle,
        startTime: DateTime.now(),
      ));
    }
  }

  /// Convert all queued files (1 or many) — single entry point for every tool.
  Future<void> convertAll(ConversionType type, {String quality = 'high'}) async {
    await convertBatch(type, quality: quality);
  }

  /// Alias kept for existing call sites.
  Future<void> convertFile(ConversionType type, {String quality = 'high'}) async {
    await convertAll(type, quality: quality);
  }

  Future<void> convertBatch(ConversionType type, {String quality = 'high'}) async {
    if (_batchConversions.isEmpty) {
      _globalErrorMessage = 'No files selected. Please upload file(s) first.';
      notifyListeners();
      return;
    }

    if (type == ConversionType.mergePdf && _batchConversions.length < 2) {
      _globalErrorMessage = 'Select at least 2 PDF files to merge.';
      notifyListeners();
      return;
    }

    if (_isProcessing) return;
    _isProcessing = true;
    _globalErrorMessage = null;
    _loadingMessage = AppStrings.convertingFile;
    notifyListeners();

    try {
      if (type == ConversionType.mergePdf) {
        _loadingMessage = 'Merging ${_batchConversions.length} PDF files...';
        notifyListeners();
        await _mergeBatch(type);
        return;
      }

      // When the user picks several images, treat the batch as a single
      // multi-page PDF so the output matches what professional tools do.
      if (type == ConversionType.imageToPdf && _batchConversions.length > 1) {
        await _imagesToSinglePdf(type, quality: quality);
        return;
      }

      final total = _batchConversions.length;
      for (int i = 0; i < _batchConversions.length; i++) {
        var conversion = _batchConversions[i];
        final name = p.basename(conversion.inputFile.path);
        _loadingMessage = '${AppStrings.convertingFile} (${i + 1}/$total)\n$name';
        notifyListeners();

        _batchConversions[i] = conversion.copyWith(
          type: type,
          status: ConversionStatus.converting,
          progress: 0.05,
          errorMessage: null,
        );
        notifyListeners();

        try {
          final outputFile = await _performConversion(
            type,
            conversion.inputFile,
            quality: quality,
            onProgress: (value, [msg]) {
              final clamped = value.clamp(0.0, 1.0).toDouble();
              _batchConversions[i] = _batchConversions[i].copyWith(
                progress: clamped,
              );
              if (msg != null && msg.isNotEmpty) {
                _loadingMessage =
                    '${AppStrings.convertingFile} (${i + 1}/$total)\n$name\n$msg';
              }
              notifyListeners();
            },
          );

          if (outputFile == null) {
            throw Exception('Conversion produced no output file');
          }

          _batchConversions[i] = _batchConversions[i].copyWith(
            outputFile: outputFile,
            status: ConversionStatus.completed,
            progress: 1.0,
            endTime: DateTime.now(),
          );

          _conversionHistory.insert(0, _batchConversions[i]);
          await _saveHistory();
        } catch (e) {
          _batchConversions[i] = _batchConversions[i].copyWith(
            status: ConversionStatus.error,
            errorMessage: _friendlyError(e),
            endTime: DateTime.now(),
          );
        }
        notifyListeners();
      }
    } finally {
      _isProcessing = false;
      _loadingMessage = null;
      notifyListeners();
    }
  }

  Future<void> _imagesToSinglePdf(
    ConversionType type, {
    required String quality,
  }) async {
    final files = _batchConversions.map((c) => c.inputFile).toList();
    for (int i = 0; i < _batchConversions.length; i++) {
      _batchConversions[i] = _batchConversions[i].copyWith(
        type: type,
        status: ConversionStatus.converting,
        progress: 0.05,
        errorMessage: null,
      );
    }
    notifyListeners();

    try {
      final output = await _conversionService.imagesToPdf(
        files,
        quality: quality,
        onProgress: (value, [msg]) {
          final clamped = value.clamp(0.0, 1.0).toDouble();
          for (int i = 0; i < _batchConversions.length; i++) {
            _batchConversions[i] =
                _batchConversions[i].copyWith(progress: clamped);
          }
          if (msg != null && msg.isNotEmpty) _loadingMessage = msg;
          notifyListeners();
        },
      );
      final merged = ConversionModel(
        id: const Uuid().v4(),
        type: type,
        inputFile: files.first,
        outputFile: output,
        status: ConversionStatus.completed,
        progress: 1.0,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      _batchConversions
        ..clear()
        ..add(merged);
      _conversionHistory.insert(0, merged);
      await _saveHistory();
    } catch (e) {
      for (int i = 0; i < _batchConversions.length; i++) {
        _batchConversions[i] = _batchConversions[i].copyWith(
          status: ConversionStatus.error,
          errorMessage: _friendlyError(e),
          endTime: DateTime.now(),
        );
      }
      _globalErrorMessage = _friendlyError(e);
    }
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final text = e.toString();
    if (text.startsWith('Exception: ')) return text.substring(11);
    return text;
  }

  Future<void> _mergeBatch(ConversionType type) async {
    final pdfFiles = _batchConversions.map((c) => c.inputFile).toList();

    for (int i = 0; i < _batchConversions.length; i++) {
      _batchConversions[i] = _batchConversions[i].copyWith(
        type: type,
        status: ConversionStatus.converting,
        progress: 0.05,
      );
    }
    notifyListeners();

    try {
      final outputFile = await _conversionService.mergePdfs(
        pdfFiles,
        onProgress: (value, [msg]) {
          final clamped = value.clamp(0.0, 1.0).toDouble();
          for (int i = 0; i < _batchConversions.length; i++) {
            _batchConversions[i] =
                _batchConversions[i].copyWith(progress: clamped);
          }
          if (msg != null && msg.isNotEmpty) _loadingMessage = msg;
          notifyListeners();
        },
      );

      final merged = ConversionModel(
        id: const Uuid().v4(),
        type: type,
        inputFile: pdfFiles.first,
        outputFile: outputFile,
        status: ConversionStatus.completed,
        progress: 1.0,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      _batchConversions
        ..clear()
        ..add(merged);

      _conversionHistory.insert(0, merged);
      await _saveHistory();
    } catch (e) {
      for (int i = 0; i < _batchConversions.length; i++) {
        _batchConversions[i] = _batchConversions[i].copyWith(
          status: ConversionStatus.error,
          errorMessage: _friendlyError(e),
          endTime: DateTime.now(),
        );
      }
      _globalErrorMessage = _friendlyError(e);
    }
    _isProcessing = false;
    _loadingMessage = null;
    notifyListeners();
  }

  Future<bool> downloadFileModel(ConversionModel model) async {
    if (model.outputFile == null) return false;
    try {
      final fileName = model.outputFileName ?? 'converted_file';
      await _fileService.saveFile(model.outputFile!, fileName);
      return true;
    } catch (e) {
      debugPrint('Failed to download file: $e');
      return false;
    }
  }

  Future<void> shareFileModel(ConversionModel model) async {
    if (model.outputFile == null) return;
    try {
      await _fileService.shareFile(model.outputFile!);
    } catch (e) {
      debugPrint('Failed to share file: $e');
    }
  }

  Future<void> openFileModel(ConversionModel model) async {
    if (model.outputFile == null) return;
    try {
      await _fileService.openFile(model.outputFile!);
    } catch (e) {
      debugPrint('Failed to open file: $e');
    }
  }

  void reset() {
    _batchConversions.clear();
    _isProcessing = false;
    _clearLoading();
    _globalErrorMessage = null;
    notifyListeners();
  }

  void removeFromBatch(int index) {
    if (index >= 0 && index < _batchConversions.length) {
      _batchConversions.removeAt(index);
      notifyListeners();
    }
  }

  void clearHistory() {
    _conversionHistory.clear();
    _saveHistory();
    notifyListeners();
  }

  void removeFromHistory(String conversionId) {
    _conversionHistory.removeWhere((c) => c.id == conversionId);
    _saveHistory();
    notifyListeners();
  }

  Future<void> retryFailed(ConversionType type, {String quality = 'high'}) async {
    for (int i = 0; i < _batchConversions.length; i++) {
      if (_batchConversions[i].status == ConversionStatus.error) {
        _batchConversions[i] = _batchConversions[i].copyWith(
          status: ConversionStatus.idle,
          errorMessage: null,
          progress: 0.0,
          outputFile: null,
        );
      }
    }
    notifyListeners();
    await convertAll(type, quality: quality);
  }

  Future<File?> _performConversion(
    ConversionType type,
    File inputFile, {
    String quality = 'high',
    ConversionProgress? onProgress,
  }) async {
    switch (type) {
      case ConversionType.pdfToWord:
        return _conversionService.pdfToWord(inputFile, onProgress: onProgress);
      case ConversionType.pdfToExcel:
        return _conversionService.pdfToExcel(inputFile, onProgress: onProgress);
      case ConversionType.pdfToImage:
        return _conversionService.pdfToImage(
          inputFile,
          ImageFormat.png,
          quality: quality,
          onProgress: onProgress,
        );
      case ConversionType.pdfToText:
        return _conversionService.pdfToText(inputFile, onProgress: onProgress);
      case ConversionType.imageToPdf:
        return _conversionService.imageToPdf(
          inputFile,
          quality: quality,
          onProgress: onProgress,
        );
      case ConversionType.wordToPdf:
        return _conversionService.wordToPdf(inputFile, onProgress: onProgress);
      case ConversionType.textToPdf:
        return _conversionService.textToPdf(inputFile, onProgress: onProgress);
      case ConversionType.pdfToPowerPoint:
        return _conversionService.pdfToPowerPoint(
          inputFile,
          onProgress: onProgress,
        );
      case ConversionType.pdfToHtml:
        return _conversionService.pdfToHtml(inputFile, onProgress: onProgress);
      case ConversionType.pdfToEpub:
        return _conversionService.pdfToEpub(inputFile, onProgress: onProgress);
      case ConversionType.excelToPdf:
        return _conversionService.excelToPdf(
          inputFile,
          onProgress: onProgress,
        );
      case ConversionType.powerPointToPdf:
        return _conversionService.powerPointToPdf(
          inputFile,
          onProgress: onProgress,
        );
      case ConversionType.mergePdf:
        throw Exception('Merge PDF requires at least 2 files in the queue.');
    }
  }

  @override
  void dispose() {
    _batchConversions.clear();
    _conversionHistory.clear();
    super.dispose();
  }

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
