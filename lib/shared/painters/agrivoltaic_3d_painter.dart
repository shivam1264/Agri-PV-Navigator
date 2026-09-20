import 'dart:math';
import 'package:flutter/material.dart';

/// Custom Painter that renders an isometric 3D Agri-PV system:
/// Elevated steel stilt columns, torque beams, tilted photovoltaic modules,
/// crops growing underneath, and realistic sunlight shadows.
class Agrivoltaic3dPainter extends CustomPainter {
  final double rotationAngle; // in radians, controls 3D viewpoint
  final double zoom;          // 0.8 to 1.5
  final double panelTiltDeg;  // e.g. 20 degrees
  final double rowSpacingM;   // e.g. 6.0 meters
  final double timeOfDayHour; // 6.0 to 18.0 (for dynamic shadow direction)

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

    // 1. Sky & Horizon Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFFD4E9F7), Color(0xFFF3F8FA)],
        stops: [0.0, 0.45, 0.55],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Horizon Line
    final horizonY = h * 0.42;

    // Distant mountain / tree silhouettes
    final hillPaint = Paint()..color = const Color(0xFF6B8E5E);
    final hillPath = Path()
      ..moveTo(0, horizonY)
      ..quadraticBezierTo(w * 0.25, horizonY - 14, w * 0.5, horizonY - 4)
      ..quadraticBezierTo(w * 0.75, horizonY - 20, w, horizonY - 6)
      ..lineTo(w, horizonY + 10)
      ..lineTo(0, horizonY + 10)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // 3. Ground / Crop Field (Lush Green with Perspective Rows)
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3F682F), Color(0xFF2E5321), Color(0xFF234418)],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);

    // Perspective Crop Rows radiating from vanishing point
    final vanishingPoint = Offset(w * 0.5, horizonY);
    final cropRowPaint = Paint()
      ..color = const Color(0x334CAF50)
      ..strokeWidth = 3.0;

    for (int i = -8; i <= 8; i++) {
      final bottomX = (w * 0.5) + (i * (w / 7.5));
      canvas.drawLine(vanishingPoint, Offset(bottomX, h), cropRowPaint);
    }

    // Wheat texture / tufts on ground
    final wheatPaint = Paint()..color = const Color(0xFF7CB342);
    final random = Random(42);
    for (int j = 0; j < 60; j++) {
      final y = horizonY + 15 + random.nextDouble() * (h - horizonY - 30);
      final scale = (y - horizonY) / (h - horizonY);
      final x = random.nextDouble() * w;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + (random.nextDouble() * 4 - 2), y - (6 * scale)),
        wheatPaint..strokeWidth = 1.2 * scale,
      );
    }

    // 4. Calculate Sun & Shadow Vector
    final sunAngle = ((timeOfDayHour - 6) / 12.0) * pi; // 0 at 6am, pi/2 at 12pm, pi at 6pm
    final shadowOffsetX = -cos(sunAngle) * 55 * zoom;
    final shadowOffsetY = (1.1 - sin(sunAngle)) * 30 * zoom;

    // 5. Draw Agri-PV Elevated Structure (Rows of Panels)
    canvas.save();
    canvas.translate(w * 0.5, h * 0.60);
    canvas.scale(zoom);

    // Dynamic rotation offset
    final rotCos = cos(rotationAngle);
    final rotSin = sin(rotationAngle);

    // 3 parallel elevated rows
    final rowSpacing = (rowSpacingM * 11.0);
    final rows = [-1.0, 0.0, 1.0];

    for (final rowIdx in rows) {
      final baseRowY = rowIdx * rowSpacing * rotCos;
      final baseRowX = rowIdx * rowSpacing * rotSin * 0.7;

      // 4 mounting stilt pillars per row
      final pillarXPositions = [-90.0, -30.0, 30.0, 90.0];
      const pillarHeight = 70.0; // elevated ~2.8 meters representation

      // --- Draw Shadows of Panels on Ground ---
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      final shadowPath = Path();
      final sX1 = -110.0 + baseRowX + shadowOffsetX;
      final sY1 = baseRowY + 10 + shadowOffsetY;
      final sX2 = 110.0 + baseRowX + shadowOffsetX;
      final sY2 = baseRowY + 10 + shadowOffsetY;
      final sX3 = 105.0 + baseRowX + shadowOffsetX + 20;
      final sY3 = baseRowY + 45 + shadowOffsetY;
      final sX4 = -115.0 + baseRowX + shadowOffsetX + 20;
      final sY4 = baseRowY + 45 + shadowOffsetY;

      shadowPath.moveTo(sX1, sY1);
      shadowPath.lineTo(sX2, sY2);
      shadowPath.lineTo(sX3, sY3);
      shadowPath.lineTo(sX4, sY4);
      shadowPath.close();
      canvas.drawPath(shadowPath, shadowPaint);

      // --- Draw Vertical Steel Pilings (Stilts) ---
      final steelPillarPaint = Paint()
        ..color = const Color(0xFF8899A6)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.square;

      final pillarBasePaint = Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.fill;

      for (final px in pillarXPositions) {
        final groundX = px + baseRowX;
        final groundY = baseRowY + 15;
        final topX = groundX;
        final topY = groundY - pillarHeight;

        // Concrete footings at ground
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(groundX, groundY), width: 9, height: 6),
            const Radius.circular(2),
          ),
          pillarBasePaint,
        );

        // Steel stilt post
        canvas.drawLine(Offset(groundX, groundY), Offset(topX, topY), steelPillarPaint);

        // Cross-bracing struts for agricultural clearance stability
        canvas.drawLine(
          Offset(groundX, groundY - 15),
          Offset(groundX + 12, topY + 15),
          Paint()..color = const Color(0xFF64748B)..strokeWidth = 2.0,
        );
      }

      // --- Longitudinal Torque Tube / Girder ---
      final girderY = baseRowY + 15 - pillarHeight;
      canvas.drawLine(
        Offset(-115.0 + baseRowX, girderY),
        Offset(115.0 + baseRowX, girderY),
        Paint()
          ..color = const Color(0xFFB0BEC5)
          ..strokeWidth = 5.0,
      );

      // --- Solar PV Modules on Racking ---
      // Tilted rectangular modules
      final tiltRad = (panelTiltDeg) * (pi / 180);
      final panelTiltHeight = 35.0 * cos(tiltRad);

      for (double px = -110; px <= 80; px += 34) {
        final mx1 = px + baseRowX;
        final my1 = girderY - (panelTiltHeight * 0.5);
        final mx2 = px + 30 + baseRowX;
        final my2 = girderY - (panelTiltHeight * 0.5);
        final mx3 = px + 28 + baseRowX + (rotSin * 10);
        final my3 = girderY + (panelTiltHeight * 0.5);
        final mx4 = px - 2 + baseRowX + (rotSin * 10);
        final my4 = girderY + (panelTiltHeight * 0.5);

        final modulePath = Path()
          ..moveTo(mx1, my1)
          ..lineTo(mx2, my2)
          ..lineTo(mx3, my3)
          ..lineTo(mx4, my4)
          ..close();

        // Deep Solar Blue with Glass Reflection
        final pvPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF172554), Color(0xFF0F172A)],
          ).createShader(Rect.fromLTRB(mx1, my1, mx3, my3));
        canvas.drawPath(modulePath, pvPaint);

        // Silver Anodized Aluminum Frame
        canvas.drawPath(
          modulePath,
          Paint()
            ..color = const Color(0xFFCBD5E1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );

        // Silicon solar cell grid lines
        final midY = (my1 + my3) / 2;
        canvas.drawLine(
          Offset((mx1 + mx4) / 2, midY),
          Offset((mx2 + mx3) / 2, midY),
          Paint()..color = const Color(0x33FFFFFF)..strokeWidth = 0.8,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Agrivoltaic3dPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panelTiltDeg != panelTiltDeg ||
        oldDelegate.rowSpacingM != rowSpacingM ||
        oldDelegate.timeOfDayHour != timeOfDayHour;
  }
}
