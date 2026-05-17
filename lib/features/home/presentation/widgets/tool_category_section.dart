import 'package:flutter/material.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';
import 'package:pdf_tool/features/home/presentation/widgets/tool_card_widget.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/theme/text_styles.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';

/// Widget displaying a category section with a grid of tool cards
class ToolCategorySectionWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<ToolModel> tools;
  final Function(ToolModel) onToolTap;

  const ToolCategorySectionWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.tools,
    required this.onToolTap,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getGridCrossAxisCount(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyles.sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/tool_category',
                    arguments: {
                      'title': title,
                      'tools': tools,
                    },
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.spacingMd),
        
        // Tools Grid
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppDimensions.gridSpacing,
              mainAxisSpacing: AppDimensions.gridSpacing,
              childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return ToolCardWidget(
                tool: tool,
                onTap: () => onToolTap(tool),
              );
            },
          ),
        ),
      ],
    );
  }
}
