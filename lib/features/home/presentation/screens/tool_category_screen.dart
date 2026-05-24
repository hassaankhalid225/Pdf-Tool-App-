import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:pdf_tool/core/constants/app_dimensions.dart';
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final horizontal = ResponsiveHelper.getHorizontalPadding(context);

    final filtered = widget.tools.where((tool) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return tool.title.toLowerCase().contains(q) ||
          tool.description.toLowerCase().contains(q) ||
          tool.subtitle.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title.toLowerCase()}…',
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    filled: false,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.search_x,
                            size: 48,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tools match "$_query"',
                            style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            ResponsiveHelper.getGridCrossAxisCount(context),
                        crossAxisSpacing: AppDimensions.gridSpacing,
                        mainAxisSpacing: AppDimensions.gridSpacing,
                        childAspectRatio:
                            ResponsiveHelper.getCardAspectRatio(context),
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final tool = filtered[index];
                        return ToolCardWidget(
                          tool: tool,
                          onTap: () => AppRoutes.navigateToConversion(
                            context,
                            tool.conversionType,
                          ),
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
