import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;
import '../../engine/scene_3d_controller.dart';
import '../../engine/farm_model_controller.dart';

class RealtimeAgriPv3dViewport extends StatefulWidget {
  final Scene3dController controller;
  final bool showSunGizmo;
  final bool enableGestures;
  final VoidCallback? onTap;

  const RealtimeAgriPv3dViewport({
    super.key,
    required this.controller,
    this.showSunGizmo = true,
    this.enableGestures = true,
    this.onTap,
  });

  @override
  State<RealtimeAgriPv3dViewport> createState() => _RealtimeAgriPv3dViewportState();
}

class _RealtimeAgriPv3dViewportState extends State<RealtimeAgriPv3dViewport> {
  double _lastScale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant RealtimeAgriPv3dViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _lastScale = 1.0;
      },
      onScaleUpdate: (details) {
        if (!widget.enableGestures) return;

        if (details.pointerCount == 1) {
          // Orbit Rotation
          widget.controller.cameraController.onDragOrbit(
            details.focalPointDelta.dx,
            details.focalPointDelta.dy,
          );
        } else if (details.pointerCount > 1) {
          // Pinch Zoom
          final scaleFactor = details.scale / _lastScale;
          _lastScale = details.scale;
          widget.controller.cameraController.onPinchZoom(scaleFactor);
        }
      },
      onDoubleTap: () {
        if (widget.enableGestures) {
          widget.controller.cameraController.reset();
        }
      },
      onTap: widget.onTap,
      child: CustomPaint(
        size: Size.infinite,
        painter: _Realtime3dPainter(
          controller: widget.controller,
          showSunGizmo: widget.showSunGizmo,
        ),
      ),
    );
  }
}

class _Realtime3dPainter extends CustomPainter {
  final Scene3dController controller;
  final bool showSunGizmo;

  _Realtime3dPainter({
    required this.controller,
    required this.showSunGizmo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final sun = controller.sunController;
    final camera = controller.cameraController;
    final config = controller.designConfig;

    // -------------------------------------------------------------
    // 1. DYNAMIC SKY & ATMOSPHERIC GRADIENT
    // -------------------------------------------------------------
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: sun.skyGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // -------------------------------------------------------------
    // 2. SUN GIZMO & CORONA IN THE SKY
    // -------------------------------------------------------------
    if (showSunGizmo) {
      _drawSunGizmo(canvas, size, sun);
      _drawCompassRose(canvas, size, camera.azimuthRad);
    }

    // -------------------------------------------------------------
    // 3. BUILD & TRANSFORM 3D GEOMETRY
    // -------------------------------------------------------------
    final rawPolygons = FarmModelController.buildSceneGeometry(
      config: config,
      sun: sun,
    );

    final transformMatrix = camera.getTransformMatrix(size);
    final lightDir = sun.sunDirectionVector;
    final sunlightColor = sun.sunlightColor;
    final ambient = sun.ambientIntensity;

    final List<_ScreenPolygon> renderList = [];

    for (final poly in rawPolygons) {
      final screenPoints = <Offset>[];
      double totalZ = 0.0;
      bool isBehindCamera = false;

      for (final v in poly.vertices) {
        final v4 = v64.Vector4(v.x, v.y, v.z, 1.0);
        v4.applyMatrix4(transformMatrix);

        if (v4.w <= 0.12) {
          isBehindCamera = true;
          break;
        }

        final invW = 1.0 / v4.w;
        final sx = v4.x * invW;
        final sy = v4.y * invW;
        final sz = v4.z;

        if (sx.isNaN || sy.isNaN || sx < -1600 || sx > 2600 || sy < -1600 || sy > 2600) {
          isBehindCamera = true;
          break;
        }

        screenPoints.add(Offset(sx, sy));
        totalZ += sz;
      }

      if (isBehindCamera || screenPoints.length < 3) continue;

      final avgDepth = totalZ / screenPoints.length;

      // Lighting & Shading
      Color finalColor;

      if (poly.isShadow) {
        finalColor = poly.baseColor;
      } else if (poly.isWater) {
        // Water shimmer blend with sky
        finalColor = poly.baseColor;
      } else {
        final dot = poly.normal.dot(lightDir).clamp(-1.0, 1.0);
        final diffuse = math.max(0.0, dot);
        final lightFactor = (ambient + (1.0 - ambient) * diffuse).clamp(0.28, 1.0);

        final base = poly.baseColor;
        final baseR = (base.r <= 1.0) ? base.r * 255.0 : base.r;
        final baseG = (base.g <= 1.0) ? base.g * 255.0 : base.g;
        final baseB = (base.b <= 1.0) ? base.b * 255.0 : base.b;

        final sunR = (sunlightColor.r <= 1.0) ? sunlightColor.r : sunlightColor.r / 255.0;
        final sunG = (sunlightColor.g <= 1.0) ? sunlightColor.g : sunlightColor.g / 255.0;
        final sunB = (sunlightColor.b <= 1.0) ? sunlightColor.b : sunlightColor.b / 255.0;

        var litR = (baseR * lightFactor * sunR);
        var litG = (baseG * lightFactor * sunG);
        var litB = (baseB * lightFactor * sunB);

        // Photorealistic Specular Glint on Glass Solar Panels
        if (poly.isGlass) {
          final viewDir = v64.Vector3(0.0, 0.7, 0.7).normalized();
          final halfVec = (lightDir + viewDir).normalized();
          final specDot = math.max(0.0, poly.normal.dot(halfVec));
          final specFactor = math.pow(specDot, 18).toDouble() * 0.40;
          litR = (litR + 255.0 * specFactor);
          litG = (litG + 255.0 * specFactor);
          litB = (litB + 255.0 * specFactor);
        }

        final alpha = (base.a <= 1.0) ? (base.a * 255.0).round() : base.a.toInt();
        finalColor = Color.fromARGB(
          alpha,
          litR.clamp(0.0, 255.0).round(),
          litG.clamp(0.0, 255.0).round(),
          litB.clamp(0.0, 255.0).round(),
        );
      }

      renderList.add(_ScreenPolygon(
        points: screenPoints,
        color: finalColor,
        depth: avgDepth,
        isPanel: poly.isPanel,
        isShadow: poly.isShadow,
        isMetallic: poly.isMetallic,
      ));
    }

    // -------------------------------------------------------------
    // 4. DEPTH SORTING (Back to Front)
    // -------------------------------------------------------------
    renderList.sort((a, b) => b.depth.compareTo(a.depth));

    // -------------------------------------------------------------
    // 5. DRAW POLYGONS TO CANVAS
    // -------------------------------------------------------------
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final sp in renderList) {
      if (sp.points.length < 3) continue;

      final path = Path();
      path.moveTo(sp.points[0].dx, sp.points[0].dy);
      for (int i = 1; i < sp.points.length; i++) {
        path.lineTo(sp.points[i].dx, sp.points[i].dy);
      }
      path.close();

      fillPaint.color = sp.color;
      canvas.drawPath(path, fillPaint);

      // Multi-busbar Photovoltaic Cell Texture Lines
      if (sp.isPanel && sp.points.length == 4) {
        strokePaint.color = const Color(0xFF90CAF9).withValues(alpha: 0.45);
        strokePaint.strokeWidth = 0.8;
        canvas.drawPath(path, strokePaint);

        final p0 = sp.points[0];
        final p1 = sp.points[1];
        final p2 = sp.points[2];
        final p3 = sp.points[3];

        // 3 Vertical Cell Busbar Columns
        for (double f = 0.33; f < 1.0; f += 0.33) {
          final top = Offset.lerp(p0, p1, f)!;
          final bottom = Offset.lerp(p3, p2, f)!;
          canvas.drawLine(top, bottom, strokePaint);
        }

        // 4 Horizontal Silicon Wafer Dividers
        for (double f = 0.25; f < 1.0; f += 0.25) {
          final left = Offset.lerp(p0, p3, f)!;
          final right = Offset.lerp(p1, p2, f)!;
          canvas.drawLine(left, right, strokePaint);
        }
      }
    }
  }

  void _drawSunGizmo(Canvas canvas, Size size, dynamic sun) {
    final sunDir = sun.sunDirectionVector;
    final sunX = size.width / 2.0 + sunDir.x * (size.width * 0.38);
    final sunY = size.height * 0.28 - sunDir.y * (size.height * 0.20);

    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          sun.sunlightColor,
          sun.sunlightColor.withValues(alpha: 0.5),
          sun.sunlightColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 38));

    canvas.drawCircle(Offset(sunX, sunY), 38, sunPaint);

    final corePaint = Paint()..color = sun.sunlightColor;
    canvas.drawCircle(Offset(sunX, sunY), 11, corePaint);
  }

  void _drawCompassRose(Canvas canvas, Size size, double azimuthRad) {
    const double compassRadius = 18.0;
    final center = Offset(size.width - 28.0, 32.0);

    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawCircle(center, compassRadius, bgPaint);

    final northAngle = -azimuthRad - math.pi / 2.0;
    final nx = center.dx + math.cos(northAngle) * 12.0;
    final ny = center.dy + math.sin(northAngle) * 12.0;

    final pointerPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(nx, ny), pointerPaint);

    final southPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx - math.cos(northAngle) * 10.0, center.dy - math.sin(northAngle) * 10.0), southPaint);
  }

  @override
  bool shouldRepaint(covariant _Realtime3dPainter oldDelegate) => true;
}

class _ScreenPolygon {
  final List<Offset> points;
  final Color color;
  final double depth;
  final bool isPanel;
  final bool isShadow;
  final bool isMetallic;

  _ScreenPolygon({
    required this.points,
    required this.color,
    required this.depth,
    this.isPanel = false,
    this.isShadow = false,
    this.isMetallic = false,
  });
}
