import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/features/about/presentation/screens/about_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/help_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/legal_screen.dart';

/// Settings screen — theme-aware, lightweight, no fake account UI.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Hero(),
              const SizedBox(height: 28),
              _SectionHeader(context, 'Appearance'),
              Consumer<SettingsProvider>(
                builder: (context, s, _) {
                  return _SettingTile(
                    icon: Icons.dark_mode_outlined,
                    iconGradient: const [Color(0xFF1E293B), Color(0xFF334155)],
                    title: 'Dark mode',
                    subtitle: 'Switch to the dark Material 3 theme.',
                    trailing: Switch.adaptive(
                      value: s.isDarkMode,
                      onChanged: (v) => s.setDarkMode(v),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              _SectionHeader(context, 'Conversion preferences'),
              Consumer<SettingsProvider>(
                builder: (context, s, _) {
                  return _SettingTile(
                    icon: Icons.high_quality_outlined,
                    iconGradient: AppColors.gradientBlue,
                    title: 'Default quality',
                    subtitle: _qualityLabel(s.defaultQuality),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showQualityDialog(context),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, s, _) {
                  return _SettingTile(
                    icon: Icons.folder_open_rounded,
                    iconGradient: AppColors.gradientOrange,
                    title: 'Save location',
                    subtitle: _locationLabel(s.storageLocation),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showStorageDialog(context),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, s, _) {
                  return _SettingTile(
                    icon: Icons.auto_awesome_motion_outlined,
                    iconGradient: AppColors.gradientGreen,
                    title: 'Open file after convert',
                    subtitle: 'Launch the result in the default app.',
                    trailing: Switch.adaptive(
                      value: s.autoOpenFile,
                      onChanged: (v) => s.setAutoOpenFile(v),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, s, _) {
                  return _SettingTile(
                    icon: Icons.history_rounded,
                    iconGradient: AppColors.gradientPurple,
                    title: 'Keep conversion history',
                    subtitle: 'Show recent files on the home screen.',
                    trailing: Switch.adaptive(
                      value: s.saveHistory,
                      onChanged: (v) => s.setSaveHistory(v),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              _SectionHeader(context, 'Support'),
              _SettingTile(
                icon: Icons.help_outline_rounded,
                iconGradient: AppColors.gradientCyan,
                title: 'Help & FAQ',
                subtitle: 'How tools work, tips, common problems.',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
              ),
              _SettingTile(
                icon: Icons.info_outline_rounded,
                iconGradient: AppColors.gradientIndigo,
                title: 'About this app',
                subtitle: 'Version, credits, licenses.',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader(context, 'Legal'),
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                iconGradient: const [Color(0xFF64748B), Color(0xFF94A3B8)],
                title: 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalScreen(
                      title: 'Privacy Policy',
                      content:
                          'Your files never leave your device. Every conversion runs on-device, '
                          'so the PDFs, Word documents, spreadsheets and images you process stay private. '
                          'We do not collect, transmit, or share your file contents.',
                    ),
                  ),
                ),
              ),
              _SettingTile(
                icon: Icons.description_outlined,
                iconGradient: const [Color(0xFF64748B), Color(0xFF94A3B8)],
                title: 'Terms of Service',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalScreen(
                      title: 'Terms of Service',
                      content:
                          'PDF Tools Pro is provided "as is" without warranty. '
                          'By using the app you agree to use it responsibly and in accordance with '
                          'applicable laws. You remain responsible for your own files — please keep '
                          'backups before converting important documents.',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SettingTile(
                icon: Icons.restore_rounded,
                iconGradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
                title: 'Reset settings',
                subtitle: 'Restore the default preferences.',
                onTap: () => _showResetDialog(context),
              ),

              const SizedBox(height: 18),
              Center(
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Center(
                child: Text(
                  AppStrings.appVersion,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── helpers ───────────────────────

  String _qualityLabel(String q) {
    switch (q) {
      case 'low':
        return 'Low — smaller files, faster';
      case 'medium':
        return 'Medium — balanced';
      default:
        return 'High — best quality';
    }
  }

  String _locationLabel(String loc) {
    switch (loc) {
      case 'documents':
        return 'Documents folder';
      case 'custom':
        return 'Custom location';
      default:
        return 'Downloads folder';
    }
  }

  void _showQualityDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Default quality'),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _quality(ctx, 'high', 'High',
                  'Best quality, slightly larger files', settings),
              _quality(ctx, 'medium', 'Medium',
                  'Balanced size & quality', settings),
              _quality(ctx, 'low', 'Low',
                  'Smaller files, faster conversion', settings),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _quality(BuildContext ctx, String value, String label, String desc,
      SettingsProvider settings) {
    final selected = settings.defaultQuality == value;
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(desc),
      trailing: selected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(ctx).colorScheme.primary)
          : Icon(Icons.radio_button_unchecked_rounded,
              color: Theme.of(ctx).colorScheme.outline),
      onTap: () {
        settings.setDefaultQuality(value);
        Navigator.pop(ctx);
      },
    );
  }

  void _showStorageDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save location'),
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _storage(ctx, 'downloads', 'Downloads', settings),
            _storage(ctx, 'documents', 'Documents', settings),
            _storage(ctx, 'custom', 'Custom', settings),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _storage(BuildContext ctx, String value, String label,
      SettingsProvider settings) {
    final selected = settings.storageLocation == value;
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(ctx).colorScheme.primary)
          : Icon(Icons.radio_button_unchecked_rounded,
              color: Theme.of(ctx).colorScheme.outline),
      onTap: () {
        settings.setStorageLocation(value);
        Navigator.pop(ctx);
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.restore_rounded, size: 36),
        title: const Text('Reset settings?'),
        content: const Text(
          'This will restore quality, save location and other preferences to their defaults. '
          'Your converted files are not affected.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              context.read<SettingsProvider>().resetSettings();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── widgets ───────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: AppColors.gradientBlue,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage('assets/images/app_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Privacy-first conversions, on your device.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _SectionHeader(this.context, this.title);

  final BuildContext context;
  final String title;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconGradient,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colorScheme.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: iconGradient.first.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
