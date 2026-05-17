import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/tools_data.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/features/home/presentation/widgets/tool_category_section.dart';
import 'package:pdf_tool/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/features/conversion/providers/conversion_provider.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/providers/navigation_provider.dart';
import 'package:intl/intl.dart';

/// Home screen displaying all conversion tools organized by category
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              AppStrings.homeTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (Greeting & Search)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  vertical: AppDimensions.paddingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyles.getH2(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surface
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: theme.brightness == Brightness.light
                            ? Border.all(color: Colors.grey[200]!)
                            : null,
                      ),
                      child: TextField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search for tools...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          icon: Icon(
                            Icons.search, 
                            size: 20,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Favorites Section
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final favoriteTools = ToolsData.allTools.where(
                    (tool) => settings.favoriteToolIds.contains(tool.id),
                  ).toList();

                  if (favoriteTools.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      ToolCategorySectionWidget(
                        title: 'Favorites',
                        description: 'Your quick access tools',
                        icon: Icons.star,
                        tools: favoriteTools,
                        onToolTap: (tool) => _handleToolTap(context, tool),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                    ],
                  );
                },
              ),

              // From PDF Category
              ToolCategorySectionWidget(
                title: AppStrings.categoryFromPdf,
                description: AppStrings.categoryFromPdfDesc,
                icon: Icons.file_upload,
                tools: ToolsData.fromPdfTools,
                onToolTap: (tool) => _handleToolTap(context, tool),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // To PDF Category
              ToolCategorySectionWidget(
                title: AppStrings.categoryToPdf,
                description: AppStrings.categoryToPdfDesc,
                icon: Icons.file_download,
                tools: ToolsData.toPdfTools,
                onToolTap: (tool) => _handleToolTap(context, tool),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Recent Files Section
              Consumer<ConversionProvider>(
                builder: (context, provider, child) {
                  if (provider.conversionHistory.isEmpty) return const SizedBox.shrink();
                  
                  final recentFiles = provider.conversionHistory.take(3).toList();
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getHorizontalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Files',
                              style: TextStyles.sectionTitle.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<NavigationProvider>().setIndex(1);
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        ...recentFiles.map((file) => _buildRecentFileItem(context, file)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, User';
    if (hour < 17) return 'Good Afternoon, User';
    return 'Good Evening, User';
  }

  void _handleToolTap(BuildContext context, ToolModel tool) {
    AppRoutes.navigateToConversion(context, tool.conversionType);
  }

  Widget _buildRecentFileItem(BuildContext context, ConversionModel conversion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFileColor(conversion.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(conversion.type),
              color: _getFileColor(conversion.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversion.outputFileName ?? conversion.inputFileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${conversion.formattedInputFileSize} • ${DateFormat('MMM dd, hh:mm a').format(conversion.startTime)}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(ConversionType type) {
    if (type.isToPdf) return Icons.picture_as_pdf;
    if (type.name.contains('Word')) return Icons.description;
    if (type.name.contains('Excel')) return Icons.table_chart;
    if (type.name.contains('Image')) return Icons.image;
    return Icons.insert_drive_file;
  }

  Color _getFileColor(ConversionType type) {
    if (type.isToPdf) return Colors.redAccent;
    if (type.name.contains('Word')) return Colors.blueAccent;
    if (type.name.contains('Excel')) return Colors.greenAccent;
    if (type.name.contains('Image')) return Colors.purpleAccent;
    return Colors.grey;
  }
}
