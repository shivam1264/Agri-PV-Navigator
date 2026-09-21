import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Custom Painter that renders an aerial satellite farm view with an overlaid polygon boundary,
/// corner vertex pins, and area badge — exactly like Screen 06 & Screen 08 in the reference design.
class FarmBoundaryPainter extends CustomPainter {
  final double areaAcres;
  final bool showPins;
  final bool interactive;
  final bool drawBackground;
  final List<Offset> points;
  final double zoomScale;

  FarmBoundaryPainter({
    this.areaAcres = 2.35,
    this.showPins = true,
    this.interactive = false,
    this.drawBackground = true,
    this.points = const [],
    this.zoomScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    // Zoom around the center
    canvas.translate(w / 2, h / 2);
    canvas.scale(zoomScale, zoomScale);
    canvas.translate(-w / 2, -h / 2);
    try {

    // 1. Draw Satellite Landscape Background if enabled
    if (drawBackground) {
      final bgPaint = Paint()..style = PaintingStyle.fill;
      bgPaint.color = const Color(0xFF2E4822);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Surrounding field textures / parcel patches
    final fieldPatches = [
      (Rect.fromLTWH(0, 0, w * 0.45, h * 0.4), const Color(0xFF385528)),
      (Rect.fromLTWH(w * 0.45, 0, w * 0.55, h * 0.35), const Color(0xFF2B4120)),
      (Rect.fromLTWH(0, h * 0.4, w * 0.3, h * 0.6), const Color(0xFF4A6B32)),
      (Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.25, h * 0.65), const Color(0xFF324D23)),
      (Rect.fromLTWH(0, h * 0.75, w, h * 0.25), const Color(0xFF263A1D)),
    ];

    for (final patch in fieldPatches) {
      bgPaint.color = patch.$2;
      canvas.drawRect(patch.$1, bgPaint);
    }

    // Draw field plow lines / crop rows
    final rowPaint = Paint()
      ..color = const Color(0x221B3012)
      ..strokeWidth = 2.0;
    for (double y = 10; y < h; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(w, y), rowPaint);
    }

    // Draw agricultural tree clusters on margins
    final treePaint = Paint()..color = const Color(0xFF1B3315);
    final treePositions = [
      Offset(w * 0.1, h * 0.15),
      Offset(w * 0.15, h * 0.12),
      Offset(w * 0.85, h * 0.2),
      Offset(w * 0.9, h * 0.25),
      Offset(w * 0.08, h * 0.85),
      Offset(w * 0.88, h * 0.8),
    ];
    for (final pos in treePositions) {
      canvas.drawCircle(pos, 14, treePaint);
      canvas.drawCircle(pos + const Offset(4, -3), 10, Paint()..color = const Color(0xFF2D5023));
    }
    }

    // 2. Main Farm Polygon Coordinates
    if (points.isEmpty) return;
    if (points.any((p) => !p.dx.isFinite || !p.dy.isFinite)) return;

    final polygonPath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      polygonPath.lineTo(points[i].dx, points[i].dy);
    }
    polygonPath.close();

    // 3. Polygon Semi-Transparent Fill (Bright Agri Green overlay)
    final fillPaint = Paint()
      ..color = const Color(0x5508783E)
      ..style = PaintingStyle.fill;
    canvas.drawPath(polygonPath, fillPaint);

    // 4. Polygon Boundary Outline (Vibrant Green)
    final borderPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polygonPath, borderPaint);

    // Inner subtle glow/dash
    final innerGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polygonPath, innerGlowPaint);

    // 5. Corner Vertex Anchor Pins
    if (showPins) {
      final pinOuterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final pinInnerPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      for (final p in points) {
        canvas.drawCircle(p, 8.0, pinOuterPaint);
        canvas.drawCircle(p, 4.5, pinInnerPaint);
      }
    }

    // 6. Center Area Badge Pill (e.g. "2.35 acres")
    double sumX = 0;
    double sumY = 0;
    for (final p in points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    final center = Offset(sumX / points.length, sumY / points.length);

    final badgeText = '${areaAcres.toStringAsFixed(2)} acres';
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    final textSpan = TextSpan(text: badgeText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 24;
    final badgeHeight = textPainter.height + 14;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: badgeWidth, height: badgeHeight),
      const Radius.circular(20),
    );

    // Badge Shadow
    canvas.drawRRect(
      badgeRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Badge Background (Deep Green)
    canvas.drawRRect(
      badgeRect,
      Paint()..color = const Color(0xEE08783E),
    );

    // Badge White Border
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw Text
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FarmBoundaryPainter oldDelegate) {
    return oldDelegate.areaAcres != areaAcres ||
        oldDelegate.showPins != showPins ||
        oldDelegate.interactive != interactive ||
        oldDelegate.points != points ||
        oldDelegate.zoomScale != zoomScale;
  }
}
