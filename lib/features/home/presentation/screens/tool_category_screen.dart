import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/features/home/presentation/widgets/tool_card_widget.dart';
import 'package:pdf_tool/routes/app_routes.dart';

class ToolCategoryScreen extends StatefulWidget {
  final String title;
  final List<ToolModel> tools;

  const ToolCategoryScreen({
    super.key,
    required this.title,
    required this.tools,
  });

  @override
  State<ToolCategoryScreen> createState() => _ToolCategoryScreenState();
}

class _ToolCategoryScreenState extends State<ToolCategoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final filteredTools = widget.tools.where((tool) {
      return tool.title.toLowerCase().contains(_searchQuery) ||
          tool.description.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title, 
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getHorizontalPadding(context),
                vertical: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark 
                      ? colorScheme.surface 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: theme.brightness == Brightness.light
                      ? Border.all(color: Colors.grey[200]!)
                      : null,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search tools in this category...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search, 
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredTools.isEmpty
                  ? Center(
                      child: Text(
                        'No tools found',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                        crossAxisSpacing: AppDimensions.gridSpacing,
                        mainAxisSpacing: AppDimensions.gridSpacing,
                        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
                      ),
                      itemCount: filteredTools.length,
                      itemBuilder: (context, index) {
                        final tool = filteredTools[index];
                        return ToolCardWidget(
                          tool: tool,
                          onTap: () => AppRoutes.navigateToConversion(context, tool.conversionType),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
