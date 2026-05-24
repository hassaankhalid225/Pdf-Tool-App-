import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/constants/tools_data.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/core/widgets/loading_overlay.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/features/conversion/presentation/widgets/conversion_upload_zone.dart';
import 'package:pdf_tool/features/conversion/providers/conversion_provider.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';

class ConversionScreen extends StatefulWidget {
  final ConversionType conversionType;

  const ConversionScreen({super.key, required this.conversionType});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  bool _successSnackShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversionProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolsData.getToolByType(widget.conversionType);
    if (tool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Tool not found')),
      );
    }

    return Consumer<ConversionProvider>(
      builder: (context, provider, _) {
        final completed = provider.isAllComplete;

        if (completed && !_successSnackShown) {
          _successSnackShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppStrings.conversionComplete),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade700,
              ),
            );
          });
        }
        if (!completed) _successSnackShown = false;

        final showStickyConvert = provider.hasFile &&
            !provider.isAllComplete &&
            !provider.isLoading &&
            provider.batchConversions.any((c) => !c.isComplete);

        return LoadingOverlay(
          isLoading: provider.isLoading,
          message: provider.loadingMessage ??
              (provider.isProcessing
                  ? AppStrings.convertingFile
                  : AppStrings.preparingFiles),
          progress: provider.isProcessing ? provider.progress : null,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                completed ? 'Conversion result' : tool.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: Icon(
                  completed ? Icons.close_rounded : Icons.arrow_back_rounded,
                ),
                onPressed: () {
                  if (completed) {
                    provider.reset();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!completed) _ToolHeaderCard(tool: tool),
                          if (!completed) const SizedBox(height: 22),
                          if (!completed)
                            _Stepper(status: provider.status),
                          if (!completed) const SizedBox(height: 26),
                          _content(context, provider, tool),
                        ],
                      ),
                    ),
                  ),
                  if (showStickyConvert)
                    _StickyConvertBar(
                      label: widget.conversionType == ConversionType.mergePdf
                          ? 'Merge ${provider.batchConversions.length} files'
                          : 'Convert ${provider.batchConversions.length} file${provider.batchConversions.length == 1 ? '' : 's'}',
                      enabled: !(widget.conversionType ==
                              ConversionType.mergePdf &&
                          provider.batchConversions.length < 2),
                      onPressed: () {
                        final quality =
                            context.read<SettingsProvider>().defaultQuality;
                        provider.convertAll(widget.conversionType,
                            quality: quality);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext context,
    ConversionProvider provider,
    ToolModel tool,
  ) {
    if (!provider.hasFile) {
      return _UploadSection(
        tool: tool,
        type: widget.conversionType,
        provider: provider,
      );
    }
    return _QueueSection(
      tool: tool,
      type: widget.conversionType,
      provider: provider,
    );
  }
}

// ─────────────────────────── Sections ───────────────────────────

class _ToolHeaderCard extends StatelessWidget {
  final ToolModel tool;
  const _ToolHeaderCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: tool.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: tool.gradientColors.first.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(tool.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tool.description,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final ConversionStatus status;
  const _Stepper({required this.status});

  int get _step {
    if (status == ConversionStatus.completed) return 3;
    if (status.isInProgress) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final s = _step;
    return Row(
      children: [
        _StepDot(index: 1, current: s, label: 'Upload'),
        _StepLine(active: s >= 2),
        _StepDot(index: 2, current: s, label: 'Convert'),
        _StepLine(active: s >= 3),
        _StepDot(index: 3, current: s, label: 'Download'),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot({
    required this.index,
    required this.current,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = current > index;
    final active = current >= index;
    final color = active ? AppColors.primary : theme.colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : Colors.transparent,
            border: Border.all(color: color, width: 2),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      color: active ? Colors.white : color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        color: active
            ? AppColors.primary
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final ToolModel tool;
  final ConversionType type;
  final ConversionProvider provider;

  const _UploadSection({
    required this.tool,
    required this.type,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConversionUploadZone(
          isLoading: provider.isSelectingFiles,
          title: 'Upload file(s)',
          subtitle: type == ConversionType.mergePdf
              ? 'Pick 2 or more PDFs to combine into one'
              : type == ConversionType.imageToPdf
                  ? 'Pick one or more images — multiple images merge into a single PDF'
                  : 'Tap to choose one or multiple files',
          onTap: () => provider.selectFiles(tool.supportedInputFormats, type),
        ),
        if (provider.globalErrorMessage != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: provider.globalErrorMessage!),
        ],
        const SizedBox(height: 18),
        _SupportedFormatsRow(formats: tool.supportedInputFormats),
      ],
    );
  }
}

class _QueueSection extends StatelessWidget {
  final ToolModel tool;
  final ConversionType type;
  final ConversionProvider provider;

  const _QueueSection({
    required this.tool,
    required this.type,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasErrors = provider.batchConversions
        .any((c) => c.status == ConversionStatus.error);
    final mergeNeedsMore =
        type == ConversionType.mergePdf && provider.batchConversions.length < 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected files (${provider.batchConversions.length})',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!provider.isLoading)
              TextButton.icon(
                onPressed: () =>
                    provider.addMoreFiles(tool.supportedInputFormats, type),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Add more'),
              ),
          ],
        ),
        if (provider.isAllComplete) ...[
          const SizedBox(height: 4),
          Text(
            '${provider.completedCount} of ${provider.batchConversions.length} converted',
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
        if (mergeNeedsMore) ...[
          const SizedBox(height: 8),
          _Hint(
            color: Colors.orange,
            icon: Icons.info_outline_rounded,
            message: 'Pick at least 2 PDF files to merge.',
          ),
        ],
        const SizedBox(height: 14),
        ...provider.batchConversions.asMap().entries.map((entry) {
          return _FileRow(
            index: entry.key,
            conversion: entry.value,
            provider: provider,
          );
        }),
        if (provider.errorMessage != null && hasErrors) ...[
          const SizedBox(height: 8),
          _ErrorBanner(message: provider.errorMessage!),
        ],
        if (hasErrors && !provider.isLoading) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              final quality =
                  context.read<SettingsProvider>().defaultQuality;
              provider.retryFailed(type, quality: quality);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(AppStrings.retry),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
        if (provider.isAllComplete) ...[
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: provider.reset,
            icon: const Icon(Icons.add_rounded),
            label: const Text(AppStrings.convertAnother),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        if (!provider.isLoading && !provider.isAllComplete) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: provider.reset,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text(AppStrings.changeFile),
          ),
        ],
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  final int index;
  final ConversionModel conversion;
  final ConversionProvider provider;
  const _FileRow({
    required this.index,
    required this.conversion,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isInProgress = conversion.status.isInProgress;
    final isDone = conversion.status == ConversionStatus.completed;
    final isError = conversion.status == ConversionStatus.error;

    Color statusColor;
    IconData statusIcon;
    if (isDone) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
    } else if (isError) {
      statusColor = colorScheme.error;
      statusIcon = Icons.error_outline_rounded;
    } else if (isInProgress) {
      statusColor = AppColors.primary;
      statusIcon = Icons.sync_rounded;
    } else {
      statusColor = colorScheme.onSurface.withValues(alpha: 0.55);
      statusIcon = Icons.insert_drive_file_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDone && conversion.outputFileName != null
                            ? conversion.outputFileName!
                            : conversion.inputFileName,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isError
                            ? (conversion.errorMessage ?? 'Failed')
                            : '${conversion.status.displayName} • ${conversion.formattedInputFileSize}',
                        style: TextStyle(
                          color: isError
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isInProgress)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '${(conversion.progress.clamp(0, 1) * 100).round()}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (isDone) ...[
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.blueAccent),
                    tooltip: 'Save',
                    onPressed: () async {
                      final ok = await provider.downloadFileModel(conversion);
                      if (context.mounted && ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.downloadComplete),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.ios_share_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    tooltip: 'Share',
                    onPressed: () => provider.shareFileModel(conversion),
                  ),
                ] else if (!provider.isProcessing && !isInProgress) ...[
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    tooltip: 'Remove',
                    onPressed: () => provider.removeFromBatch(index),
                  ),
                ],
              ],
            ),
            if (isInProgress) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: conversion.progress.clamp(0, 1).toDouble(),
                  minHeight: 4,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StickyConvertBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _StickyConvertBar({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(colors: AppColors.gradientBlue)
              : null,
          color: enabled ? null : theme.disabledColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Bits ───────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _Hint({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportedFormatsRow extends StatelessWidget {
  final List<String> formats;
  const _SupportedFormatsRow({required this.formats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Text(
          'Supported',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        ...formats.map(
          (f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              f.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
