import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScoreArcPainter extends CustomPainter {
  final double score; // 0 to 100
  final Color activeColor;
  final Color backgroundColor;

  ScoreArcPainter({
    required this.score,
    this.activeColor = AppColors.primary,
    this.backgroundColor = const Color(0xFFE5E7EB),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Semicircular / 240-degree open gauge
    const startAngle = 150 * (pi / 180);
    const sweepTotalAngle = 240 * (pi / 180);

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotalAngle,
      false,
      bgPaint,
    );

    // Active progress arc
    final progressSweep = (score / 100.0) * sweepTotalAngle;
    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScoreArcPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}
