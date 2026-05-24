import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';
import 'package:pdf_tool/core/widgets/empty_state_widget.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/features/conversion/providers/conversion_provider.dart';

/// History screen — modern, theme-aware, searchable & filterable.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Category _category = _Category.all;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontal = ResponsiveHelper.getHorizontalPadding(context);

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
                colors: AppColors.gradientPurple,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder_rounded, color: Colors.white, size: 22),
          ),
        ),
        title: const Text('My Files', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear history',
            onPressed: () => _showClearHistoryDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 0),
              child: _SearchField(
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                itemCount: _Category.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _Category.values[i];
                  return _CategoryChip(
                    label: cat.label,
                    selected: cat == _category,
                    onTap: () => setState(() => _category = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ConversionProvider>(
                builder: (context, provider, child) {
                  final filtered = provider.conversionHistory.where((c) {
                    final matchesCategory = _category.matches(c.type);
                    final search = _searchQuery;
                    final matchesSearch = search.isEmpty ||
                        (c.outputFileName ?? c.inputFileName)
                            .toLowerCase()
                            .contains(search);
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const NoHistoryEmptyState();
                  }

                  final today = filtered.where((c) => _isToday(c.startTime)).toList();
                  final yesterday = filtered.where((c) => _isYesterday(c.startTime)).toList();
                  final lastWeek = filtered.where((c) {
                    return _isLastWeek(c.startTime) &&
                        !_isToday(c.startTime) &&
                        !_isYesterday(c.startTime);
                  }).toList();
                  final older = filtered.where((c) {
                    return !_isToday(c.startTime) &&
                        !_isYesterday(c.startTime) &&
                        !_isLastWeek(c.startTime);
                  }).toList();

                  return ListView(
                    padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 24),
                    children: [
                      if (today.isNotEmpty)
                        _Section(label: 'Today', items: today),
                      if (yesterday.isNotEmpty)
                        _Section(label: 'Yesterday', items: yesterday),
                      if (lastWeek.isNotEmpty)
                        _Section(label: 'Last week', items: lastWeek),
                      if (older.isNotEmpty)
                        _Section(label: 'Older', items: older),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  bool _isLastWeek(DateTime d) =>
      d.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(Icons.delete_sweep_outlined, size: 36),
          title: const Text('Clear all history?'),
          content: const Text(
            'Your converted files in the system will not be deleted. '
            'Only the history list will be cleared.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () {
                context.read<ConversionProvider>().clearHistory();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── widgets ───────────────────────────

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search your files…',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          filled: false,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(colors: AppColors.gradientBlue)
            : null,
        color: selected ? null : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<ConversionModel> items;
  const _Section({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ),
        ...items.map((c) => _FileTile(conversion: c)),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  final ConversionModel conversion;
  const _FileTile({required this.conversion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = _iconGradient(conversion.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (conversion.outputFile != null) {
            context.read<ConversionProvider>().openFileModel(conversion);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _iconFor(conversion.type),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversion.outputFileName ?? conversion.inputFileName,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${conversion.type.displayName}'
                      ' • ${conversion.formattedInputFileSize}'
                      ' • ${DateFormat('hh:mm a').format(conversion.startTime)}',
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
                  Icons.ios_share_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  if (conversion.outputFile != null) {
                    context.read<ConversionProvider>().shareFileModel(conversion);
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onSelected: (value) {
                  final provider = context.read<ConversionProvider>();
                  if (value == 'delete') {
                    provider.removeFromHistory(conversion.id);
                  } else if (value == 'open' && conversion.outputFile != null) {
                    provider.openFileModel(conversion);
                  } else if (value == 'download') {
                    provider.downloadFileModel(conversion);
                  }
                },
                itemBuilder: (context) => [
                  if (conversion.outputFile != null)
                    const PopupMenuItem(
                      value: 'open',
                      child: ListTile(
                        leading: Icon(Icons.open_in_new_rounded),
                        title: Text('Open'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (conversion.outputFile != null)
                    const PopupMenuItem(
                      value: 'download',
                      child: ListTile(
                        leading: Icon(Icons.download_rounded),
                        title: Text('Save to device'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                      title: Text('Remove from history',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ConversionType type) {
    if (type == ConversionType.mergePdf) return Icons.merge_type_rounded;
    if (type.isToPdf) return Icons.picture_as_pdf_rounded;
    final name = type.name.toLowerCase();
    if (name.contains('word')) return Icons.description_rounded;
    if (name.contains('excel')) return Icons.grid_on_rounded;
    if (name.contains('powerpoint')) return Icons.slideshow_rounded;
    if (name.contains('image')) return Icons.image_rounded;
    if (name.contains('html')) return Icons.code_rounded;
    if (name.contains('epub')) return Icons.menu_book_rounded;
    if (name.contains('text')) return Icons.text_snippet_rounded;
    return Icons.insert_drive_file_rounded;
  }

  List<Color> _iconGradient(ConversionType type) {
    if (type == ConversionType.mergePdf) return AppColors.gradientPurple;
    if (type.isToPdf) {
      return const [Color(0xFFEF4444), Color(0xFFF97316)];
    }
    final name = type.name.toLowerCase();
    if (name.contains('word')) return AppColors.gradientBlue;
    if (name.contains('excel')) return AppColors.gradientGreen;
    if (name.contains('powerpoint')) return AppColors.gradientOrange;
    if (name.contains('image')) return AppColors.gradientCyan;
    if (name.contains('html')) return AppColors.gradientIndigo;
    if (name.contains('epub')) return AppColors.gradientPink;
    if (name.contains('text')) return AppColors.gradientTeal;
    return AppColors.gradientBlue;
  }
}

enum _Category {
  all('All Files'),
  pdf('PDF'),
  word('Word'),
  excel('Excel'),
  powerpoint('PowerPoint'),
  image('Images'),
  text('Text & HTML');

  final String label;
  const _Category(this.label);

  bool matches(ConversionType type) {
    final name = type.name.toLowerCase();
    switch (this) {
      case _Category.all:
        return true;
      case _Category.pdf:
        return type.isToPdf || type == ConversionType.mergePdf;
      case _Category.word:
        return name.contains('word');
      case _Category.excel:
        return name.contains('excel');
      case _Category.powerpoint:
        return name.contains('powerpoint');
      case _Category.image:
        return name.contains('image');
      case _Category.text:
        return name.contains('text') ||
            name.contains('html') ||
            name.contains('epub');
    }
  }
}
