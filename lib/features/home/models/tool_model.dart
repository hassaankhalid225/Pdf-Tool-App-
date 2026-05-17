import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/enums.dart';

/// Model representing a conversion tool
class ToolModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final ConversionType conversionType;
  final List<Color> gradientColors;
  final List<String> supportedInputFormats;
  final String outputFormat;
  final bool isPopular;
  final String description;

  const ToolModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.conversionType,
    required this.gradientColors,
    required this.supportedInputFormats,
    required this.outputFormat,
    this.isPopular = false,
    required this.description,
  });

  /// Create a copy of this tool with updated values
  ToolModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    ConversionType? conversionType,
    List<Color>? gradientColors,
    List<String>? supportedInputFormats,
    String? outputFormat,
    bool? isPopular,
    String? description,
  }) {
    return ToolModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      conversionType: conversionType ?? this.conversionType,
      gradientColors: gradientColors ?? this.gradientColors,
      supportedInputFormats: supportedInputFormats ?? this.supportedInputFormats,
      outputFormat: outputFormat ?? this.outputFormat,
      isPopular: isPopular ?? this.isPopular,
      description: description ?? this.description,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'conversionType': conversionType.name,
      'supportedInputFormats': supportedInputFormats,
      'outputFormat': outputFormat,
      'isPopular': isPopular,
      'description': description,
    };
  }

  /// Create from JSON
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: Icons.picture_as_pdf, // Default icon
      conversionType: ConversionType.values.firstWhere(
        (e) => e.name == json['conversionType'],
      ),
      gradientColors: const [Colors.blue, Colors.blueAccent], // Default gradient
      supportedInputFormats: List<String>.from(json['supportedInputFormats'] as List),
      outputFormat: json['outputFormat'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      description: json['description'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ToolModel &&
        other.id == id &&
        other.title == title &&
        other.conversionType == conversionType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ conversionType.hashCode;
  }

  @override
  String toString() {
    return 'ToolModel(id: $id, title: $title, conversionType: $conversionType)';
  }
}
