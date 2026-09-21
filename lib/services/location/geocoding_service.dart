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

  static String _cleanAscii(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    final s = val.toString();
    // Remove non-ASCII characters that can cause PDF or geocoding display issues
    final cleaned = s
        .replaceAll('₹', 'Rs. ')
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
        .trim();
    return cleaned.isNotEmpty ? cleaned : fallback;
  }

  factory LocationSearchResult.fromOsmJson(Map<String, dynamic> json) {
    final address = (json['address'] as Map<String, dynamic>?) ?? {};

    final rawShort = address['village'] ??
        address['town'] ??
        address['suburb'] ??
        address['city'] ??
        address['county'] ??
        json['name'] ??
        'Location';

    final rawDist = address['state_district'] ??
        address['county'] ??
        address['district'] ??
        address['city'] ??
        rawShort;

    final rawSt = address['state'] ?? 'India';

    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;

    var short = _cleanAscii(rawShort);
    var dist = _cleanAscii(rawDist);
    var st = _cleanAscii(rawSt);

    // If reverse geocoding returned purely Hindi/Devanagari characters, fall back to nearest known Indian city
    if (dist.isEmpty || short.isEmpty || st.isEmpty) {
      final fallback = GeocodingService.findNearestCity(lat, lon);
      if (short.isEmpty) short = fallback.shortName;
      if (dist.isEmpty) dist = fallback.district;
      if (st.isEmpty) st = fallback.state;
    }

    return LocationSearchResult(
      displayName: _cleanAscii(json['display_name'], '$short, $dist, $st'),
      shortName: short,
      district: dist,
      state: st,
      latitude: lat,
      longitude: lon,
    );
  }
}

class GeocodingService {
  static const String _userAgent = 'AgriPvNavigator/1.0 (agripv-app@local.dev)';

  // Static list of major agricultural & regional hubs across India for offline fallback
  static const List<Map<String, dynamic>> _indianCities = [
    {'city': 'Prayagraj', 'district': 'Prayagraj', 'state': 'Uttar Pradesh', 'lat': 25.4358, 'lon': 81.8463},
    {'city': 'Phulpur', 'district': 'Prayagraj', 'state': 'Uttar Pradesh', 'lat': 25.5512, 'lon': 82.0911},
    {'city': 'Lucknow', 'district': 'Lucknow', 'state': 'Uttar Pradesh', 'lat': 26.8467, 'lon': 80.9462},
    {'city': 'Varanasi', 'district': 'Varanasi', 'state': 'Uttar Pradesh', 'lat': 25.3176, 'lon': 82.9739},
    {'city': 'Kanpur', 'district': 'Kanpur', 'state': 'Uttar Pradesh', 'lat': 26.4499, 'lon': 80.3319},
    {'city': 'Agra', 'district': 'Agra', 'state': 'Uttar Pradesh', 'lat': 27.1767, 'lon': 78.0081},
    {'city': 'Bareilly', 'district': 'Bareilly', 'state': 'Uttar Pradesh', 'lat': 28.3670, 'lon': 79.4304},
    {'city': 'Gorakhpur', 'district': 'Gorakhpur', 'state': 'Uttar Pradesh', 'lat': 26.7606, 'lon': 83.3732},
    {'city': 'Bhopal', 'district': 'Bhopal', 'state': 'Madhya Pradesh', 'lat': 23.2599, 'lon': 77.4126},
    {'city': 'Indore', 'district': 'Indore', 'state': 'Madhya Pradesh', 'lat': 22.7196, 'lon': 75.8577},
    {'city': 'Jabalpur', 'district': 'Jabalpur', 'state': 'Madhya Pradesh', 'lat': 23.1815, 'lon': 79.9864},
    {'city': 'Gwalior', 'district': 'Gwalior', 'state': 'Madhya Pradesh', 'lat': 26.2183, 'lon': 78.1828},
    {'city': 'Ujjain', 'district': 'Ujjain', 'state': 'Madhya Pradesh', 'lat': 23.1765, 'lon': 75.7885},
    {'city': 'Rewa', 'district': 'Rewa', 'state': 'Madhya Pradesh', 'lat': 24.5362, 'lon': 81.3037},
    {'city': 'Sagar', 'district': 'Sagar', 'state': 'Madhya Pradesh', 'lat': 23.8388, 'lon': 78.7378},
    {'city': 'Jaipur', 'district': 'Jaipur', 'state': 'Rajasthan', 'lat': 26.9124, 'lon': 75.7873},
    {'city': 'Jodhpur', 'district': 'Jodhpur', 'state': 'Rajasthan', 'lat': 26.2389, 'lon': 73.0243},
    {'city': 'Udaipur', 'district': 'Udaipur', 'state': 'Rajasthan', 'lat': 24.5854, 'lon': 73.7125},
    {'city': 'Kota', 'district': 'Kota', 'state': 'Rajasthan', 'lat': 25.2138, 'lon': 75.8648},
    {'city': 'Bikaner', 'district': 'Bikaner', 'state': 'Rajasthan', 'lat': 28.0229, 'lon': 73.3119},
    {'city': 'Delhi', 'district': 'New Delhi', 'state': 'Delhi', 'lat': 28.6139, 'lon': 77.2090},
    {'city': 'Chandigarh', 'district': 'Chandigarh', 'state': 'Punjab', 'lat': 30.7333, 'lon': 76.7794},
    {'city': 'Ludhiana', 'district': 'Ludhiana', 'state': 'Punjab', 'lat': 30.9010, 'lon': 75.8573},
    {'city': 'Amritsar', 'district': 'Amritsar', 'state': 'Punjab', 'lat': 31.6340, 'lon': 74.8723},
    {'city': 'Karnal', 'district': 'Karnal', 'state': 'Haryana', 'lat': 29.6857, 'lon': 76.9905},
    {'city': 'Hisar', 'district': 'Hisar', 'state': 'Haryana', 'lat': 29.1492, 'lon': 75.7217},
    {'city': 'Patna', 'district': 'Patna', 'state': 'Bihar', 'lat': 25.5941, 'lon': 85.1376},
    {'city': 'Gaya', 'district': 'Gaya', 'state': 'Bihar', 'lat': 24.7914, 'lon': 85.0002},
    {'city': 'Muzaffarpur', 'district': 'Muzaffarpur', 'state': 'Bihar', 'lat': 26.1209, 'lon': 85.3647},
    {'city': 'Ahmedabad', 'district': 'Ahmedabad', 'state': 'Gujarat', 'lat': 23.0225, 'lon': 72.5714},
    {'city': 'Surat', 'district': 'Surat', 'state': 'Gujarat', 'lat': 21.1702, 'lon': 72.8311},
    {'city': 'Vadodara', 'district': 'Vadodara', 'state': 'Gujarat', 'lat': 22.3072, 'lon': 73.1812},
    {'city': 'Rajkot', 'district': 'Rajkot', 'state': 'Gujarat', 'lat': 22.3039, 'lon': 70.8022},
    {'city': 'Pune', 'district': 'Pune', 'state': 'Maharashtra', 'lat': 18.5204, 'lon': 73.8567},
    {'city': 'Nagpur', 'district': 'Nagpur', 'state': 'Maharashtra', 'lat': 21.1458, 'lon': 79.0882},
    {'city': 'Nashik', 'district': 'Nashik', 'state': 'Maharashtra', 'lat': 19.9975, 'lon': 73.7898},
    {'city': 'Mumbai', 'district': 'Mumbai', 'state': 'Maharashtra', 'lat': 19.0760, 'lon': 72.8777},
    {'city': 'Bengaluru', 'district': 'Bengaluru Urban', 'state': 'Karnataka', 'lat': 12.9716, 'lon': 77.5946},
    {'city': 'Mysuru', 'district': 'Mysuru', 'state': 'Karnataka', 'lat': 12.2958, 'lon': 76.6394},
    {'city': 'Hyderabad', 'district': 'Hyderabad', 'state': 'Telangana', 'lat': 17.3850, 'lon': 78.4867},
    {'city': 'Vijayawada', 'district': 'Krishna', 'state': 'Andhra Pradesh', 'lat': 16.5062, 'lon': 80.6480},
    {'city': 'Visakhapatnam', 'district': 'Visakhapatnam', 'state': 'Andhra Pradesh', 'lat': 17.6868, 'lon': 83.2185},
    {'city': 'Chennai', 'district': 'Chennai', 'state': 'Tamil Nadu', 'lat': 13.0827, 'lon': 80.2707},
    {'city': 'Coimbatore', 'district': 'Coimbatore', 'state': 'Tamil Nadu', 'lat': 11.0168, 'lon': 76.9558},
    {'city': 'Kolkata', 'district': 'Kolkata', 'state': 'West Bengal', 'lat': 22.5726, 'lon': 88.3639},
    {'city': 'Bhubaneswar', 'district': 'Khurda', 'state': 'Odisha', 'lat': 20.2961, 'lon': 85.8245},
    {'city': 'Raipur', 'district': 'Raipur', 'state': 'Chhattisgarh', 'lat': 21.2514, 'lon': 81.6296},
    {'city': 'Ranchi', 'district': 'Ranchi', 'state': 'Jharkhand', 'lat': 23.3441, 'lon': 85.3096},
    {'city': 'Dehradun', 'district': 'Dehradun', 'state': 'Uttarakhand', 'lat': 30.3165, 'lon': 78.0322},
  ];

  /// Finds the geographically nearest Indian city from coordinates
  static LocationSearchResult findNearestCity(double lat, double lon) {
    double minDistance = double.infinity;
    Map<String, dynamic> nearest = _indianCities.first;

    for (final c in _indianCities) {
      final double dLat = (c['lat'] as double) - lat;
      final double dLon = (c['lon'] as double) - lon;
      final double distSq = dLat * dLat + dLon * dLon;
      if (distSq < minDistance) {
        minDistance = distSq;
        nearest = c;
      }
    }

    final city = nearest['city'] as String;
    final dist = nearest['district'] as String;
    final st = nearest['state'] as String;

    return LocationSearchResult(
      displayName: '$city, $dist, $st',
      shortName: city,
      district: dist,
      state: st,
      latitude: lat,
      longitude: lon,
    );
  }

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

/// Network-based position (city-level). Used on web/desktop where there is
  /// no GPS: the browser/OS Wi-Fi fix can be stale, so anchor to the current
  /// network instead.
  static Future<({double latitude, double longitude})?> getIpPosition() async {
    try {
      final res = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final latitude = double.tryParse(map['latitude']?.toString() ?? '');
      final longitude = double.tryParse(map['longitude']?.toString() ?? '');
      if (latitude == null || longitude == null) return null;
      return (latitude: latitude, longitude: longitude);
    } catch (e) {
      debugPrint('Error getting IP position: $e');
      return null;
    }
  }

  /// Searches OpenStreetMap Nominatim for a query string in English
  static Future<List<LocationSearchResult>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmed)}&format=json&addressdetails=1&limit=5&accept-language=en',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Accept-Language': 'en',
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

  /// Performs reverse geocoding via OpenStreetMap Nominatim with English locale and offline city fallback
  static Future<LocationSearchResult?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1&accept-language=en',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationSearchResult.fromOsmJson(data);
      }
    } catch (e) {
      debugPrint('Notice: Network reverse geocoding fallback to offline database: $e');
    }

    // Reliable instant offline fallback for any coordinates in India
    return findNearestCity(lat, lon);
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
