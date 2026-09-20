import 'dart:math';
import 'package:flutter/material.dart';

/// A highly realistic custom 3D Agri-PV visualization painter.
/// Features proper perspective projection, detailed solar modules, dynamic shadows,
/// green crop field, and a living sky.
class Agrivoltaic3dPainter extends CustomPainter {
  final double rotationAngle;
  final double zoom;
  final double panelTiltDeg;
  final double rowSpacingM;
  final double timeOfDayHour;

  Agrivoltaic3dPainter({
    this.rotationAngle = 0.35,
    this.zoom = 1.0,
    this.panelTiltDeg = 20.0,
    this.rowSpacingM = 6.0,
    this.timeOfDayHour = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.38;

    // ── 1. SKY ────────────────────────────────────────────────────────────────
    final bool isMorning = timeOfDayHour < 9;
    final bool isEvening = timeOfDayHour > 15;
    final List<Color> skyColors = isMorning
        ? [const Color(0xFFFF9966), const Color(0xFFFFD194), const Color(0xFF87CEEB)]
        : isEvening
            ? [const Color(0xFFFF6B35), const Color(0xFFFFAA44), const Color(0xFF6B8ED6)]
            : [const Color(0xFF2196F3), const Color(0xFF64B5F6), const Color(0xFFBBDEFB), const Color(0xFFE3F2FD)];
    final skyStops = isMorning || isEvening
        ? [0.0, 0.4, 1.0]
        : [0.0, 0.3, 0.7, 1.0];

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: skyColors,
          stops: skyStops,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── 2. SUN ────────────────────────────────────────────────────────────────
    final sunProgress = (timeOfDayHour - 6) / 12.0; // 0 at 6am, 1 at 6pm
    final sunX = w * sunProgress;
    // Parabola: high at noon, low at ends
    final sunY = horizonY - (sin(sunProgress * pi) * horizonY * 0.75);
    final sunColor = isMorning || isEvening ? const Color(0xFFFF9800) : const Color(0xFFFDD835);
    final sunGlowPaint = Paint()
      ..color = sunColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(sunX, sunY), 24, sunGlowPaint);
    canvas.drawCircle(Offset(sunX, sunY), 12, Paint()..color = sunColor);

    // ── 3. CLOUDS ─────────────────────────────────────────────────────────────
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    _drawCloud(canvas, Offset(w * 0.2, horizonY * 0.3), 28, cloudPaint);
    _drawCloud(canvas, Offset(w * 0.65, horizonY * 0.2), 20, cloudPaint);
    _drawCloud(canvas, Offset(w * 0.85, horizonY * 0.45), 16, cloudPaint);

    // ── 4. DISTANT HILLS / TREELINE ───────────────────────────────────────────
    final hillPaint = Paint()..color = const Color(0xFF5C8A4A).withValues(alpha: 0.8);
    final hillPath = Path()
      ..moveTo(0, horizonY + 2)
      ..quadraticBezierTo(w * 0.15, horizonY - 18, w * 0.3, horizonY - 6)
      ..quadraticBezierTo(w * 0.45, horizonY - 28, w * 0.6, horizonY - 10)
      ..quadraticBezierTo(w * 0.75, horizonY - 22, w * 0.9, horizonY - 5)
      ..lineTo(w, horizonY)
      ..lineTo(w, horizonY + 15)
      ..lineTo(0, horizonY + 15)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // ── 5. GROUND FIELD ───────────────────────────────────────────────────────
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF4CAF50), const Color(0xFF388E3C), const Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);

    // Soil path / dirt track in perspective
    final soilPaint = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.5);
    final soilPath = Path()
      ..moveTo(w * 0.47, horizonY)
      ..lineTo(w * 0.53, horizonY)
      ..lineTo(w * 0.65, h)
      ..lineTo(w * 0.35, h)
      ..close();
    canvas.drawPath(soilPath, soilPaint);

    // Perspective crop row lines vanishing at horizon center
    final vp = Offset(w * 0.5, horizonY); // vanishing point
    final rowLinePaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue;
      final bx = w * 0.5 + i * (w / 9.0);
      canvas.drawLine(vp, Offset(bx.clamp(0, w), h.toDouble()), rowLinePaint);
    }

    // ── 6. WHEAT CROP STALKS (perspective-scaled tufts) ───────────────────────
    final rng = Random(12345);
    final wheatPaint = Paint()..strokeCap = StrokeCap.round;
    for (int j = 0; j < 120; j++) {
      final fy = horizonY + 10 + rng.nextDouble() * (h - horizonY - 20);
      final scale = ((fy - horizonY) / (h - horizonY)).clamp(0.1, 1.0);
      // avoid the dirt path in middle
      double fx = rng.nextDouble() * w;
      if (fx > w * 0.42 && fx < w * 0.58) continue;
      final stalkH = 10.0 * scale + rng.nextDouble() * 6 * scale;
      final lean = (rng.nextDouble() - 0.5) * 4;
      wheatPaint.color = const Color(0xFF8BC34A).withValues(alpha: 0.7 + rng.nextDouble() * 0.3);
      wheatPaint.strokeWidth = 1.2 * scale;
      canvas.drawLine(Offset(fx, fy), Offset(fx + lean, fy - stalkH), wheatPaint);
      // wheat head
      canvas.drawCircle(Offset(fx + lean, fy - stalkH), 1.8 * scale,
          Paint()..color = const Color(0xFFCDDC39).withValues(alpha: 0.9));
    }

    // ── 7. SHADOW + 3D STRUCTURE ──────────────────────────────────────────────
    final sunAngle = sunProgress * pi; // 0=east, pi/2=south, pi=west
    final shadowLength = (1.2 - sin(sunAngle)) * 55 * zoom;
    final shadowDirX = -cos(sunAngle - pi * 0.5) * shadowLength;
    final shadowDirY = cos(sunAngle) * shadowLength * 0.4;

    canvas.save();
    // Pivot at a scenic spot on the ground
    final cx = w * 0.5;
    final cy = horizonY + (h - horizonY) * 0.52;
    canvas.translate(cx, cy);
    canvas.scale(zoom);

    // isometric-style view angle driven by rotationAngle
    final viewAngle = pi / 6 + rotationAngle * 0.15; // slight tilt

    // Rows: -1 (back), 0 (mid), +1 (front)
    final rowOffsets = [-1.0, 0.0, 1.0];
    final rowSpacePx = rowSpacingM * 13.0;
    const panelCount = 7;
    const panelWidth = 24.0;
    const panelGap = 2.0;
    const structureHeight = 68.0; // ~2.8 m elevated

    for (int ri = 0; ri < rowOffsets.length; ri++) {
      final rowFactor = rowOffsets[ri];
      // Row position in pseudo-3D isometric space
      final rowBaseX = rowFactor * rowSpacePx * sin(viewAngle) * 0.5;
      final rowBaseY = rowFactor * rowSpacePx * cos(viewAngle) * 0.65;

      // Depth-based scale so back rows look farther
      final depthScale = 1.0 - (rowFactor + 1.0) * 0.06;

      // ── Panel shadow on ground ────────────────────────────────────────────
      final totalPanelWidth = panelCount * (panelWidth + panelGap) - panelGap;
      final shadowAlpha = (0.45 * sin(sunAngle)).clamp(0.1, 0.5);
      final sPaint = Paint()
        ..color = Colors.black.withValues(alpha: shadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final shLeft = -totalPanelWidth * 0.5 + rowBaseX + shadowDirX;
      final shTop = rowBaseY + shadowDirY;
      final shadowRect = Rect.fromLTWH(
        shLeft * depthScale,
        shTop * depthScale,
        totalPanelWidth * depthScale * 1.1,
        18 * depthScale,
      );
      canvas.drawOval(shadowRect, sPaint);

      // ── Steel Stilt Pillars ───────────────────────────────────────────────
      final pillarPaint = Paint()
        ..color = const Color(0xFF90A4AE)
        ..strokeWidth = 3.5 * depthScale
        ..strokeCap = StrokeCap.square;
      final footingPaint = Paint()..color = const Color(0xFF607D8B);

      final pillarXs = [-totalPanelWidth * 0.5, -totalPanelWidth * 0.16,
                         totalPanelWidth * 0.16,  totalPanelWidth * 0.5];
      for (final px in pillarXs) {
        final gx = (px + rowBaseX) * depthScale;
        final gy = rowBaseY * depthScale + 10;
        final tx = gx;
        final ty = gy - structureHeight * depthScale;

        // Concrete footing
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(gx, gy + 3), width: 8 * depthScale, height: 5 * depthScale),
            const Radius.circular(2),
          ),
          footingPaint,
        );
        // Pillar
        canvas.drawLine(Offset(gx, gy), Offset(tx, ty), pillarPaint);
        // Cross brace
        if (px != pillarXs.last) {
          final nxt = pillarXs[pillarXs.indexOf(px) + 1];
          final nGx = (nxt + rowBaseX) * depthScale;
          canvas.drawLine(
            Offset(gx, gy - structureHeight * depthScale * 0.3),
            Offset(nGx, gy - structureHeight * depthScale * 0.7),
            Paint()..color = const Color(0xFF78909C)..strokeWidth = 1.5 * depthScale,
          );
        }
      }

      // ── Longitudinal Torque Tube / Purlins ────────────────────────────────
      final girderY = (rowBaseY * depthScale) + 10 - structureHeight * depthScale;
      final torquePaint = Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 5.0 * depthScale
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset((-totalPanelWidth * 0.55 + rowBaseX) * depthScale, girderY),
        Offset((totalPanelWidth * 0.55 + rowBaseX) * depthScale, girderY),
        torquePaint,
      );

      // ── Solar PV Modules ─────────────────────────────────────────────────
      final tiltRad = panelTiltDeg * pi / 180;
      final panelRiseY = panelWidth * sin(tiltRad) * 0.8;
      final panelRunY = panelWidth * cos(tiltRad) * 0.25;

      for (int pi2 = 0; pi2 < panelCount; pi2++) {
        final startX = (-totalPanelWidth * 0.5 + pi2 * (panelWidth + panelGap));
        final mx = (startX + rowBaseX) * depthScale;
        final mx2 = (startX + panelWidth + rowBaseX) * depthScale;

        // 4 corners of tilted panel in isometric view
        final p1 = Offset(mx, girderY + panelRiseY * depthScale);
        final p2 = Offset(mx2, girderY + panelRiseY * depthScale);
        final p3 = Offset(mx2 + panelRunY * depthScale, girderY - panelRiseY * depthScale * 0.3);
        final p4 = Offset(mx + panelRunY * depthScale, girderY - panelRiseY * depthScale * 0.3);

        final modulePath = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();

        // Solar glass — dark blue with light reflection
        final lightFactor = sin(sunAngle).clamp(0.0, 1.0);
        final baseBlue = const Color(0xFF0D2137);
        final glintBlue = const Color(0xFF1565C0);
        canvas.drawPath(
          modulePath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(baseBlue, glintBlue, lightFactor * 0.5)!,
                baseBlue,
                const Color(0xFF080F1A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromLTRB(p1.dx, p1.dy, p3.dx, p3.dy)),
        );

        // Aluminum frame
        canvas.drawPath(
          modulePath,
          Paint()
            ..color = const Color(0xFFCFD8DC)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4 * depthScale,
        );

        // Cell grid lines (3×6 cells)
        _drawCellGrid(canvas, p1, p2, p3, p4, depthScale);

        // Specular glint
        if (lightFactor > 0.3) {
          final glintPath = Path()
            ..moveTo(p1.dx + (p2.dx - p1.dx) * 0.1, p1.dy + (p4.dy - p1.dy) * 0.15)
            ..lineTo(p1.dx + (p2.dx - p1.dx) * 0.25, p1.dy + (p4.dy - p1.dy) * 0.12)
            ..lineTo(p1.dx + (p2.dx - p1.dx) * 0.22, p1.dy + (p4.dy - p1.dy) * 0.28)
            ..lineTo(p1.dx + (p2.dx - p1.dx) * 0.08, p1.dy + (p4.dy - p1.dy) * 0.30)
            ..close();
          canvas.drawPath(
            glintPath,
            Paint()
              ..color = Colors.white.withValues(alpha: lightFactor * 0.35)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
      }
    }

    canvas.restore();

    // ── 8. ATMOSPHERE / DEPTH OVERLAY ────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 10, w, 20),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, horizonY - 10, w, 20)),
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(Offset(center.dx + r * 0.8, center.dy + r * 0.1), r * 0.75, paint);
    canvas.drawCircle(Offset(center.dx - r * 0.7, center.dy + r * 0.15), r * 0.6, paint);
    canvas.drawRect(
      Rect.fromLTWH(center.dx - r * 1.3, center.dy, r * 2.6, r * 0.5),
      paint,
    );
  }

  void _drawCellGrid(Canvas canvas, Offset p1, Offset p2, Offset p3, Offset p4, double scale) {
    final gridPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.6 * scale;
    const cols = 6;
    const rows = 3;
    for (int c = 1; c < cols; c++) {
      final t = c / cols;
      canvas.drawLine(
        Offset.lerp(p1, p2, t)! ,
        Offset.lerp(p4, p3, t)!,
        gridPaint,
      );
    }
    for (int r = 1; r < rows; r++) {
      final t = r / rows;
      canvas.drawLine(
        Offset.lerp(p1, p4, t)!,
        Offset.lerp(p2, p3, t)!,
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Agrivoltaic3dPainter old) =>
      old.rotationAngle != rotationAngle ||
      old.zoom != zoom ||
      old.panelTiltDeg != panelTiltDeg ||
      old.rowSpacingM != rowSpacingM ||
      old.timeOfDayHour != timeOfDayHour;
}

