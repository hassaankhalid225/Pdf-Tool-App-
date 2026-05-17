import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';

/// Widget displaying conversion status with progress
class ConversionStatusWidget extends StatefulWidget {
  final ConversionStatus status;
  final double progress;
  final String? fileName;
  final String? errorMessage;

  const ConversionStatusWidget({
    super.key,
    required this.status,
    this.progress = 0.0,
    this.fileName,
    this.errorMessage,
  });

  @override
  State<ConversionStatusWidget> createState() => _ConversionStatusWidgetState();
}

class _ConversionStatusWidgetState extends State<ConversionStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: _getStatusColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildStatusIcon(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildStatusText(),
          if (widget.status.isInProgress) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            _buildProgressBar(),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildProgressPercentage(),
          ],
          if (widget.fileName != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _buildFileName(),
          ],
          if (widget.status == ConversionStatus.error &&
              widget.errorMessage != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (widget.status.isInProgress) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            value: widget.progress > 0 ? widget.progress : null,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(),
        size: AppDimensions.statusIconSize,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildStatusText() {
    return Text(
      _getStatusMessage(),
      style: TextStyles.getH3(context).copyWith(
        color: _getStatusColor(),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.statusProgressHeight / 2),
      child: LinearProgressIndicator(
        value: widget.progress,
        minHeight: AppDimensions.statusProgressHeight,
        backgroundColor: _getStatusColor().withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
      ),
    );
  }

  Widget _buildProgressPercentage() {
    final percentage = (widget.progress * 100).toInt();
    return Text(
      '$percentage%',
      style: TextStyles.getBody1(context).copyWith(
        fontWeight: FontWeight.w600,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildFileName() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            size: AppDimensions.iconSm,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              widget.fileName!,
              style: TextStyles.getBody2(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: AppDimensions.iconSm,
            color: AppColors.error,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: TextStyles.getBody2(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case ConversionStatus.idle:
        return AppColors.info;
      case ConversionStatus.uploading:
      case ConversionStatus.converting:
        return AppColors.primary;
      case ConversionStatus.completed:
        return AppColors.success;
      case ConversionStatus.error:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case ConversionStatus.idle:
        return Icons.info_outline;
      case ConversionStatus.uploading:
        return Icons.cloud_upload;
      case ConversionStatus.converting:
        return Icons.sync;
      case ConversionStatus.completed:
        return Icons.check_circle;
      case ConversionStatus.error:
        return Icons.error;
    }
  }

  String _getStatusMessage() {
    switch (widget.status) {
      case ConversionStatus.idle:
        return 'Ready to convert';
      case ConversionStatus.uploading:
        return AppStrings.uploadingFile;
      case ConversionStatus.converting:
        return AppStrings.convertingFile;
      case ConversionStatus.completed:
        return AppStrings.conversionComplete;
      case ConversionStatus.error:
        return AppStrings.conversionFailed;
    }
  }
}

/// Compact conversion progress widget
class ConversionProgressWidget extends StatelessWidget {
  final double progress;
  final String? label;

  const ConversionProgressWidget({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyles.getBody2(context),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyles.getCaption(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
