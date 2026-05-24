import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_strings.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/widgets/custom_app_bar.dart';
import 'package:pdf_tool/core/widgets/custom_card.dart';
import 'package:pdf_tool/core/utils/responsive_helper.dart';

/// About screen displaying app information
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.aboutTitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.spacingXl),
              
              // App Logo and Name
              _buildAppHeader(context),
              
              const SizedBox(height: AppDimensions.spacingXl),
              
              // Version Info
              _buildVersionCard(context),
              
              const SizedBox(height: AppDimensions.spacingLg),
              
              // Description
              _buildDescriptionCard(context),
              
              const SizedBox(height: AppDimensions.spacingLg),
              
              // Features
              _buildFeaturesCard(context),
              
              const SizedBox(height: AppDimensions.spacingLg),
              
              // Developer Info
              _buildDeveloperCard(context),
              
              const SizedBox(height: AppDimensions.spacingLg),
              
              // Legal
              _buildLegalCard(context),
              
              const SizedBox(height: AppDimensions.spacingXl),
              
              // Copyright
              _buildCopyright(context),
              
              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientBlue,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          AppStrings.appDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    return InfoCard(
      icon: Icons.info_outline,
      title: 'Version',
      description: AppStrings.appVersion,
      iconColor: AppColors.info,
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'About This App',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'PDF Tools Pro is a comprehensive file conversion application that allows you to convert PDFs to various formats and vice versa. Built with Flutter for a seamless cross-platform experience.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Key Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildFeatureItem(context, 'PDF to Word, Excel, PowerPoint'),
          _buildFeatureItem(context, 'PDF to Image, Text, HTML'),
          _buildFeatureItem(context, 'Image, Word, Text to PDF'),
          _buildFeatureItem(context, 'Fast and secure conversions'),
          _buildFeatureItem(context, 'Beautiful Material Design 3 UI'),
          _buildFeatureItem(context, 'Dark mode support'),
          _buildFeatureItem(context, 'Responsive design for all devices'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: AppDimensions.iconSm,
            color: AppColors.success,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Developer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Developed with ❤️ using Flutter',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Built with clean architecture and best practices',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTermsOfService(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLicenses(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.footerCopyright,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          AppStrings.footerAllRights,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app processes files locally on your device. '
            'No data is sent to external servers unless you explicitly choose to use cloud conversion features. '
            'We do not collect, store, or share your personal information or files.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to use it responsibly and in accordance with applicable laws. '
            'The app is provided "as is" without warranties. We are not liable for any data loss or damages. '
            'You are responsible for backing up your files before conversion.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: AppStrings.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBlue,
          ),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
