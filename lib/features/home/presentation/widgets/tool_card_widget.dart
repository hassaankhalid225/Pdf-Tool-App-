import 'package:flutter/material.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';

/// Widget displaying a conversion tool card with gradient background
class ToolCardWidget extends StatefulWidget {
  final ToolModel tool;
  final VoidCallback onTap;

  const ToolCardWidget({
    super.key,
    required this.tool,
    required this.onTap,
  });

  @override
  State<ToolCardWidget> createState() => _ToolCardWidgetState();
}

class _ToolCardWidgetState extends State<ToolCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isDark ? null : Border.all(color: Colors.grey[200]!.withValues(alpha: 0.5)),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingSm),
                      decoration: BoxDecoration(
                        color: widget.tool.gradientColors.first.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Icon(
                        widget.tool.icon,
                        size: AppDimensions.iconMd,
                        color: widget.tool.gradientColors.first,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Title
                    Text(
                      widget.tool.title,
                      style: TextStyles.toolCardTitle.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      widget.tool.subtitle,
                      style: TextStyles.toolCardSubtitle.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Favorite Icon
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    final isFavorite = settings.isFavorite(widget.tool.id);
                    return GestureDetector(
                      onTap: () => settings.toggleFavoriteTool(widget.tool.id),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        size: 16,
                        color: isFavorite 
                          ? Colors.amber 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
