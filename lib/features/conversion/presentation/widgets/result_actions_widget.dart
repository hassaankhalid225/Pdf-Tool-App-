import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/widgets/custom_button.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';

/// Widget displaying action buttons for converted file
class ResultActionsWidget extends StatelessWidget {
  final String filePath;
  final String fileName;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onOpen;
  final VoidCallback onConvertAnother;
  final bool isDownloading;
  final bool isSharing;
  final bool isOpening;

  const ResultActionsWidget({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.onDownload,
    required this.onShare,
    required this.onOpen,
    required this.onConvertAnother,
    this.isDownloading = false,
    this.isSharing = false,
    this.isOpening = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success message
        _buildSuccessMessage(context),
        
        const SizedBox(height: AppDimensions.spacingXl),
        
        // File info
        _buildFileInfo(context),
        
        const SizedBox(height: AppDimensions.spacingXl),
        
        // Action buttons
        if (isMobile)
          _buildMobileActions(context)
        else
          _buildDesktopActions(context),
        
        const SizedBox(height: AppDimensions.spacingLg),
        
        // Convert another button
        CustomButton(
          text: AppStrings.convertAnother,
          onPressed: onConvertAnother,
          icon: Icons.refresh,
          isOutlined: true,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildSuccessMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.successTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  AppStrings.successMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: Theme.of(context).colorScheme.primary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Ready to download',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: AppStrings.download,
          onPressed: onDownload,
          icon: Icons.download,
          isLoading: isDownloading,
          width: double.infinity,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.share,
                onPressed: onShare,
                icon: Icons.share,
                isLoading: isSharing,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: CustomButton(
                text: AppStrings.open,
                onPressed: onOpen,
                icon: Icons.open_in_new,
                isLoading: isOpening,
                isOutlined: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            text: AppStrings.download,
            onPressed: onDownload,
            icon: Icons.download,
            isLoading: isDownloading,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: CustomButton(
            text: AppStrings.share,
            onPressed: onShare,
            icon: Icons.share,
            isLoading: isSharing,
            isOutlined: true,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: CustomButton(
            text: AppStrings.open,
            onPressed: onOpen,
            icon: Icons.open_in_new,
            isLoading: isOpening,
            isOutlined: true,
          ),
        ),
      ],
    );
  }
}

/// Compact action buttons for result
class CompactResultActions extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  const CompactResultActions({
    super.key,
    required this.onDownload,
    required this.onShare,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.download,
          label: AppStrings.download,
          onTap: onDownload,
        ),
        _buildActionButton(
          context,
          icon: Icons.share,
          label: AppStrings.share,
          onTap: onShare,
        ),
        _buildActionButton(
          context,
          icon: Icons.open_in_new,
          label: AppStrings.open,
          onTap: onOpen,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
