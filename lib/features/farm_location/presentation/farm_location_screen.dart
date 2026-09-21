import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../providers/farm_provider.dart';
import '../../../services/location/geocoding_service.dart';

class FarmLocationScreen extends StatefulWidget {
  const FarmLocationScreen({super.key});

  @override
  State<FarmLocationScreen> createState() => _FarmLocationScreenState();
}

class _FarmLocationScreenState extends State<FarmLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _cameraDebounce;

  double _latitude = 25.4358;
  double _longitude = 81.8463;
  String _locationName = 'Phulpur, Prayagraj';
  String _stateName = 'Uttar Pradesh, India';
  double _areaAcres = 2.35;

  bool _isLocating = false;
  bool _isSearching = false;
  bool _useSatellite = true;

  List<LocationSearchResult> _searchResults = [];
  List<LatLng> _boundaryPoints = [];

  @override
  void initState() {
    super.initState();
    final draft = context.read<FarmProvider>().draftFarm;
    if (draft['latitude'] != null && draft['longitude'] != null) {
      _latitude = (draft['latitude'] as num).toDouble();
      _longitude = (draft['longitude'] as num).toDouble();
      if (draft['district'] != null) {
        _locationName = draft['district'].toString();
      }
      if (draft['state'] != null) {
        _stateName = '${draft['state']}, India';
      }
      if (draft['areaAcres'] != null) {
        _areaAcres = (draft['areaAcres'] as num).toDouble();
      }
    }
    _searchController.text = _locationName;
    _generateBoundaryPoints();
  }

  @override
  void dispose() {
    _cameraDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onCameraMoved(LatLng center) {
    _cameraDebounce?.cancel();
    _cameraDebounce = Timer(const Duration(milliseconds: 700), () async {
      _latitude = center.latitude;
      _longitude = center.longitude;
      final res = await GeocodingService.reverseGeocode(center.latitude, center.longitude);
      if (!mounted) return;
      setState(() {
        if (res != null) {
          _locationName = '${res.shortName}, ${res.district}';
          _stateName = '${res.state}, India';
          _searchController.text = _locationName;
        }
      });
    });
  }

  Future<void> _relocatePlotTo(LatLng point) async {
    setState(() {
      _latitude = point.latitude;
      _longitude = point.longitude;
      _generateBoundaryPoints();
    });
    final res = await GeocodingService.reverseGeocode(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      if (res != null) {
        _locationName = '${res.shortName}, ${res.district}';
        _stateName = '${res.state}, India';
        _searchController.text = _locationName;
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.place_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Plot moved to: $_locationName')),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int? _activeDragIndex;
  int? _selectedCornerIndex;
  bool _isDrawingMode = false;
  final List<LatLng> _drawnPoints = [];

  void _generateBoundaryPoints() {
    // Generates a ~2-5 acre realistic agricultural plot around current center
    const double delta = 0.0010;
    setState(() {
      _selectedCornerIndex = null;
      _isDrawingMode = false;
      _drawnPoints.clear();
      _boundaryPoints = [
        LatLng(_latitude + delta * 0.85, _longitude - delta * 0.95),
        LatLng(_latitude + delta * 0.90, _longitude + delta * 1.05),
        LatLng(_latitude - delta * 0.80, _longitude + delta * 1.10),
        LatLng(_latitude - delta * 0.88, _longitude - delta * 0.80),
      ];
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  void _setPresetPlot(double acres) {
    // 1 acre is ~4046.86 m^2. For a square, half-span is ~31.8m * sqrt(acres)
    final double sideMeters = 63.6 * math.sqrt(acres);
    final double dLat = (sideMeters / 2.0) / 111139.0;
    final double radLat = _latitude * math.pi / 180.0;
    final double cosLat = math.cos(radLat).abs() > 0.1 ? math.cos(radLat).abs() : 1.0;
    final double dLon = (sideMeters / 2.0) / (111139.0 * cosLat);

    setState(() {
      _selectedCornerIndex = null;
      _isDrawingMode = false;
      _drawnPoints.clear();
      _boundaryPoints = [
        LatLng(_latitude + dLat, _longitude - dLon),
        LatLng(_latitude + dLat, _longitude + dLon),
        LatLng(_latitude - dLat, _longitude + dLon),
        LatLng(_latitude - dLat, _longitude - dLon),
      ];
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${acres.toStringAsFixed(1)} Acre preset plot.'),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _moveSelectedCornerTo(LatLng point) {
    if (_selectedCornerIndex == null || _selectedCornerIndex! >= _boundaryPoints.length) return;
    setState(() {
      _boundaryPoints[_selectedCornerIndex!] = point;
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  void _nudgeCorner(int index, double dMetersY, double dMetersX) {
    if (index < 0 || index >= _boundaryPoints.length) return;
    final current = _boundaryPoints[index];
    final double radLat = current.latitude * math.pi / 180.0;
    final double cosLat = math.cos(radLat).abs() > 0.1 ? math.cos(radLat).abs() : 1.0;

    final double dLat = dMetersY / 111139.0;
    final double dLon = dMetersX / (111139.0 * cosLat);

    setState(() {
      _boundaryPoints[index] = LatLng(current.latitude + dLat, current.longitude + dLon);
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  void _onMarkerDrag(int index, DragUpdateDetails details) {
    if (index < 0 || index >= _boundaryPoints.length) return;

    final currentZoom = _mapController.camera.zoom;
    final currentPoint = _boundaryPoints[index];

    // Web Mercator pixel scale calculation at current zoom & latitude
    final double mapSize = 256.0 * math.pow(2.0, currentZoom);
    final double radLat = currentPoint.latitude * math.pi / 180.0;
    final double cosLat = math.cos(radLat).abs() > 0.05 ? math.cos(radLat).abs() : 1.0;

    final double dLon = (details.delta.dx * 360.0) / mapSize;
    final double dLat = -(details.delta.dy * 360.0 * cosLat) / mapSize;

    setState(() {
      _boundaryPoints[index] = LatLng(
        currentPoint.latitude + dLat,
        currentPoint.longitude + dLon,
      );
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  void _insertPointAfter(int index, LatLng point) {
    setState(() {
      _boundaryPoints.insert(index + 1, point);
      _selectedCornerIndex = index + 1;
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Corner #${index + 2} added! Tap map or drag to position.'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removePoint(int index) {
    if (_boundaryPoints.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm boundary requires at least 3 corners.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _boundaryPoints.removeAt(index);
      if (_selectedCornerIndex == index) {
        _selectedCornerIndex = null;
      } else if (_selectedCornerIndex != null && _selectedCornerIndex! > index) {
        _selectedCornerIndex = _selectedCornerIndex! - 1;
      }
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed corner #${index + 1}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetBoundary() {
    _generateBoundaryPoints();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Boundary reset to default plot.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shiftBoundaryToCenter(LatLng newCenter) {
    if (_boundaryPoints.isEmpty) {
      _generateBoundaryPoints();
      return;
    }
    final double dLat = newCenter.latitude - _latitude;
    final double dLon = newCenter.longitude - _longitude;
    setState(() {
      _latitude = newCenter.latitude;
      _longitude = newCenter.longitude;
      _boundaryPoints = _boundaryPoints
          .map((p) => LatLng(p.latitude + dLat, p.longitude + dLon))
          .toList();
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  void _showPresetsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Boundary Tools & Presets', style: AppTypography.cardTitle),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a standard plot size or redraw custom field:',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 14),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.surface,
                  leading: const Icon(Icons.crop_square_rounded, color: AppColors.primary),
                  title: const Text('1.0 Acre (Square Field)'),
                  subtitle: const Text('~63m x 63m plot outline'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setPresetPlot(1.0);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.surface,
                  leading: const Icon(Icons.crop_landscape_rounded, color: AppColors.primary),
                  title: const Text('2.5 Acres (Rectangular Field)'),
                  subtitle: const Text('~100m x 100m plot outline'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setPresetPlot(2.5);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.surface,
                  leading: const Icon(Icons.crop_5_4_rounded, color: AppColors.primary),
                  title: const Text('5.0 Acres (Large Commercial Plot)'),
                  subtitle: const Text('~142m x 142m plot outline'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setPresetPlot(5.0);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.primarySurface,
                  leading: const Icon(Icons.draw_rounded, color: AppColors.primary),
                  title: const Text('Redraw Field by Tapping Corners'),
                  subtitle: const Text('Tap directly on satellite map to place each corner'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _isDrawingMode = true;
                      _drawnPoints.clear();
                      _selectedCornerIndex = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tap corners of your field on the map (min 3 corners).'),
                        backgroundColor: AppColors.primaryDark,
                        duration: Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Desktop web has no GPS: use the current network's IP location;
  /// fall back to the browser's (stale Wi-Fi) fix if IP lookup fails.
  Future<Position?> _desktopWebPosition() async {
    final ipPos = await GeocodingService.getIpPosition();
    if (ipPos != null) {
      return Position(
        latitude: ipPos.latitude,
        longitude: ipPos.longitude,
        timestamp: DateTime.now(),
        accuracy: 5000,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        altitudeAccuracy: 0,
      );
    }
    return GeocodingService.getCurrentGpsPosition();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    final pos = kIsWeb
        ? await _desktopWebPosition()
        : await GeocodingService.getCurrentGpsPosition();
    if (!mounted) return;

    if (pos != null) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;

      final res = await GeocodingService.reverseGeocode(_latitude, _longitude);
      if (!mounted) return;

      setState(() {
        if (res != null) {
          _locationName = '${res.shortName}, ${res.district}';
          _stateName = '${res.state}, India';
          _searchController.text = _locationName;
        } else {
          _locationName = 'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}';
          _searchController.text = _locationName;
        }
        _generateBoundaryPoints();
        _isLocating = false;
      });

      _mapController.move(LatLng(_latitude, _longitude), 16.5);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Live GPS Location: $_locationName')),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS unavailable or permission denied. Type location in search bar.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);

    final results = await GeocodingService.searchLocations(query);
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });

    if (results.isNotEmpty) {
      _selectSearchResult(results.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No location found for "$query". Try adding city/state.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectSearchResult(LocationSearchResult res) {
    setState(() {
      _latitude = res.latitude;
      _longitude = res.longitude;
      _locationName = '${res.shortName}, ${res.district}';
      _stateName = '${res.state}, India';
      _searchController.text = _locationName;
      _searchResults = [];
      _generateBoundaryPoints();
    });

    _mapController.move(LatLng(_latitude, _longitude), 16.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_boundaryPoints.isEmpty) {
      const double delta = 0.0010;
      _boundaryPoints = [
        LatLng(_latitude + delta * 0.85, _longitude - delta * 0.95),
        LatLng(_latitude + delta * 0.90, _longitude + delta * 1.05),
        LatLng(_latitude - delta * 0.80, _longitude + delta * 1.10),
        LatLng(_latitude - delta * 0.88, _longitude - delta * 0.80),
      ];
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Farm Location',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper (Step 1: Location)
            ProgressStepper(
              currentStep: 1,
              onStepTapped: (step) {
                if (step == 2) context.go('/farm-details');
                if (step == 3) context.go('/site-suitability');
                if (step == 4) context.go('/agri-pv-design');
              },
            ),

            // Top Bar / Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Up Your Farm Location',
                    style: AppTypography.screenHeading.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 8),

                  // Search input & "Use My Location" chip
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _performSearch,
                            style: AppTypography.bodySmall.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search city, village, or pincode...',
                              prefixIcon: _isSearching
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Center(
                                        child: SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                                onPressed: () => _performSearch(_searchController.text),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Use My Location Chip
                      GestureDetector(
                        onTap: _isLocating ? null : _useCurrentLocation,
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.primaryLight.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              _isLocating
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    )
                                  : Icon(Icons.my_location_rounded, size: 16, color: isDark ? AppColors.accent : AppColors.primary),
                              const SizedBox(width: 5),
                              Text(
                                _isLocating ? 'Locating...' : 'Use My Location',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Suggestions Overlay Dropdown
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black54 : Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _searchResults.take(3).map((res) {
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.place_outlined, size: 18, color: isDark ? AppColors.accent : AppColors.primary),
                            title: Text(
                              res.displayName,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white : null),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(res),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Real Live Interactive Map View (FlutterMap)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(_latitude, _longitude),
                            initialZoom: 16.2,
                            maxZoom: 19.0,
                            minZoom: 4.0,
                            interactionOptions: InteractionOptions(
                              flags: _activeDragIndex != null ? InteractiveFlag.none : InteractiveFlag.all,
                            ),
                            onPositionChanged: (camera, hasGesture) {
                              if (hasGesture) {
                                _onCameraMoved(camera.center);
                              }
                            },
                            onTap: (tapPosition, point) {
                              if (_isDrawingMode) {
                                setState(() {
                                  _drawnPoints.add(point);
                                  if (_drawnPoints.length >= 3) {
                                    _boundaryPoints = List.from(_drawnPoints);
                                    _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
                                  }
                                });
                                return;
                              }

                              if (_selectedCornerIndex != null) {
                                _moveSelectedCornerTo(point);
                                return;
                              }

                              // Tap anywhere on map to relocate farm plot to that exact area
                              _relocatePlotTo(point);
                            },
                          ),
                          children: [
                            // Tile Layer (Satellite Esri vs OSM Street)
                            TileLayer(
                              urlTemplate: _useSatellite
                                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              maxZoom: 19,
                            ),

                            // Polyline preview while in drawing mode (< 3 points)
                            if (_isDrawingMode && _drawnPoints.length >= 2)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _drawnPoints,
                                    color: const Color(0xFF22C55E),
                                    strokeWidth: 2.5,
                                  ),
                                ],
                              ),

                            // Real Farm Plot Polygon
                            if (_isDrawingMode && _drawnPoints.length >= 3)
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _drawnPoints,
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.28),
                                    borderColor: const Color(0xFF15803D),
                                    borderStrokeWidth: 2.5,
                                  ),
                                ],
                              )
                            else if (!_isDrawingMode && _boundaryPoints.isNotEmpty)
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _boundaryPoints,
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.28),
                                    borderColor: const Color(0xFF15803D),
                                    borderStrokeWidth: 2.5,
                                  ),
                                ],
                              ),

                            // Markers Layer
                            if (_isDrawingMode)
                              MarkerLayer(
                                markers: _drawnPoints.asMap().entries.map((entry) {
                                  return Marker(
                                    point: entry.value,
                                    width: 32,
                                    height: 32,
                                    child: Center(
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF15803D),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              MarkerLayer(
                                markers: [
                                  // 1. Interactive Selectable & Draggable Corner Markers
                                  ..._boundaryPoints.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final pt = entry.value;
                                    final isDragging = _activeDragIndex == idx;
                                    final isSelected = _selectedCornerIndex == idx;

                                    return Marker(
                                      point: pt,
                                      width: 50,
                                      height: 50,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _selectedCornerIndex = isSelected ? null : idx;
                                          });
                                        },
                                        onPanStart: (_) {
                                          setState(() {
                                            _activeDragIndex = idx;
                                            _selectedCornerIndex = idx;
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          _onMarkerDrag(idx, details);
                                        },
                                        onPanEnd: (_) {
                                          setState(() => _activeDragIndex = null);
                                        },
                                        onPanCancel: () {
                                          setState(() => _activeDragIndex = null);
                                        },
                                        onLongPress: _boundaryPoints.length > 3
                                            ? () => _removePoint(idx)
                                            : null,
                                        child: Center(
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 140),
                                            width: isDragging ? 38 : (isSelected ? 36 : 28),
                                            height: isDragging ? 38 : (isSelected ? 36 : 28),
                                            decoration: BoxDecoration(
                                              color: isDragging
                                                  ? AppColors.primary
                                                  : (isSelected ? const Color(0xFFF59E0B) : Colors.white),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: (isDragging || isSelected)
                                                    ? Colors.white
                                                    : const Color(0xFF15803D),
                                                width: (isDragging || isSelected) ? 2.5 : 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isDragging
                                                      ? AppColors.primary.withValues(alpha: 0.6)
                                                      : (isSelected
                                                          ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                                                          : Colors.black26),
                                                  blurRadius: (isDragging || isSelected) ? 8 : 4,
                                                  spreadRadius: (isDragging || isSelected) ? 2 : 0,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${idx + 1}',
                                                style: TextStyle(
                                                  color: (isDragging || isSelected)
                                                      ? Colors.white
                                                      : const Color(0xFF15803D),
                                                  fontSize: (isDragging || isSelected) ? 13 : 11,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),

                                  // 2. Midpoint "+" Add Corner Handles
                                  if (_boundaryPoints.length >= 3)
                                    ...List.generate(_boundaryPoints.length, (i) {
                                      final p1 = _boundaryPoints[i];
                                      final p2 = _boundaryPoints[(i + 1) % _boundaryPoints.length];
                                      final mid = LatLng(
                                        (p1.latitude + p2.latitude) / 2,
                                        (p1.longitude + p2.longitude) / 2,
                                      );
                                      return Marker(
                                        point: mid,
                                        width: 26,
                                        height: 26,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _insertPointAfter(i, mid),
                                          child: Center(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF15803D),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 1.5),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black26, blurRadius: 3),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.add, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                          ],
                        ),

                        // Top Overlay Status & Mode Bar
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 64,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isDrawingMode
                                    ? const Color(0xFF22C55E)
                                    : (_selectedCornerIndex != null
                                        ? const Color(0xFFF59E0B)
                                        : Colors.white24),
                                width: 1,
                              ),
                            ),
                            child: _isDrawingMode
                                ? Row(
                                    children: [
                                      const Icon(Icons.edit_road_rounded, color: Color(0xFF4ADE80), size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Corners: ${_drawnPoints.length}/4+ • Tap field',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isDrawingMode = false;
                                            if (_drawnPoints.length >= 3) {
                                              _boundaryPoints = List.from(_drawnPoints);
                                              _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text('Done ✓', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  )
                                : (_selectedCornerIndex != null
                                    ? Row(
                                        children: [
                                          const Icon(Icons.touch_app_rounded, color: Color(0xFFFBBF24), size: 14),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              'Corner #${_selectedCornerIndex! + 1}: Tap map to move or drag',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => setState(() => _selectedCornerIndex = null),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text('✕', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        children: [
                                          Icon(Icons.pan_tool_alt_rounded, color: Colors.white70, size: 13),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Tap corner (1, 2..) to move • Or drag pin',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )),
                          ),
                        ),

                        // Map Controls (Satellite Switch, Zoom In, Zoom Out, Presets, Reset)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            children: [
                              _buildMapButton(
                                _useSatellite ? Icons.satellite_alt_rounded : Icons.map_outlined,
                                () => setState(() => _useSatellite = !_useSatellite),
                                tooltip: _useSatellite ? 'Switch to Map' : 'Switch to Satellite',
                              ),
                              const SizedBox(height: 8),
                              _buildMapButton(Icons.add_rounded, () {
                                final zoom = _mapController.camera.zoom + 0.5;
                                _mapController.move(_mapController.camera.center, zoom);
                              }, tooltip: 'Zoom In'),
                              const SizedBox(height: 6),
                              _buildMapButton(Icons.remove_rounded, () {
                                final zoom = _mapController.camera.zoom - 0.5;
                                _mapController.move(_mapController.camera.center, zoom);
                              }, tooltip: 'Zoom Out'),
                              const SizedBox(height: 8),
                              _buildMapButton(
                                Icons.tune_rounded,
                                _showPresetsSheet,
                                tooltip: 'Boundary Presets & Draw Tool',
                              ),
                              const SizedBox(height: 6),
                              _buildMapButton(
                                Icons.restart_alt_rounded,
                                _resetBoundary,
                                tooltip: 'Reset Boundary',
                              ),
                            ],
                          ),
                        ),

                        // Bottom Left: Corner Quick-Selector Bar
                        if (!_isDrawingMode && _boundaryPoints.isNotEmpty)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Corner: ',
                                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  ...List.generate(_boundaryPoints.length, (i) {
                                    final isSel = _selectedCornerIndex == i;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCornerIndex = isSel ? null : i;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isSel ? const Color(0xFFF59E0B) : const Color(0xFF15803D),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSel ? Colors.white : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      if (_boundaryPoints.length >= 2) {
                                        final p1 = _boundaryPoints.last;
                                        final p2 = _boundaryPoints.first;
                                        _insertPointAfter(
                                          _boundaryPoints.length - 1,
                                          LatLng((p1.latitude + p2.latitude) / 2, (p1.longitude + p2.longitude) / 2),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bottom Right: Precision Nudge Arrow Pad (when corner selected)
                        if (_selectedCornerIndex != null && _selectedCornerIndex! < _boundaryPoints.length)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _nudgeCorner(_selectedCornerIndex!, 2.0, 0.0),
                                    child: _buildNudgeButton(Icons.keyboard_arrow_up_rounded),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _nudgeCorner(_selectedCornerIndex!, 0.0, -2.0),
                                        child: _buildNudgeButton(Icons.keyboard_arrow_left_rounded),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '#${_selectedCornerIndex! + 1}',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _nudgeCorner(_selectedCornerIndex!, 0.0, 2.0),
                                        child: _buildNudgeButton(Icons.keyboard_arrow_right_rounded),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _nudgeCorner(_selectedCornerIndex!, -2.0, 0.0),
                                    child: _buildNudgeButton(Icons.keyboard_arrow_down_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Info Card: Selected Area & Real Location
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selected Area', style: AppTypography.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            '${_areaAcres.toStringAsFixed(2)} acres',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${_boundaryPoints.length} corners (editable)',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 36, width: 1, color: theme.dividerColor),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location', style: AppTypography.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            _locationName,
                            style: AppTypography.cardTitle.copyWith(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$_stateName (${_latitude.toStringAsFixed(3)}°, ${_longitude.toStringAsFixed(3)}°)',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/home'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () async {
                        double finalLat = _latitude;
                        double finalLng = _longitude;

                        // Calculate actual centroid of the plotted farm boundary
                        if (_boundaryPoints.isNotEmpty) {
                          finalLat = _boundaryPoints.map((p) => p.latitude).reduce((a, b) => a + b) / _boundaryPoints.length;
                          finalLng = _boundaryPoints.map((p) => p.longitude).reduce((a, b) => a + b) / _boundaryPoints.length;
                        }

                        var districtClean = _locationName.contains(',') ? _locationName.split(',').first.trim() : _locationName.trim();
                        var stateClean = _stateName.contains(',') ? _stateName.split(',').first.trim() : _stateName.trim();

                        // If district is generic, empty, or hasn't refreshed, do an instant geocode lookup
                        if (districtClean.isEmpty || districtClean.toLowerCase() == 'location' || districtClean.toLowerCase() == 'site') {
                          final geo = await GeocodingService.reverseGeocode(finalLat, finalLng);
                          if (geo != null) {
                            districtClean = geo.district;
                            stateClean = geo.state;
                          }
                        }

                        // Save real live coordinates and calculated acreage
                        if (!context.mounted) return;
                        context.read<FarmProvider>().updateDraftLocation(
                          latitude: finalLat,
                          longitude: finalLng,
                          state: stateClean,
                          district: districtClean,
                          areaAcres: _areaAcres,
                          boundaryPoints: [
                            for (final p in _boundaryPoints) [p.latitude, p.longitude],
                          ],
                        );
                        context.go('/farm-details');
                      },
                      height: 46,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/farms');
                if (index == 2) context.go('/farm-location');
                if (index == 3) context.go('/reports');
                if (index == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildNudgeButton(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }
}
