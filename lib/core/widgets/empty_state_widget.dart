import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:pdf_tool/core/widgets/custom_button.dart';

/// Empty / error / success states using the modern token palette.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final List<Color>? gradient;
  final IconData? actionIcon;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.gradient,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = gradient ?? AppColors.gradientBlue;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: palette,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.first.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 44),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              style: TextStyles.emptyStateTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              style: TextStyles.emptyStateMessage.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                icon: actionIcon ?? Icons.arrow_forward_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-built no-files state, kept for compatibility.
class NoFilesEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseFiles;
  const NoFilesEmptyState({super.key, this.onBrowseFiles});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.folder_open_rounded,
      title: 'No File Selected',
      message: 'Pick a file from your device to get started',
      gradient: AppColors.gradientPurple,
      actionText: onBrowseFiles != null ? 'Browse Files' : null,
      onActionPressed: onBrowseFiles,
      actionIcon: Icons.upload_file_rounded,
    );
  }
}

class NoHistoryEmptyState extends StatelessWidget {
  const NoHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.history_rounded,
      title: 'Nothing here yet',
      message:
          'Your converted files will land here so you can find them anytime.',
      gradient: AppColors.gradientBlue,
    );
  }
}

class NoFavoritesEmptyState extends StatelessWidget {
  const NoFavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.star_rounded,
      title: 'No Favorite Tools',
      message:
          'Tap the bookmark on any tool to pin it for one-tap access later.',
      gradient: AppColors.gradientOrange,
    );
  }
}

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
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      message: message,
      gradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
      actionText: actionText,
      onActionPressed: onActionPressed,
      actionIcon: Icons.refresh_rounded,
    );
  }
}

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
    return EmptyStateWidget(
      icon: Icons.check_circle_rounded,
      title: title,
      message: message,
      gradient: const [Color(0xFF10B981), Color(0xFF06B6D4)],
      actionText: actionText,
      onActionPressed: onActionPressed,
      actionIcon: Icons.check_rounded,
    );
  }
}
