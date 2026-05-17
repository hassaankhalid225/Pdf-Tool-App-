import 'package:flutter/material.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';

/// Static data for all conversion tools
class ToolsData {
  ToolsData._(); // Private constructor

  /// Get all "From PDF" tools
  static List<ToolModel> get fromPdfTools => [
        ToolModel(
          id: 'pdf_to_word',
          title: AppStrings.pdfToWord,
          subtitle: AppStrings.pdfToWordDesc,
          icon: Icons.description,
          conversionType: ConversionType.pdfToWord,
          gradientColors: AppColors.gradientBlue,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'docx',
          isPopular: true,
          description: 'Convert PDF documents to editable Microsoft Word format',
        ),
        ToolModel(
          id: 'pdf_to_excel',
          title: AppStrings.pdfToExcel,
          subtitle: AppStrings.pdfToExcelDesc,
          icon: Icons.table_chart,
          conversionType: ConversionType.pdfToExcel,
          gradientColors: AppColors.gradientGreen,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'xlsx',
          isPopular: true,
          description: 'Extract tables and data from PDF to Excel spreadsheet',
        ),
        ToolModel(
          id: 'pdf_to_powerpoint',
          title: AppStrings.pdfToPowerPoint,
          subtitle: AppStrings.pdfToPowerPointDesc,
          icon: Icons.slideshow,
          conversionType: ConversionType.pdfToPowerPoint,
          gradientColors: AppColors.gradientOrange,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'pptx',
          description: 'Convert PDF to PowerPoint presentation',
        ),
        ToolModel(
          id: 'pdf_to_image',
          title: AppStrings.pdfToImage,
          subtitle: AppStrings.pdfToImageDesc,
          icon: Icons.image,
          conversionType: ConversionType.pdfToImage,
          gradientColors: AppColors.gradientPurple,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'png',
          isPopular: true,
          description: 'Convert PDF pages to high-quality images',
        ),
        ToolModel(
          id: 'pdf_to_text',
          title: AppStrings.pdfToText,
          subtitle: AppStrings.pdfToTextDesc,
          icon: Icons.text_fields,
          conversionType: ConversionType.pdfToText,
          gradientColors: AppColors.gradientTeal,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'txt',
          description: 'Extract all text content from PDF documents',
        ),
        ToolModel(
          id: 'pdf_to_html',
          title: AppStrings.pdfToHtml,
          subtitle: AppStrings.pdfToHtmlDesc,
          icon: Icons.code,
          conversionType: ConversionType.pdfToHtml,
          gradientColors: AppColors.gradientIndigo,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'html',
          description: 'Convert PDF to HTML web page format',
        ),
        ToolModel(
          id: 'pdf_to_epub',
          title: AppStrings.pdfToEpub,
          subtitle: AppStrings.pdfToEpubDesc,
          icon: Icons.menu_book,
          conversionType: ConversionType.pdfToEpub,
          gradientColors: AppColors.gradientPink,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'epub',
          description: 'Convert PDF to EPUB eBook format',
        ),
      ];

  /// Get all "To PDF" tools
  static List<ToolModel> get toPdfTools => [
        ToolModel(
          id: 'image_to_pdf',
          title: AppStrings.imageToPdf,
          subtitle: AppStrings.imageToPdfDesc,
          icon: Icons.photo_library,
          conversionType: ConversionType.imageToPdf,
          gradientColors: AppColors.gradientCyan,
          supportedInputFormats: const ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
          outputFormat: 'pdf',
          isPopular: true,
          description: 'Convert images to PDF document',
        ),
        ToolModel(
          id: 'word_to_pdf',
          title: AppStrings.wordToPdf,
          subtitle: AppStrings.wordToPdfDesc,
          icon: Icons.article,
          conversionType: ConversionType.wordToPdf,
          gradientColors: AppColors.gradientBlue,
          supportedInputFormats: const ['doc', 'docx'],
          outputFormat: 'pdf',
          isPopular: true,
          description: 'Convert Word documents to PDF format',
        ),
        ToolModel(
          id: 'excel_to_pdf',
          title: AppStrings.excelToPdf,
          subtitle: AppStrings.excelToPdfDesc,
          icon: Icons.grid_on,
          conversionType: ConversionType.excelToPdf,
          gradientColors: AppColors.gradientGreen,
          supportedInputFormats: const ['xls', 'xlsx'],
          outputFormat: 'pdf',
          description: 'Convert Excel spreadsheets to PDF',
        ),
        ToolModel(
          id: 'powerpoint_to_pdf',
          title: AppStrings.powerPointToPdf,
          subtitle: AppStrings.powerPointToPdfDesc,
          icon: Icons.present_to_all,
          conversionType: ConversionType.powerPointToPdf,
          gradientColors: AppColors.gradientOrange,
          supportedInputFormats: const ['ppt', 'pptx'],
          outputFormat: 'pdf',
          description: 'Convert PowerPoint presentations to PDF',
        ),
        ToolModel(
          id: 'text_to_pdf',
          title: AppStrings.textToPdf,
          subtitle: AppStrings.textToPdfDesc,
          icon: Icons.text_snippet,
          conversionType: ConversionType.textToPdf,
          gradientColors: AppColors.gradientAmber,
          supportedInputFormats: const ['txt'],
          outputFormat: 'pdf',
          description: 'Convert plain text files to PDF',
        ),
        ToolModel(
          id: 'merge_pdf',
          title: 'Merge PDF',
          subtitle: 'Combine multiple PDF files',
          icon: Icons.merge_type,
          conversionType: ConversionType.mergePdf,
          gradientColors: AppColors.gradientPurple,
          supportedInputFormats: const ['pdf'],
          outputFormat: 'pdf',
          isPopular: true,
          description: 'Join multiple PDF documents into a single file in any order',
        ),
      ];

  /// Get all tools (combined)
  static List<ToolModel> get allTools => [...fromPdfTools, ...toPdfTools];

  /// Get tool by ID
  static ToolModel? getToolById(String id) {
    try {
      return allTools.firstWhere((tool) => tool.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get tool by conversion type
  static ToolModel? getToolByType(ConversionType type) {
    try {
      return allTools.firstWhere((tool) => tool.conversionType == type);
    } catch (e) {
      return null;
    }
  }

  /// Get popular tools
  static List<ToolModel> get popularTools {
    return allTools.where((tool) => tool.isPopular).toList();
  }
}
