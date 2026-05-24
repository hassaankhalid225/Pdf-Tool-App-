import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/tools_data.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';
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

/// Home screen — modern hero header, search, favorites and tool categories.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  } 

  @override 
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hPad = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredFromPdf = _filterTools(ToolsData.fromPdfTools);
    final filteredToPdf = _filterTools(ToolsData.toPdfTools);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
                child: _HeroHeader(
                  onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
                  searchController: _searchCtrl,
                  onSearchChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ─── Quick stats / hero stat chips ───
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                child: Consumer<ConversionProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: LucideIcons.zap,
                            label: 'Tools',
                            value: '${ToolsData.allTools.length}',
                            gradient: AppColors.gradientIndigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: LucideIcons.history,
                            label: 'Converted',
                            value: '${provider.conversionHistory.length}',
                            gradient: AppColors.gradientPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: LucideIcons.star,
                            label: 'Favorites',
                            value:
                                '${context.watch<SettingsProvider>().favoriteToolIds.length}',
                            gradient: AppColors.gradientAmber,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Favorites section is now on its own tab in the bottom navigation bar

            // ─── From PDF ───
            if (filteredFromPdf.isNotEmpty)
              SliverToBoxAdapter(
                child: ToolCategorySectionWidget(
                  title: AppStrings.categoryFromPdf,
                  description: AppStrings.categoryFromPdfDesc,
                  icon: LucideIcons.file_up,
                  tools: filteredFromPdf,
                  onToolTap: (t) => _handleToolTap(context, t),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ─── To PDF ───
            if (filteredToPdf.isNotEmpty)
              SliverToBoxAdapter(
                child: ToolCategorySectionWidget(
                  title: AppStrings.categoryToPdf,
                  description: AppStrings.categoryToPdfDesc,
                  icon: LucideIcons.file_down,
                  tools: filteredToPdf,
                  onToolTap: (t) => _handleToolTap(context, t),
                ),
              ),

            if (filteredFromPdf.isEmpty && filteredToPdf.isEmpty && _query.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(LucideIcons.search_x,
                          size: 56,
                          color: colorScheme.onSurface.withValues(alpha: 0.35)),
                      const SizedBox(height: 12),
                      Text(
                        'No tools match "${_searchCtrl.text}"',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ─── Recent files ───
            SliverToBoxAdapter(
              child: Consumer<ConversionProvider>(
                builder: (context, provider, _) {
                  if (provider.conversionHistory.isEmpty || _query.isNotEmpty) {
                    return const SizedBox.shrink();
                  }
                  final recent = provider.conversionHistory.take(3).toList();
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent files',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<NavigationProvider>().setIndex(2),
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...recent.map(
                          (file) => _RecentFileTile(
                            conversion: file,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  List<ToolModel> _filterTools(List<ToolModel> tools) {
    if (_query.isEmpty) return tools;
    return tools
        .where((t) =>
            t.title.toLowerCase().contains(_query) ||
            t.subtitle.toLowerCase().contains(_query) ||
            t.description.toLowerCase().contains(_query))
        .toList();
  }

  void _handleToolTap(BuildContext context, ToolModel tool) {
    AppRoutes.navigateToConversion(context, tool.conversionType);
  }
}

// ────────────────────────────── widgets ──────────────────────────────

class _HeroHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _HeroHeader({
    required this.onSettingsTap,
    required this.searchController,
    required this.onSearchChanged,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveHelper.getHorizontalPadding(context);
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, topInset + 12, hPad, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                AppStrings.homeTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              _CircleIconButton(
                icon: LucideIcons.bell,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: LucideIcons.settings,
                onTap: onSettingsTap,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _greeting(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'What would you like\nto convert today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          _SearchField(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Search any tool — e.g. "to Word"',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(LucideIcons.x, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFileTile extends StatelessWidget {
  final ConversionModel conversion;
  final bool isDark;
  const _RecentFileTile({required this.conversion, required this.isDark});

  IconData _icon(ConversionType type) {
    if (type.isToPdf) return LucideIcons.file_text;
    if (type.name.contains('Word')) return LucideIcons.file_text;
    if (type.name.contains('Excel')) return LucideIcons.file_spreadsheet;
    if (type.name.contains('Image')) return LucideIcons.image;
    return LucideIcons.file;
  }

  List<Color> _gradient(ConversionType type) {
    if (type.isToPdf) return AppColors.gradientRed;
    if (type.name.contains('Word')) return AppColors.gradientBlue;
    if (type.name.contains('Excel')) return AppColors.gradientGreen;
    if (type.name.contains('Image')) return AppColors.gradientPurple;
    return AppColors.gradientIndigo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = _gradient(conversion.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (conversion.outputFile != null) {
              context.read<ConversionProvider>().openFileModel(conversion);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon(conversion.type),
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversion.outputFileName ?? conversion.inputFileName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${conversion.formattedInputFileSize} • '
                        '${DateFormat('MMM dd, hh:mm a').format(conversion.startTime)}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.share_2,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    size: 20,
                  ),
                  onPressed: () =>
                      context.read<ConversionProvider>().shareFileModel(conversion),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
