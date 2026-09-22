import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../engine/scene_3d_controller.dart';
import 'dart:convert';
import 'three_js_bridge.dart';

class RealtimeAgriPv3dViewport extends StatefulWidget {
  final Scene3dController controller;
  final List<String>? boundaryCoords;
  final bool showSunGizmo;
  final bool enableGestures;
  final VoidCallback? onTap;
  final String? customBackgroundImageUrl;

  const RealtimeAgriPv3dViewport({
    super.key,
    required this.controller,
    this.boundaryCoords,
    this.showSunGizmo = true,
    this.enableGestures = true,
    this.onTap,
    this.customBackgroundImageUrl,
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
    final config = widget.controller.designConfig;
    final sun = widget.controller.sunController;
    
    final Map<String, dynamic> configMap = {
      'farmL': 160.0,
      'farmW': 160.0,
      'tiltRad': config.panelTilt * (math.pi / 180.0),
      'spacing': config.rowSpacing,
      'stiltH': config.panelHeight,
      'panelW': 4.2,
      'panelChord': 2.2,
      'sunAzimuthRad': sun.solarAzimuthRad,
      'sunElevationRad': sun.solarAltitudeRad,
      'boundaryCoords': widget.boundaryCoords ?? [],
      'customBackgroundImageUrl': widget.customBackgroundImageUrl,
    };

    return ThreeJsBridge(configJson: jsonEncode(configMap));
  }
}

