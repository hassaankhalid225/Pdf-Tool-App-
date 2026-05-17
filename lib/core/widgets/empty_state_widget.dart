import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:pdf_tool/core/widgets/custom_button.dart';

/// Empty state widget for displaying when there's no content
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? AppDimensions.iconXxl * 1.5,
              color: iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: TextStyles.emptyStateTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              style: TextStyles.emptyStateMessage.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No files empty state
class NoFilesEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseFiles;

  const NoFilesEmptyState({
    super.key,
    this.onBrowseFiles,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.folder_open,
      title: 'No File Selected',
      message: 'Select a file to get started with conversion',
      actionText: onBrowseFiles != null ? 'Browse Files' : null,
      onActionPressed: onBrowseFiles,
    );
  }
}

/// No history empty state
class NoHistoryEmptyState extends StatelessWidget {
  const NoHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.history,
      title: 'No Conversion History',
      message: 'Your conversion history will appear here once you start converting files',
    );
  }
}

/// No favorites empty state
class NoFavoritesEmptyState extends StatelessWidget {
  const NoFavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.star_border,
      title: 'No Favorite Tools',
      message: 'Mark tools as favorites for quick access',
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconXxl * 1.5,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: TextStyles.emptyStateTitle.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              style: TextStyles.emptyStateMessage.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success state widget
class SuccessStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SuccessStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: AppDimensions.iconXxl * 1.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: TextStyles.emptyStateTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              style: TextStyles.emptyStateMessage.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
