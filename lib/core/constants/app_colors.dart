import 'package:flutter/material.dart';

/// App-wide color tokens.
///
/// Organised in three layers, mirroring a modern design-system token
/// architecture:
///
///   * **Primitive**  – raw brand colour ramps (`_indigo500`, `_violet600`, …)
///   * **Semantic**   – purpose aliases (`primary`, `surfaceLight`, …)
///   * **Component**  – ready-to-use gradients for tool cards
///
/// Re-skinning the whole app is a matter of updating the primitive values.
class AppColors {
  AppColors._();

  // ─────────────────────────── Primitive ramps ───────────────────────────

  // Brand: deep indigo → violet (modern, premium, neutral background-friendly).
  static const Color _indigo50 = Color(0xFFEEF2FF);
  static const Color _indigo400 = Color(0xFF818CF8);
  static const Color _indigo500 = Color(0xFF6366F1);
  static const Color _indigo600 = Color(0xFF4F46E5);
  static const Color _indigo700 = Color(0xFF4338CA);

  static const Color _violet500 = Color(0xFF8B5CF6);
  static const Color _violet600 = Color(0xFF7C3AED);

  // Accent: amber (warm complement for CTAs).
  static const Color _amber400 = Color(0xFFFBBF24);
  static const Color _amber500 = Color(0xFFF59E0B);
  static const Color _amber600 = Color(0xFFD97706);

  // Neutrals (Slate scale).
  static const Color _slate50 = Color(0xFFF8FAFC);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate300 = Color(0xFFCBD5E1);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate600 = Color(0xFF475569);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate800 = Color(0xFF1E293B);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate950 = Color(0xFF020617);

  // Status ramps.
  static const Color _green500 = Color(0xFF10B981);
  static const Color _red500 = Color(0xFFEF4444);
  static const Color _amberStatus = Color(0xFFF59E0B);
  static const Color _blue500 = Color(0xFF3B82F6);

  // ─────────────────────────── Semantic tokens ───────────────────────────

  // Brand
  static const Color primary = _indigo600;
  static const Color primaryDark = _indigo700;
  static const Color primaryLight = _indigo400;
  static const Color primarySoft = _indigo50;

  // Secondary / accent
  static const Color secondary = _amber500;
  static const Color secondaryDark = _amber600;
  static const Color secondaryLight = _amber400;

  // Backgrounds
  static const Color backgroundLight = _slate50;
  static const Color backgroundDark = _slate950;
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = _slate900;

  // Status
  static const Color success = _green500;
  static const Color error = _red500;
  static const Color warning = _amberStatus;
  static const Color info = _blue500;

  // Text — light theme
  static const Color textPrimaryLight = _slate900;
  static const Color textSecondaryLight = _slate500;
  static const Color textDisabledLight = _slate300;

  // Text — dark theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = _slate400;
  static const Color textDisabledDark = _slate600;

  // Cards & surfaces
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = _slate800;

  // Dividers / borders
  static const Color dividerLight = _slate200;
  static const Color dividerDark = _slate700;
  static const Color borderLight = _slate200;
  static const Color borderDark = _slate700;

  // ─────────────────────────── Component tokens ───────────────────────────

  // Tool-card gradients (subtle, modern, used as accent washes).
  static const List<Color> gradientBlue = [_indigo500, _indigo600];
  static const List<Color> gradientOrange = [_amber500, _amber600];
  static const List<Color> gradientPurple = [_violet500, _violet600];
  static const List<Color> gradientGreen = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> gradientRed = [Color(0xFFF87171), Color(0xFFDC2626)];
  static const List<Color> gradientTeal = [Color(0xFF14B8A6), Color(0xFF0D9488)];
  static const List<Color> gradientIndigo = [_indigo500, _indigo700];
  static const List<Color> gradientPink = [Color(0xFFEC4899), Color(0xFFDB2777)];
  static const List<Color> gradientCyan = [Color(0xFF06B6D4), Color(0xFF0891B2)];
  static const List<Color> gradientAmber = [_amber400, _amber600];
  static const List<Color> gradientDeepOrange = [Color(0xFFFB923C), Color(0xFFEA580C)];
  static const List<Color> gradientLime = [Color(0xFFA3E635), Color(0xFF65A30D)];

  // Hero / brand gradient — used by app bar and primary banners.
  static const List<Color> heroGradient = [_indigo600, _violet600];

  // Shadows
  static const Color shadowLight = Color(0x1A0F172A);
  static const Color shadowDark = Color(0x40000000);

  // Overlays
  static const Color overlayLight = Color(0x0F0F172A);
  static const Color overlayDark = Color(0x1FFFFFFF);
}
