import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';

/// Custom card widget with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBorderRadius = borderRadius ??
        BorderRadius.circular(AppDimensions.radiusMedium);

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: cardBorderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: cardContent,
        ),
      );
    }

    return Card(
      elevation: elevation ?? AppDimensions.cardElevation,
      margin: margin ?? const EdgeInsets.all(AppDimensions.cardMargin),
      shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
      child: cardContent,
    );
  }
}

/// Gradient card widget
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ??
        BorderRadius.circular(AppDimensions.radiusMedium);

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: cardBorderRadius,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: cardContent,
        ),
      );
    }

    return Card(
      elevation: elevation ?? AppDimensions.cardElevation,
      margin: margin ?? const EdgeInsets.all(AppDimensions.cardMargin),
      shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
      child: cardContent,
    );
  }
}

/// Info card with icon, title, and description
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      color: backgroundColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: AppDimensions.iconSm,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
        ],
      ),
    );
  }
}

/// Status card with colored indicator
class StatusCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Widget? action;

  const StatusCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      border: Border.all(color: color, width: 2),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppDimensions.iconLg),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            action!,
          ],
        ],
      ),
    );
  }
}
