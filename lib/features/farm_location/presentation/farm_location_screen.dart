import 'package:flutter/material.dart';
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

  void _generateBoundaryPoints() {
    // Generates a ~2-5 acre realistic agricultural plot around current center
    const double delta = 0.0010;
    setState(() {
      _boundaryPoints = [
        LatLng(_latitude + delta * 0.85, _longitude - delta * 0.95),
        LatLng(_latitude + delta * 0.90, _longitude + delta * 1.05),
        LatLng(_latitude - delta * 0.80, _longitude + delta * 1.10),
        LatLng(_latitude - delta * 0.88, _longitude - delta * 0.80),
      ];
      _areaAcres = GeocodingService.calculatePolygonAreaInAcres(_boundaryPoints);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    final pos = await GeocodingService.getCurrentGpsPosition();
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
                            onTap: (tapPosition, point) {
                              // Tap on map updates farm center & boundary
                              setState(() {
                                _latitude = point.latitude;
                                _longitude = point.longitude;
                                _generateBoundaryPoints();
                              });
                              GeocodingService.reverseGeocode(point.latitude, point.longitude).then((res) {
                                if (res != null && mounted) {
                                  setState(() {
                                    _locationName = '${res.shortName}, ${res.district}';
                                    _stateName = '${res.state}, India';
                                    _searchController.text = _locationName;
                                  });
                                }
                              });
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

                            // Real Farm Plot Polygon
                            if (_boundaryPoints.isNotEmpty)
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _boundaryPoints,
                                    holePointsList: const [],
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.28),
                                    borderColor: const Color(0xFF15803D),
                                    borderStrokeWidth: 2.5,
                                  ),
                                ],
                              ),

                            // Corner Boundary Marker Pins
                            MarkerLayer(
                              markers: _boundaryPoints.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final pt = entry.value;
                                return Marker(
                                  point: pt,
                                  width: 28,
                                  height: 28,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF15803D), width: 2),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          color: Color(0xFF15803D),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        // Map Controls (Satellite Switch, Zoom In, Zoom Out)
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
                              }),
                              const SizedBox(height: 6),
                              _buildMapButton(Icons.remove_rounded, () {
                                final zoom = _mapController.camera.zoom - 0.5;
                                _mapController.move(_mapController.camera.center, zoom);
                              }),
                            ],
                          ),
                        ),

                        // Instruction overlay tag at top left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.touch_app_outlined, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Tap map to set farm boundary',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
                      onPressed: () {
                        final stateClean = _stateName.contains(',') ? _stateName.split(',').first.trim() : _stateName;
                        final districtClean = _locationName.contains(',') ? _locationName.split(',').first.trim() : _locationName;

                        // Save real live coordinates and calculated acreage
                        context.read<FarmProvider>().updateDraftLocation(
                          latitude: _latitude,
                          longitude: _longitude,
                          state: stateClean,
                          district: districtClean,
                          areaAcres: _areaAcres,
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
}
