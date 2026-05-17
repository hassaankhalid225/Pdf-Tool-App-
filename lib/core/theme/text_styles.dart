import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';

/// Centralized text styles for the application
class TextStyles {
  TextStyles._(); // Private constructor

  // Headings - Light Theme
  static const TextStyle h1Light = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle h2Light = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle h3Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  // Headings - Dark Theme
  static const TextStyle h1Dark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle h2Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle h3Dark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  // Body Text - Light Theme
  static const TextStyle body1Light = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  static const TextStyle body2Light = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  static const TextStyle captionLight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textDisabledLight,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  // Body Text - Dark Theme
  static const TextStyle body1Dark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  static const TextStyle body2Dark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textDisabledDark,
    letterSpacing: AppDimensions.letterSpacingNormal,
    height: AppDimensions.lineHeightNormal,
  );

  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: AppDimensions.letterSpacingWide,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: AppDimensions.letterSpacingWide,
  );

  // Special Text Styles
  static const TextStyle toolCardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.15,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle toolCardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
    letterSpacing: 0.1,
    height: AppDimensions.lineHeightNormal,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: AppDimensions.lineHeightTight,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: AppDimensions.lineHeightNormal,
  );

  // Status Text
  static const TextStyle statusSuccess = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
    letterSpacing: 0.15,
  );

  static const TextStyle statusError = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    letterSpacing: 0.15,
  );

  static const TextStyle statusWarning = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
    letterSpacing: 0.15,
  );

  static const TextStyle statusInfo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
    letterSpacing: 0.15,
  );

  // File Info Text
  static const TextStyle fileNameLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
    letterSpacing: 0.15,
  );

  static const TextStyle fileNameDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    letterSpacing: 0.15,
  );

  static const TextStyle fileInfoLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
    letterSpacing: 0.1,
  );

  static const TextStyle fileInfoDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryDark,
    letterSpacing: 0.1,
  );

  // Badge Text
  static const TextStyle badgeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Empty State Text
  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle emptyStateMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
  );

  // Helper method to get heading style based on theme
  static TextStyle getH1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? h1Light
        : h1Dark;
  }

  static TextStyle getH2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? h2Light
        : h2Dark;
  }

  static TextStyle getH3(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? h3Light
        : h3Dark;
  }

  static TextStyle getBody1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? body1Light
        : body1Dark;
  }

  static TextStyle getBody2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? body2Light
        : body2Dark;
  }

  static TextStyle getCaption(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? captionLight
        : captionDark;
  }

  static TextStyle getFileName(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? fileNameLight
        : fileNameDark;
  }

  static TextStyle getFileInfo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? fileInfoLight
        : fileInfoDark;
  }
}
