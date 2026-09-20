import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

class SunSimulationController with ChangeNotifier {
  double _timeOfDayHour; // 6.0 to 18.0 (6:00 AM to 6:00 PM)
  bool _isPlaying;

  SunSimulationController({
    double initialTimeOfDay = 10.5,
    bool isPlaying = false,
  })  : _timeOfDayHour = initialTimeOfDay,
        _isPlaying = isPlaying;

  double get timeOfDayHour => _timeOfDayHour;
  set timeOfDayHour(double value) {
    final clamped = value.clamp(6.0, 18.0);
    if (_timeOfDayHour != clamped) {
      _timeOfDayHour = clamped;
      notifyListeners();
    }
  }

  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    if (_isPlaying != value) {
      _isPlaying = value;
      notifyListeners();
    }
  }

  // Solar Altitude (Elevation angle above horizon in radians: 0 at sunrise/sunset, up to ~75° at noon)
  double get solarAltitudeRad {
    // Normalised day progress 0.0 at 6 AM, 1.0 at 6 PM
    final t = (_timeOfDayHour - 6.0) / 12.0;
    final maxElevRad = 72.0 * math.pi / 180.0;
    // Sinusoidal elevation
    return math.sin(t * math.pi) * maxElevRad;
  }

  double get solarAltitudeDeg => solarAltitudeRad * 180.0 / math.pi;

  // Solar Azimuth (in radians: East = -π/2, South = 0, West = +π/2)
  double get solarAzimuthRad {
    final t = (_timeOfDayHour - 6.0) / 12.0;
    // From -80° (East) to +80° (West)
    return (t - 0.5) * math.pi * 0.88;
  }

  double get solarAzimuthDeg => solarAzimuthRad * 180.0 / math.pi;

  // Unit vector pointing FROM the scene TOWARDS the sun (Light Direction)
  v64.Vector3 get sunDirectionVector {
    final alt = math.max(0.08, solarAltitudeRad); // Keep slightly above horizon to prevent infinite shadow lengths
    final az = solarAzimuthRad;

    final lx = math.sin(az) * math.cos(alt);
    final ly = math.sin(alt);
    final lz = -math.cos(az) * math.cos(alt);

    return v64.Vector3(lx, ly, lz).normalized();
  }

  // Shadow projection offset matrix multiplier on ground plane (y=0)
  // Vertex (x, y, z) -> (x - y * (lx / ly), 0, z - y * (lz / ly))
  v64.Vector2 get groundShadowProjectionFactor {
    final sunDir = sunDirectionVector;
    final safeLy = math.max(0.30, sunDir.y);
    final fx = (-sunDir.x / safeLy).clamp(-1.2, 1.2);
    final fz = (-sunDir.z / safeLy).clamp(-1.2, 1.2);
    return v64.Vector2(fx, fz);
  }

  // Sunlight color temperature based on time of day
  Color get sunlightColor {
    final t = (_timeOfDayHour - 6.0) / 12.0; // 0.0 to 1.0
    if (t < 0.2) {
      // Sunrise warm golden orange
      return Color.lerp(const Color(0xFFFF9E43), const Color(0xFFFFD54F), t / 0.2)!;
    } else if (t > 0.8) {
      // Sunset deep amber
      return Color.lerp(const Color(0xFFFFD54F), const Color(0xFFFF7043), (t - 0.8) / 0.2)!;
    } else {
      // Crisp daylight
      return const Color(0xFFFFFDE7);
    }
  }

  // Sunlight intensity (0.4 at dawn/dusk to 1.0 at noon)
  double get solarIrradianceWm2 {
    final t = (_timeOfDayHour - 6.0) / 12.0;
    final sinT = math.sin(t * math.pi);
    return math.max(120.0, sinT * 950.0);
  }

  // Ambient light intensity
  double get ambientIntensity {
    final t = (_timeOfDayHour - 6.0) / 12.0;
    return 0.35 + 0.30 * math.sin(t * math.pi);
  }

  // Sky gradient colors
  List<Color> get skyGradient {
    final t = (_timeOfDayHour - 6.0) / 12.0;
    if (t < 0.25) {
      return [
        const Color(0xFF1E3C72),
        const Color(0xFFF3904F),
        const Color(0xFFFFE0B2),
      ];
    } else if (t > 0.75) {
      return [
        const Color(0xFF2C3E50),
        const Color(0xFFE65100),
        const Color(0xFFFFCC80),
      ];
    } else {
      return [
        const Color(0xFF4A90E2),
        const Color(0xFF87CEEB),
        const Color(0xFFE8F5E9),
      ];
    }
  }

  String get formattedTime {
    final hours = _timeOfDayHour.floor();
    final minutes = ((_timeOfDayHour - hours) * 60).round();
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHour = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return '${displayHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $period';
  }
}
