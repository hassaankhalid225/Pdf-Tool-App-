import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';

/// Modern loading overlay used over conversion screens.
///
/// * Soft blurred backdrop (Material 3 scrim feel).
/// * Compact card with gradient progress indicator and optional message.
/// * Pointer events are absorbed while shown so the underlying UI cannot
///   be interacted with mid-conversion.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final double? progress;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: _LoadingScrim(message: message, progress: progress),
          ),
      ],
    );
  }
}

class _LoadingScrim extends StatelessWidget {
  final String? message;
  final double? progress;

  const _LoadingScrim({required this.message, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted = textColor.withValues(alpha: 0.65);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.35),
        alignment: Alignment.center,
        child: AbsorbPointer(
          absorbing: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GradientRing(progress: progress),
                  const SizedBox(height: 18),
                  Text(
                    message ?? 'Working on it…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${(progress!.clamp(0, 1) * 100).round()}%',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientRing extends StatefulWidget {
  final double? progress;

  const _GradientRing({required this.progress});

  @override
  State<_GradientRing> createState() => _GradientRingState();
}

class _GradientRingState extends State<_GradientRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.1415926,
            child: CustomPaint(
              painter: _RingPainter(progress: widget.progress),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double? progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 4.5;

    final track = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.16)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      0,
      6.283185,
      false,
      track,
    );

    final sweep = (progress?.clamp(0, 1).toDouble() ?? 0.35) * 6.283185;
    if (sweep <= 0) return;

    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -1.5707,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
