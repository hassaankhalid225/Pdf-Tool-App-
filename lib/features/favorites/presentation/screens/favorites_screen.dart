import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/tools_data.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';
import 'package:pdf_tool/core/widgets/empty_state_widget.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/features/home/presentation/widgets/tool_card_widget.dart';
import 'package:pdf_tool/routes/app_routes.dart';

/// Favorites screen — displays all favorited tools in a grid.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _handleToolTap(BuildContext context, ToolModel tool) {
    AppRoutes.navigateToConversion(context, tool.conversionType);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hPad = ResponsiveHelper.getHorizontalPadding(context);
    final crossAxisCount = ResponsiveHelper.getGridCrossAxisCount(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradientAmber,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final favoriteTools = ToolsData.allTools
                .where((t) => settings.favoriteToolIds.contains(t.id))
                .toList();

            if (favoriteTools.isEmpty) {
              return const NoFavoritesEmptyState();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your most-used tools',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: AppDimensions.gridSpacing,
                      mainAxisSpacing: AppDimensions.gridSpacing,
                      childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
                    ),
                    itemCount: favoriteTools.length,
                    itemBuilder: (context, index) {
                      final tool = favoriteTools[index];
                      return ToolCardWidget(
                        tool: tool,
                        onTap: () => _handleToolTap(context, tool),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
