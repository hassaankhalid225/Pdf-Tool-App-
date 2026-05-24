import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';

/// Shared text styles used outside the Material `Theme`.
///
/// Most typography goes through `Theme.of(context).textTheme` (see
/// `AppTheme`). This file only exposes a small set of context-aware helpers
/// and a handful of named display styles used by widgets that pre-date the
/// theme refactor (empty states, etc.).
class TextStyles {
  TextStyles._();

  // ─────────── Empty-state styles ───────────

  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static const TextStyle emptyStateMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
  );

  // ─────────── Theme-aware helpers ───────────

  static TextStyle getH3(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      letterSpacing: -0.1,
      height: AppDimensions.lineHeightNormal,
    );
  }

  static TextStyle getBody2(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isLight
          ? AppColors.textSecondaryLight
          : AppColors.textSecondaryDark,
      letterSpacing: 0.1,
      height: AppDimensions.lineHeightNormal,
    );
  }
}
