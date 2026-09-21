import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

enum CameraPreset {
  perspective('Perspective', 'Isometric 45° angle'),
  top('Top View', 'Nadir aerial boundary layout'),
  side('Side View', 'Profile stilt & clearance height'),
  sun('Sun-Facing', 'Looking along solar irradiance');

  final String label;
  final String description;
  const CameraPreset(this.label, this.description);
}

class Camera3dController with ChangeNotifier {
  double _azimuthRad; // Horizontal orbit angle (-π to π)
  double _pitchRad; // Vertical elevation angle (0.15 rad to 1.45 rad)
  double _zoomScale; // Distance multiplier (0.6x to 2.2x)
  v64.Vector2 _panOffset; // Screen pan offset
  CameraPreset _currentPreset;

  Camera3dController({
    double initialAzimuth = 0.55,
    double initialPitch = 0.65,
    double initialZoom = 1.0,
    CameraPreset initialPreset = CameraPreset.perspective,
  })  : _azimuthRad = initialAzimuth,
        _pitchRad = initialPitch,
        _zoomScale = initialZoom,
        _panOffset = v64.Vector2.zero(),
        _currentPreset = initialPreset;

  double get azimuthRad => _azimuthRad;
  double get pitchRad => _pitchRad;
  double get zoomScale => _zoomScale;
  v64.Vector2 get panOffset => _panOffset;
  CameraPreset get currentPreset => _currentPreset;

  void onDragOrbit(double deltaX, double deltaY) {
    // DeltaX rotates horizontally around scene
    _azimuthRad = (_azimuthRad + deltaX * 0.008) % (2 * math.pi);
    // DeltaY changes camera pitch (clamped to prevent flipping upside down)
    _pitchRad = (_pitchRad - deltaY * 0.008).clamp(0.12, 1.45);
    notifyListeners();
  }

  void onPinchZoom(double scaleFactor) {
    _zoomScale = (_zoomScale * scaleFactor).clamp(0.55, 2.3);
    notifyListeners();
  }

  void onPan(double deltaX, double deltaY) {
    _panOffset.x += deltaX * 0.8;
    _panOffset.y += deltaY * 0.8;
    notifyListeners();
  }

  void setPreset(CameraPreset preset, {double? currentSunAzimuthRad}) {
    _currentPreset = preset;
    switch (preset) {
      case CameraPreset.perspective:
        _azimuthRad = 0.55;
        _pitchRad = 0.60;
        _zoomScale = 1.0;
        _panOffset = v64.Vector2.zero();
        break;
      case CameraPreset.top:
        _azimuthRad = 0.0;
        _pitchRad = 1.42; // Nearly directly overhead
        _zoomScale = 1.05;
        _panOffset = v64.Vector2.zero();
        break;
      case CameraPreset.side:
        _azimuthRad = math.pi / 2.0; // Perpendicular side view
        _pitchRad = 0.22; // Low angle looking across crop rows and stilts
        _zoomScale = 1.1;
        _panOffset = v64.Vector2.zero();
        break;
      case CameraPreset.sun:
        if (currentSunAzimuthRad != null) {
          _azimuthRad = currentSunAzimuthRad;
        } else {
          _azimuthRad = 0.0;
        }
        _pitchRad = 0.45;
        _zoomScale = 1.0;
        _panOffset = v64.Vector2.zero();
        break;
    }
    notifyListeners();
  }

  void reset() {
    setPreset(CameraPreset.perspective);
  }

  // Generate 3D Transformation Matrix for world-to-camera-to-screen
  v64.Matrix4 getTransformMatrix(Size viewportSize) {
    final matrix = v64.Matrix4.identity();

    // Center to viewport
    matrix.translate(
      viewportSize.width / 2.0 + _panOffset.x,
      viewportSize.height / 2.0 + _panOffset.y + 12.0,
      0.0,
    );

    // Apply zoom
    matrix.scale(_zoomScale * 0.88, _zoomScale * 0.88, _zoomScale * 0.88);

    // Controlled perspective factor to prevent near plane inversion
    matrix.setEntry(3, 2, 0.0006);

    // Rotate pitch (around X-axis)
    matrix.rotateX(_pitchRad);

    // Rotate azimuth (around Y-axis)
    matrix.rotateY(_azimuthRad);

    return matrix;
  }
}
