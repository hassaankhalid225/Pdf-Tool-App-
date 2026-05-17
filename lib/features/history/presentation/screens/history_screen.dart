import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf_tool/core/widgets/empty_state_widget.dart';
import 'package:pdf_tool/features/conversion/providers/conversion_provider.dart';
import 'package:pdf_tool/features/conversion/models/conversion_model.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

/// History screen displaying past conversions
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = 'All Files';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Files', 
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder, color: colorScheme.primary, size: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search your files...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
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
            
            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCategoryChip('All Files', context),
                  _buildCategoryChip('PDF', context),
                  _buildCategoryChip('Word', context),
                  _buildCategoryChip('Images', context),
                  _buildCategoryChip('Excel', context),
                  _buildCategoryChip('Text', context),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // File List
            Expanded(
              child: Consumer<ConversionProvider>(
                builder: (context, provider, child) {
                  final filteredHistory = provider.conversionHistory.where((c) {
                    // Filter by category
                    bool categoryMatch = _selectedCategory == 'All Files';
                    if (!categoryMatch) {
                      if (_selectedCategory == 'PDF') categoryMatch = c.type.isToPdf;
                      else if (_selectedCategory == 'Word') categoryMatch = c.type.name.contains('Word');
                      else if (_selectedCategory == 'Images') categoryMatch = c.type.name.contains('Image');
                      else if (_selectedCategory == 'Excel') categoryMatch = c.type.name.contains('Excel');
                      else if (_selectedCategory == 'Text') categoryMatch = c.type.name.contains('Text');
                    }

                    // Filter by search
                    bool searchMatch = _searchQuery.isEmpty || 
                        (c.outputFileName ?? c.inputFileName).toLowerCase().contains(_searchQuery);

                    return categoryMatch && searchMatch;
                  }).toList();

                  if (filteredHistory.isEmpty) {
                    return const NoHistoryEmptyState();
                  }

                  // Group by date
                  final today = filteredHistory.where((c) => _isToday(c.startTime)).toList();
                  final yesterday = filteredHistory.where((c) => _isYesterday(c.startTime)).toList();
                  final lastWeek = filteredHistory.where((c) => _isLastWeek(c.startTime)).toList();
                  final older = filteredHistory.where((c) => 
                      !_isToday(c.startTime) && 
                      !_isYesterday(c.startTime) && 
                      !_isLastWeek(c.startTime)
                  ).toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (today.isNotEmpty) ...[
                        _buildSectionHeader('TODAY', context),
                        ...today.map((c) => _buildFileListItem(context, c)),
                        const SizedBox(height: 24),
                      ],
                      if (yesterday.isNotEmpty) ...[
                        _buildSectionHeader('YESTERDAY', context),
                        ...yesterday.map((c) => _buildFileListItem(context, c)),
                        const SizedBox(height: 24),
                      ],
                      if (lastWeek.isNotEmpty) ...[
                        _buildSectionHeader('LAST WEEK', context),
                        ...lastWeek.map((c) => _buildFileListItem(context, c)),
                        const SizedBox(height: 24),
                      ],
                      if (older.isNotEmpty) ...[
                        _buildSectionHeader('OLDER', context),
                        ...older.map((c) => _buildFileListItem(context, c)),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildCategoryChip(String label, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isSelected = _selectedCategory == label;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedCategory = label;
          });
        },
        backgroundColor: theme.brightness == Brightness.dark 
            ? colorScheme.surface 
            : Colors.grey[100],
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected 
              ? Colors.white 
              : colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey[200]!.withValues(alpha: isSelected ? 0 : 1)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFileListItem(BuildContext context, ConversionModel conversion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.read<ConversionProvider>().openFile();
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getFileColor(conversion.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getFileIcon(conversion.type), color: _getFileColor(conversion.type), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversion.outputFileName ?? conversion.inputFileName,
                    style: TextStyle(
                      color: colorScheme.onSurface, 
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${conversion.formattedInputFileSize} • ${DateFormat('hh:mm a').format(conversion.startTime)}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.share, 
                color: colorScheme.onSurface.withValues(alpha: 0.4), 
                size: 20,
              ), 
              onPressed: () {
                context.read<ConversionProvider>().shareFile();
              }
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert, 
                color: colorScheme.onSurface.withValues(alpha: 0.4), 
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  context.read<ConversionProvider>().removeFromHistory(conversion.id);
                } else if (value == 'open') {
                  context.read<ConversionProvider>().openFile();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'open', child: Text('Open')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  bool _isLastWeek(DateTime date) {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return date.isAfter(lastWeek) && !_isToday(date) && !_isYesterday(date);
  }

  void _showClearHistoryDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(
          'Clear History', 
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to clear all conversion history? This action cannot be undone.',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ConversionProvider>().clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
