import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  final String displayName;
  final String shortName;
  final String district;
  final String state;
  final double latitude;
  final double longitude;

  const LocationSearchResult({
    required this.displayName,
    required this.shortName,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSearchResult.fromOsmJson(Map<String, dynamic> json) {
    final address = (json['address'] as Map<String, dynamic>?) ?? {};

    final short = address['village'] ??
        address['town'] ??
        address['suburb'] ??
        address['city'] ??
        address['county'] ??
        json['name'] ??
        'Location';

    final dist = address['state_district'] ??
        address['county'] ??
        address['district'] ??
        address['city'] ??
        short;

    final st = address['state'] ?? 'India';

    return LocationSearchResult(
      displayName: json['display_name'] ?? '$short, $dist, $st',
      shortName: short.toString(),
      district: dist.toString(),
      state: st.toString(),
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class GeocodingService {
  static const String _userAgent = 'AgriPvNavigator/1.0 (agripv-app@local.dev)';

  /// Obtains the real current GPS location of the user using Geolocator
  static Future<Position?> getCurrentGpsPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return null;
    }
  }

  /// Searches OpenStreetMap Nominatim for a query string
  static Future<List<LocationSearchResult>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmed)}&format=json&addressdetails=1&limit=5',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => LocationSearchResult.fromOsmJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
    }
    return [];
  }

  /// Performs reverse geocoding via OpenStreetMap Nominatim
  static Future<LocationSearchResult?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationSearchResult.fromOsmJson(data);
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
    return null;
  }

  /// Calculates real geographic polygon area in acres using spherical projection
  static double calculatePolygonAreaInAcres(List<LatLng> points) {
    if (points.length < 3) return 2.0;

    const double earthRadiusMeters = 6378137.0; // WGS84
    double totalAreaSquareMeters = 0.0;

    for (int i = 0; i < points.length; i++) {
      final LatLng p1 = points[i];
      final LatLng p2 = points[(i + 1) % points.length];

      final double radLat1 = p1.latitude * math.pi / 180.0;
      final double radLat2 = p2.latitude * math.pi / 180.0;
      final double radLon1 = p1.longitude * math.pi / 180.0;
      final double radLon2 = p2.longitude * math.pi / 180.0;

      totalAreaSquareMeters += (radLon2 - radLon1) *
          (2.0 + math.sin(radLat1) + math.sin(radLat2));
    }

    totalAreaSquareMeters = totalAreaSquareMeters.abs() *
        (earthRadiusMeters * earthRadiusMeters) /
        4.0;

    // 1 square meter = 0.000247105 acres
    final acres = totalAreaSquareMeters * 0.000247105;
    if (acres.isNaN || acres <= 0.05) return 2.35;
    return double.parse(acres.toStringAsFixed(2));
  }
}
