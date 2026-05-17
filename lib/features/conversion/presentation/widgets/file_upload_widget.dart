import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';

/// Widget for file upload with drag-and-drop support
class FileUploadWidget extends StatefulWidget {
  final List<String> allowedExtensions;
  final Function(File) onFileSelected;
  final String acceptedFormats;
  final IconData icon;
  final int maxFileSize;
  final File? selectedFile;
  final VoidCallback? onRemoveFile;

  const FileUploadWidget({
    super.key,
    required this.allowedExtensions,
    required this.onFileSelected,
    required this.acceptedFormats,
    this.icon = Icons.cloud_upload,
    this.maxFileSize = 50 * 1024 * 1024, // 50MB
    this.selectedFile,
    this.onRemoveFile,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedFile != null) {
      return _buildSelectedFileView();
    }

    return _buildUploadArea();
  }

  Widget _buildUploadArea() {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => widget.onFileSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: AppDimensions.uploadAreaHeight,
          decoration: BoxDecoration(
            color: _isHovering
                ? theme.colorScheme.primary.withOpacity(0.05)
                : Colors.transparent,
            border: Border.all(
              color: _isHovering
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: AppDimensions.uploadAreaBorderWidth,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: AppDimensions.uploadIconSize,
                color: _isHovering
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                AppStrings.dragDropHint,
                style: TextStyles.getH3(context).copyWith(
                  color: _isHovering
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                AppStrings.orText,
                style: TextStyles.getBody2(context),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLg,
                  vertical: AppDimensions.paddingMd,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  AppStrings.clickToBrowse,
                  style: TextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              _buildFormatChips(),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                AppStrings.maxFileSize,
                style: TextStyles.getCaption(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChips() {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      alignment: WrapAlignment.center,
      children: widget.allowedExtensions.map((ext) {
        return Chip(
          label: Text(
            ext.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSm,
            vertical: 0,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedFileView() {
    final file = widget.selectedFile!;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = _getFileSize(file);
    final fileExtension = fileName.split('.').last.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  _getFileIcon(fileExtension),
                  size: AppDimensions.iconXl,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyles.getFileName(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSm,
                            vertical: AppDimensions.paddingXs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                          child: Text(
                            fileExtension,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Text(
                          fileSize,
                          style: TextStyles.getFileInfo(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.onRemoveFile != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onRemoveFile,
                  tooltip: AppStrings.removeFile,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: AppDimensions.iconSm,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  AppStrings.fileSelected,
                  style: TextStyles.getBody2(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
