import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf_tool/core/providers/settings_provider.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/change_password_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/subscription_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/help_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/legal_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/link_accounts_screen.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile', 
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context),
              const SizedBox(height: 32),
              
              // Account Settings
              _buildSectionHeader(context, 'ACCOUNT SETTINGS'),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen())),
                child: _buildSettingItem(context, Icons.lock, 'Change Password', color: Colors.blue),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LinkAccountsScreen())),
                child: _buildSettingItem(context, Icons.link, 'Link Accounts', color: Colors.purple),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SubscriptionScreen())),
                child: _buildSettingItem(
                  context,
                  Icons.workspace_premium, 
                  'Subscription Plan', 
                  color: Colors.orange, 
                  trailingText: 'Manage',
                  trailingTextColor: Colors.blue,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Settings
              _buildSectionHeader(context, 'APP SETTINGS'),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return _buildSettingItem(
                    context,
                    Icons.dark_mode, 
                    'Dark Mode', 
                    color: Colors.blueGrey,
                    trailing: Switch(
                      value: settings.isDarkMode,
                      activeColor: colorScheme.primary,
                      onChanged: (value) => settings.setDarkMode(value),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return _buildSettingItem(
                    context,
                    Icons.notifications, 
                    'Notifications', 
                    color: Colors.redAccent,
                    trailing: Switch(
                      value: settings.showNotifications,
                      activeColor: colorScheme.primary,
                      onChanged: (value) => settings.setNotifications(value),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return InkWell(
                    onTap: () => _showLanguageDialog(context),
                    child: _buildSettingItem(
                      context,
                      Icons.language, 
                      'Language', 
                      color: Colors.teal, 
                      trailingText: _getLanguageName(settings.language),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return InkWell(
                    onTap: () => _showQualityDialog(context),
                    child: _buildSettingItem(
                      context,
                      Icons.high_quality, 
                      'Quality', 
                      color: Colors.blue, 
                      trailingText: _getQualityName(settings.defaultQuality),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return InkWell(
                    onTap: () => _showStorageLocationDialog(context),
                    child: _buildSettingItem(
                      context,
                      Icons.folder_open, 
                      'Storage', 
                      color: Colors.amber, 
                      trailingText: _getStorageLocationName(settings.storageLocation),
                    ),
                  );
                },
              ),
              InkWell(
                onTap: () => _showResetDialog(context),
                child: _buildSettingItem(context, Icons.restore, 'Reset Settings', color: Colors.red),
              ),
              
              const SizedBox(height: 24),
              
              // Support
              _buildSectionHeader(context, 'SUPPORT'),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpScreen())),
                child: _buildSettingItem(context, Icons.help, 'Help & FAQ', color: Colors.green),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Contact Us'),
                      content: const Text('Please email us at support@pdftool.app for any inquiries.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                    ),
                  );
                }, 
                child: _buildSettingItem(context, Icons.email, 'Contact Us', color: Colors.indigo),
              ),
              
              const SizedBox(height: 24),
              
              // Legal
              _buildSectionHeader(context, 'LEGAL'),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LegalScreen(title: 'Privacy Policy', content: 'Privacy Policy Content Here...'))),
                child: _buildSettingItem(context, Icons.security, 'Privacy Policy', color: Colors.blueGrey),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LegalScreen(title: 'Terms of Service', content: 'Terms of Service Content Here...'))),
                child: _buildSettingItem(context, Icons.description, 'Terms of Service', color: Colors.blueGrey),
              ),
              
              const SizedBox(height: 40),
              
              // Sign Out Button
              _buildSignOutButton(context),
              
              const SizedBox(height: 16),
              Text(
                'App Version 2.4.0',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5), 
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  child: Icon(
                    Icons.edit, 
                    size: 14, 
                    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Alex Morgan',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'alex.morgan@example.com',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'PRO Member',
            style: TextStyle(
              color: colorScheme.primary, 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon, 
    String title, {
    required Color color, 
    Widget? trailing,
    String? trailingText,
    Color? trailingTextColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface, 
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  color: trailingTextColor ?? colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right, 
              color: colorScheme.onSurface.withValues(alpha: 0.3), 
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }



  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }

  String _getQualityName(String quality) {
    switch (quality) {
      case 'low':
        return 'Low (Smaller file size)';
      case 'medium':
        return 'Medium (Balanced)';
      case 'high':
        return 'High (Best quality)';
      default:
        return 'High (Best quality)';
    }
  }

  String _getStorageLocationName(String location) {
    switch (location) {
      case 'downloads':
        return 'Downloads folder';
      case 'documents':
        return 'Documents folder';
      case 'custom':
        return 'Custom location';
      default:
        return 'Downloads folder';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Select Language', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'en', 'English', settings),
            _buildLanguageOption(context, 'es', 'Español', settings),
            _buildLanguageOption(context, 'fr', 'Français', settings),
            _buildLanguageOption(context, 'de', 'Deutsch', settings),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    SettingsProvider settings,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey,
      ),
      child: RadioListTile<String>(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        value: code,
        groupValue: settings.language,
        activeColor: AppColors.primary,
        onChanged: (value) {
          if (value != null) {
            settings.setLanguage(value);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Select Quality', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption(context, 'low', 'Low', settings),
            _buildQualityOption(context, 'medium', 'Medium', settings),
            _buildQualityOption(context, 'high', 'High', settings),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption(
    BuildContext context,
    String quality,
    String name,
    SettingsProvider settings,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey,
      ),
      child: RadioListTile<String>(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(_getQualityName(quality), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        value: quality,
        groupValue: settings.defaultQuality,
        activeColor: AppColors.primary,
        onChanged: (value) {
          if (value != null) {
            settings.setDefaultQuality(value);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showStorageLocationDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Select Storage Location', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStorageOption(context, 'downloads', 'Downloads', settings),
            _buildStorageOption(context, 'documents', 'Documents', settings),
            _buildStorageOption(context, 'custom', 'Custom', settings),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageOption(
    BuildContext context,
    String location,
    String name,
    SettingsProvider settings,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey,
      ),
      child: RadioListTile<String>(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        value: location,
        groupValue: settings.storageLocation,
        activeColor: AppColors.primary,
        onChanged: (value) {
          if (value != null) {
            settings.setStorageLocation(value);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default'),
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
