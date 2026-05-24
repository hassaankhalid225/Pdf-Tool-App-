import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf_tool/core/constants/enums.dart';

/// Model representing a file conversion operation
class ConversionModel {
  final String id;
  final ConversionType type;
  final File inputFile;
  final File? outputFile;
  final ConversionStatus status;
  final double progress;
  final DateTime startTime;
  final DateTime? endTime;
  final String? errorMessage;

  const ConversionModel({
    required this.id,
    required this.type,
    required this.inputFile,
    this.outputFile,
    required this.status,
    this.progress = 0.0,
    required this.startTime,
    this.endTime,
    this.errorMessage,
  });

  /// Create a copy of this conversion with updated values
  ConversionModel copyWith({
    String? id,
    ConversionType? type,
    File? inputFile,
    File? outputFile,
    ConversionStatus? status,
    double? progress,
    DateTime? startTime,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return ConversionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      inputFile: inputFile ?? this.inputFile,
      outputFile: outputFile ?? this.outputFile,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get the duration of the conversion
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Get the input file name
  String get inputFileName {
    return p.basename(inputFile.path);
  }

  /// Get the output file name
  String? get outputFileName {
    final file = outputFile;
    if (file == null) return null;
    return p.basename(file.path);
  }

  /// Get the input file size in bytes
  int get inputFileSize {
    try {
      return inputFile.lengthSync();
    } catch (e) {
      return 0;
    }
  }

  /// Get the output file size in bytes
  int? get outputFileSize {
    try {
      return outputFile?.lengthSync();
    } catch (e) {
      return null;
    }
  }

  /// Get formatted input file size
  String get formattedInputFileSize {
    return _formatFileSize(inputFileSize);
  }

  /// Get formatted output file size
  String? get formattedOutputFileSize {
    final size = outputFileSize;
    if (size == null) return null;
    return _formatFileSize(size);
  }

  /// Format file size in bytes to human-readable format
  String _formatFileSize(int bytes) {
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

  /// Check if conversion is in progress
  bool get isInProgress {
    return status.isInProgress;
  }

  /// Check if conversion is complete
  bool get isComplete {
    return status.isComplete;
  }

  /// Check if there's an error
  bool get hasError {
    return status.hasError;
  }

  /// Check if idle
  bool get isIdle {
    return status.isIdle;
  }

  /// Get progress percentage (0-100)
  int get progressPercentage {
    return (progress * 100).round();
  }

  /// Convert to JSON (for potential storage/caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'inputFilePath': inputFile.path,
      'outputFilePath': outputFile?.path,
      'status': status.name,
      'progress': progress,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON
  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      id: json['id'] as String,
      type: ConversionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      inputFile: File(json['inputFilePath'] as String),
      outputFile: json['outputFilePath'] != null
          ? File(json['outputFilePath'] as String)
          : null,
      status: ConversionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      progress: (json['progress'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversionModel &&
        other.id == id &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ status.hashCode;
  }

  @override
  String toString() {
    return 'ConversionModel(id: $id, type: ${type.displayName}, status: ${status.displayName}, progress: $progressPercentage%)';
  }
}
