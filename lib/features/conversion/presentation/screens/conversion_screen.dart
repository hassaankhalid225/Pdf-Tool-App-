import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/tools_data.dart';
import 'package:pdf_tool/core/widgets/custom_button.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:pdf_tool/features/conversion/providers/conversion_provider.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';

/// Screen for performing file conversions
class ConversionScreen extends StatefulWidget {
  final ConversionType conversionType;

  const ConversionScreen({
    super.key,
    required this.conversionType,
  });

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  @override
  void initState() {
    super.initState();
    // Reset conversion state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversionProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tool = ToolsData.getToolByType(widget.conversionType);
    
    if (tool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Tool not found')),
      );
    }

    return Consumer<ConversionProvider>(
      builder: (context, provider, child) {
        final isCompleted = provider.status == ConversionStatus.completed;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              isCompleted ? 'Conversion Result' : tool.title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                isCompleted ? Icons.close : Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                if (isCompleted) {
                  provider.reset();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              if (isCompleted)
                IconButton(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                  onPressed: () {},
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isCompleted) ...[
                    // Tool info card
                    _buildToolHeaderCard(context, tool),
                    const SizedBox(height: 24),
                    // Stepper
                    _buildStepper(context, provider),
                    const SizedBox(height: 32),
                  ],
                  
                  // Conversion Content
                  _buildConversionContent(context, provider, tool),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolHeaderCard(BuildContext context, dynamic tool) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tool.gradientColors.first.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tool.icon,
              size: 32,
              color: tool.gradientColors.first,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tool.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context, ConversionProvider provider) {
    int currentStep = 1;
    if (provider.status.isInProgress) currentStep = 2;
    if (provider.status == ConversionStatus.completed) currentStep = 3;

    return Row(
      children: [
        _buildStepItem(context, 1, 'UPLOAD', currentStep >= 1),
        _buildStepLine(context, currentStep >= 2),
        _buildStepItem(context, 2, 'CONVERT', currentStep >= 2),
        _buildStepLine(context, currentStep >= 3),
        _buildStepItem(context, 3, 'DOWNLOAD', currentStep >= 3),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, int step, String label, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: theme.brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!, width: 2),
          ),
          child: Center(
            child: isActive && step < 3 
                ? (step == 1 && isActive ? const Icon(Icons.check, size: 16, color: Colors.white) : Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                : Text('$step', style: TextStyle(color: isActive ? Colors.white : (theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400]), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? colorScheme.onSurface : (theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
      ),
    );
  }


  Widget _buildConversionContent(BuildContext context, ConversionProvider provider, dynamic tool) {
    // No file selected - show upload button
    if (!provider.hasFile) {
      return _buildFileUploadSection(context, provider, tool);
    }

    // Batch mode
    if (provider.isBatchProcessing) {
      return _buildBatchConversionSection(context, provider, tool);
    }

    // File selected but not converting - show file info and convert button
    if (provider.status == ConversionStatus.idle) {
      return _buildFileSelectedSection(context, provider, tool);
    }

    // Converting - show progress
    if (provider.status.isInProgress) {
      return _buildConvertingSection(context, provider);
    }

    // Completed - show result actions
    if (provider.status == ConversionStatus.completed) {
      return _buildCompletedSection(context, provider);
    }

    // Error - show error message
    if (provider.status == ConversionStatus.error) {
      return _buildErrorSection(context, provider);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFileUploadSection(BuildContext context, ConversionProvider provider, dynamic tool) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.selectFiles(tool.supportedInputFormats, widget.conversionType),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: AppDimensions.iconXxl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Upload PDF File(s)',
                    style: TextStyles.getH3(context),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Tap to select one or more files',
                    style: TextStyles.getBody2(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomButton(
          text: 'Select Multiple Files',
          onPressed: () => provider.selectFiles(tool.supportedInputFormats, widget.conversionType),
          icon: Icons.copy,
          isOutlined: true,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildFileSelectedSection(BuildContext context, ConversionProvider provider, dynamic tool) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileName = provider.currentConversion?.inputFileName ?? '';
    final fileSize = provider.currentConversion?.formattedInputFileSize ?? '';
    
    return Column(
      children: [
        // Preview Card
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.05),
                theme.cardTheme.color ?? colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.grey[800]!.withValues(alpha: 0.8) : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('READY', style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, color: colorScheme.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('PDF', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.05),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$fileSize • 14 Pages',
                              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: provider.removeFile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Convert Now',
                onPressed: () {
                  final quality = context.read<SettingsProvider>().defaultQuality;
                  provider.convertFile(widget.conversionType, quality: quality);
                },
                icon: Icons.sync,
                height: 56,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add More',
                onPressed: () => provider.addMoreFiles(tool.supportedInputFormats, widget.conversionType),
                icon: Icons.add_circle_outline,
                isOutlined: true,
                height: 56,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Change File',
          onPressed: provider.reset,
          icon: Icons.folder_open,
          isOutlined: true,
          width: double.infinity,
          height: 56,
          textColor: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        
        const SizedBox(height: 32),
        
        // Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb, color: AppColors.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart OCR Enabled',
                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We've detected scanned pages. Optical Character Recognition is active to ensure your text is editable.",
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Bottom Format Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 16),
            const SizedBox(width: 12),
            Icon(tool.icon, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildConvertingSection(BuildContext context, ConversionProvider provider) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppDimensions.spacingLg),
        Text(
          AppStrings.convertingFile,
          style: TextStyles.getH3(context),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        LinearProgressIndicator(
          value: provider.progress,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          '${(provider.progress * 100).toInt()}%',
          style: TextStyles.getBody1(context),
        ),
      ],
    );
  }

  Widget _buildCompletedSection(BuildContext context, ConversionProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        const SizedBox(height: 20),
        // Success Circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Conversion Successful!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          provider.currentConversion?.type.displayName ?? '',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 48),
        
        // Result File Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.currentConversion?.outputFileName ?? '',
                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PDF', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(provider.currentConversion?.formattedOutputFileSize ?? '', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withValues(alpha: 0.4))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // 2x2 Action Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildResultActionCard(
              context,
              'Download',
              Icons.download,
              colorScheme.primary,
              provider.downloadFile,
              textColor: Colors.white,
            ),
            _buildResultActionCard(
              context,
              'Share',
              Icons.share,
              theme.cardTheme.color ?? colorScheme.surface,
              provider.shareFile,
              isSecondary: true,
            ),
            _buildResultActionCard(
              context,
              'Open',
              Icons.remove_red_eye,
              theme.cardTheme.color ?? colorScheme.surface,
              provider.openFile,
              isSecondary: true,
            ),
            _buildResultActionCard(
              context,
              'Convert Another',
              Icons.add_circle,
              Colors.orange,
              provider.reset,
              textColor: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Pro Tip Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pro Tip', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Files are automatically saved to your Documents folder. Tap "Open" to preview instantly.',
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.close, color: colorScheme.onSurface.withValues(alpha: 0.3), size: 16),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultActionCard(
    BuildContext context,
    String title, 
    IconData icon, 
    Color color, 
    VoidCallback onTap, {
    bool isSecondary = false,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isSecondary ? Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)) : null,
          boxShadow: [
            if (!isSecondary)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? theme.colorScheme.onSurface, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor ?? theme.colorScheme.onSurface, 
                fontWeight: FontWeight.bold, 
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchConversionSection(BuildContext context, ConversionProvider provider, dynamic tool) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Batch Selection (${provider.batchConversions.length} files)',
              style: TextStyles.getH3(context),
            ),
            if (!provider.isProcessing && provider.batchConversions.every((c) => !c.isComplete))
              TextButton.icon(
                onPressed: () => provider.addMoreFiles(tool.supportedInputFormats, widget.conversionType),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add More'),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        ...provider.batchConversions.asMap().entries.map((entry) {
          final index = entry.key;
          final conv = entry.value;
          return Card(
            elevation: 0,
            color: theme.cardTheme.color ?? colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: ListTile(
              leading: Icon(
                conv.status == ConversionStatus.completed 
                  ? Icons.check_circle 
                  : conv.status == ConversionStatus.error 
                    ? Icons.error 
                    : Icons.insert_drive_file,
                color: conv.status == ConversionStatus.completed 
                  ? Colors.green 
                  : conv.status == ConversionStatus.error 
                    ? Colors.red 
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              title: Text(
                conv.inputFileName, 
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                conv.status.displayName, 
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
              ),
              trailing: conv.status.isInProgress 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : (conv.status == ConversionStatus.completed 
                    ? IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue, size: 20),
                        onPressed: () => provider.downloadFileModel(conv),
                      )
                    : (provider.isProcessing ? null : IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                        onPressed: () => provider.removeFromBatch(index),
                      ))),
            ),
          );
        }),
        const SizedBox(height: AppDimensions.spacingLg),
        if (!provider.isProcessing && provider.batchConversions.every((c) => !c.isComplete))
          CustomButton(
            text: 'Convert All',
            onPressed: () {
              final quality = context.read<SettingsProvider>().defaultQuality;
              provider.convertBatch(widget.conversionType, quality: quality);
            },
            icon: Icons.sync,
            width: double.infinity,
          ),
        if (provider.batchConversions.any((c) => c.isComplete))
          CustomButton(
            text: AppStrings.convertAnother,
            onPressed: provider.reset,
            icon: Icons.refresh,
            isOutlined: true,
            width: double.infinity,
          ),
        const SizedBox(height: AppDimensions.spacingMd),
        if (!provider.isProcessing)
          CustomButton(
            text: 'Cancel',
            onPressed: provider.reset,
            isOutlined: true,
            width: double.infinity,
          ),
      ],
    );
  }

  Widget _buildErrorSection(BuildContext context, ConversionProvider provider) {
    return Column(
      children: [
        const Icon(
          Icons.error,
          color: Colors.red,
          size: 80,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text(
          AppStrings.conversionFailed,
          style: TextStyles.getH3(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          provider.errorMessage ?? AppStrings.errorUnknown,
          style: TextStyles.getBody2(context).copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        CustomButton(
          text: AppStrings.retry,
          onPressed: provider.retryConversion,
          icon: Icons.refresh,
          width: double.infinity,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomButton(
          text: AppStrings.changeFile,
          onPressed: provider.reset,
          isOutlined: true,
          width: double.infinity,
        ),
      ],
    );
  }
}
