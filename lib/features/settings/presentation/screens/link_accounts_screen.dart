import 'package:flutter/material.dart';
import 'package:pdf_tool/core/widgets/custom_button.dart';

class LinkAccountsScreen extends StatelessWidget {
  const LinkAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Link Accounts',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAccountItem(context, 'Google', Icons.email, true),
            _buildAccountItem(context, 'Facebook', Icons.facebook, false),
            _buildAccountItem(context, 'Apple', Icons.apple, false),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, String name, IconData icon, bool isConnected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: colorScheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (isConnected)
            const Text(
              'Connected',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          else
            CustomButton(
              text: 'Connect',
              onPressed: () {},
              height: 36,
              width: 100,
            ),
        ],
      ),
    );
  }
}
