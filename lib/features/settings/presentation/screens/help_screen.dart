import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFaqItem(
              context,
              'How do I convert a PDF to Word?',
              'Simply go to the Home screen, select "PDF to Word" tool, upload your file, and tap Convert.',
            ),
            _buildFaqItem(
              context,
              'Is my data safe?',
              'Yes! All conversions happen locally on your device or via secure encrypted connections. We do not store your files.',
            ),
            _buildFaqItem(
              context,
              'Can I convert multiple files at once?',
              'Yes, use the "Batch Convert" feature to select multiple files and convert them simultaneously.',
            ),
            _buildFaqItem(
              context,
              'How can I contact support?',
              'You can use the "Contact Us" button on the Settings screen or email support@pdftool.app.',
            ),
             _buildFaqItem(
              context,
              'Where are my files saved?',
              'By default, files are saved in your Downloads folder. You can change this in Settings > Storage.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
