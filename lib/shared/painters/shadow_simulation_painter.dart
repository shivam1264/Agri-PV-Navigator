import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Painter for Screen 12 (Shadow Simulation):
/// Shows elevated solar panel arrays over agricultural crop rows with a dynamic sun arc
/// that casts accurate panel shadows across the crops based on the time-of-day slider.
class ShadowSimulationPainter extends CustomPainter {
  final double timeOfDayHour; // 6.0 to 18.0 (6 AM to 6 PM)
  final double rowSpacing;    // e.g. 6.0 meters

  ShadowSimulationPainter({
    required this.timeOfDayHour,
    this.rowSpacing = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sky & Sun Atmosphere
    // Sky color shifts warmer at dawn/dusk and bright blue at noon
    final noonFactor = 1.0 - (pow((timeOfDayHour - 12.0) / 6.0, 2)).clamp(0.0, 1.0);

    final skyColors = [
      Color.lerp(const Color(0xFFFFB74D), const Color(0xFF60A5FA), noonFactor)!,
      Color.lerp(const Color(0xFFFFE0B2), const Color(0xFFBFDBFE), noonFactor)!,
      Color.lerp(const Color(0xFFFFF3E0), const Color(0xFFEFF6FF), noonFactor)!,
    ];

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyColors,
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.45), skyPaint);

    // 2. Draw Sun Arc and Sun Position
    final sunProgress = ((timeOfDayHour - 6.0) / 12.0).clamp(0.0, 1.0);
    // Elliptical arc across the sky
    final sunAngle = pi * (1.0 - sunProgress);
    final sunX = (w * 0.15) + (w * 0.70 * sunProgress);
    final sunY = (h * 0.38) - (sin(sunAngle) * (h * 0.28));

    // Sun Rays / Glow
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.solar,
          AppColors.solar.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 36));
    canvas.drawCircle(Offset(sunX, sunY), 36, sunGlowPaint);

    // Sun Disk
    canvas.drawCircle(
      Offset(sunX, sunY),
      14,
      Paint()..color = const Color(0xFFFFFBEB),
    );
    canvas.drawCircle(
      Offset(sunX, sunY),
      12,
      Paint()..color = AppColors.solar,
    );

    // 3. Ground / Crop Field (Perspective View)
    final horizonY = h * 0.42;
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E5321), Color(0xFF1E3A15), Color(0xFF14270E)],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);

    // 4. Crop Rows (Lush agricultural planting rows)
    final cropRowPaint = Paint()
      ..color = const Color(0xFF437530)
      ..strokeWidth = 2.5;

    final vp = Offset(w * 0.5, horizonY);
    for (int i = -6; i <= 6; i++) {
      final bx = (w * 0.5) + (i * (w / 6.0));
      canvas.drawLine(vp, Offset(bx, h), cropRowPaint);
    }

    // 5. Shadow Calculation based on Sun Angle
    // Sun on left (morning) casts shadows to the right (+X)
    // Sun on right (afternoon) casts shadows to the left (-X)
    // Sun overhead (noon) casts short, centered shadows
    final shadowDirection = (12.0 - timeOfDayHour); // >0 morning (right shadow), <0 afternoon (left shadow)
    final shadowLengthX = (shadowDirection * 9.0).clamp(-75.0, 75.0);
    final shadowLengthY = (24.0 + (shadowDirection.abs() * 3.5)).clamp(15.0, 50.0);

    // 6. Draw 2 Elevated Solar Array Rows
    final arrayRows = [
      (baseY: horizonY + 50.0, width: w * 0.72, height: 42.0, scale: 0.8),
      (baseY: horizonY + 120.0, width: w * 0.88, height: 60.0, scale: 1.0),
    ];

    for (final arr in arrayRows) {
      final rowY = arr.baseY;
      final rowWidth = arr.width;
      final startX = (w - rowWidth) / 2;
      final endX = startX + rowWidth;

      // Draw Ground Shadow Cast By Solar Array
      final shadowPath = Path()
        ..moveTo(startX + shadowLengthX, rowY + 12 + shadowLengthY)
        ..lineTo(endX + shadowLengthX, rowY + 12 + shadowLengthY)
        ..lineTo(endX + (shadowLengthX * 0.8), rowY + 12)
        ..lineTo(startX + (shadowLengthX * 0.8), rowY + 12)
        ..close();

      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.42)
          ..style = PaintingStyle.fill,
      );

      // Stilt Posts (Elevated 2.8m columns)
      final postPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 3.5 * arr.scale;

      const numPosts = 5;
      final step = rowWidth / (numPosts - 1);
      for (int p = 0; p < numPosts; p++) {
        final px = startX + (p * step);
        final postTop = rowY - arr.height;
        // Foundation
        canvas.drawCircle(Offset(px, rowY + 6), 4.0 * arr.scale, Paint()..color = const Color(0xFF475569));
        // Column
        canvas.drawLine(Offset(px, rowY + 6), Offset(px, postTop), postPaint);
      }

      // Longitudinal Cross-Girder
      final postTopY = rowY - arr.height;
      canvas.drawLine(
        Offset(startX - 10, postTopY),
        Offset(endX + 10, postTopY),
        Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 4.0 * arr.scale,
      );

      // Solar Panels
      final panelModuleWidth = (step * 0.85);
      for (int m = 0; m < numPosts - 1; m++) {
        final mx = startX + (m * step) + (step * 0.08);
        final my = postTopY - (12 * arr.scale);
        final panelRect = Rect.fromLTWH(mx, my, panelModuleWidth, 24 * arr.scale);

        // Photovoltaic cell gradient
        final panelPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          ).createShader(panelRect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(2)),
          panelPaint,
        );

        // Aluminum frame
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(2)),
          Paint()
            ..color = const Color(0xFFE2E8F0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ShadowSimulationPainter oldDelegate) {
    return oldDelegate.timeOfDayHour != timeOfDayHour ||
        oldDelegate.rowSpacing != rowSpacing;
  }
}
