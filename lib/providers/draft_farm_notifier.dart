import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/farm.dart';
import '../../models/agri_pv_design.dart';
import '../../services/calculation/agri_pv_calculation_service.dart';

/// Holds the in-progress farm wizard state across all 4 steps.
/// Nothing is lost when navigating between screens.
class DraftFarm {
  final String id;
  final String name;
  final double areaAcres;
  final String crop;
  final String location;
  final String state;
  final String soilType;
  final String slope;
  final String irrigation;
  final String gridString;
  final double gridProximityKm;
  final int suitabilityScore;
  final AgriPvDesign? design;

  const DraftFarm({
    this.id = '',
    this.name = 'My Farm',
    this.areaAcres = 2.35,
    this.crop = 'Wheat',
    this.location = '',
    this.state = 'India',
    this.soilType = 'Loamy',
    this.slope = '< 2% (Almost flat)',
    this.irrigation = 'Available',
    this.gridString = '2.4 km',
    this.gridProximityKm = 2.4,
    this.suitabilityScore = 0,
    this.design,
  });

  DraftFarm copyWith({
    String? id,
    String? name,
    double? areaAcres,
    String? crop,
    String? location,
    String? state,
    String? soilType,
    String? slope,
    String? irrigation,
    String? gridString,
    double? gridProximityKm,
    int? suitabilityScore,
    AgriPvDesign? design,
  }) {
    return DraftFarm(
      id: id ?? this.id,
      name: name ?? this.name,
      areaAcres: areaAcres ?? this.areaAcres,
      crop: crop ?? this.crop,
      location: location ?? this.location,
      state: state ?? this.state,
      soilType: soilType ?? this.soilType,
      slope: slope ?? this.slope,
      irrigation: irrigation ?? this.irrigation,
      gridString: gridString ?? this.gridString,
      gridProximityKm: gridProximityKm ?? this.gridProximityKm,
      suitabilityScore: suitabilityScore ?? this.suitabilityScore,
      design: design ?? this.design,
    );
  }

  /// Convert DraftFarm → saved Farm model
  Farm toFarm() {
    return Farm(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      name: name,
      areaAcres: areaAcres,
      crop: crop,
      location: location,
      state: state,
      suitabilityScore: suitabilityScore,
      status: FarmStatus.active,
      soilType: soilType,
      slope: slope,
      irrigation: irrigation,
      gridProximityKm: gridProximityKm,
      currentLandUse: 'Agriculture',
      imagePath: _cropImagePath(crop),
    );
  }

  /// Generate an AgriPvDesign from current draft parameters (no notifier needed)
  AgriPvDesign generateDesign({
    MountingType mountingType = MountingType.elevated,
    double tiltDegrees = 20.0,
    PanelOrientation orientation = PanelOrientation.south,
    double rowSpacingMeters = 6.0,
    double panelCoveragePercent = 40.0,
  }) {
    return AgriPvCalculationService.generateDesign(
      id: 'design_${DateTime.now().millisecondsSinceEpoch}',
      name: '$name Design',
      areaAcres: areaAcres,
      crop: crop,
      mountingType: mountingType,
      tiltDegrees: tiltDegrees,
      orientation: orientation,
      rowSpacingMeters: rowSpacingMeters,
      panelCoveragePercent: panelCoveragePercent,
    );
  }

  String _cropImagePath(String crop) {
    final lower = crop.toLowerCase();
    if (lower.contains('wheat')) return 'assets/images/farm_wheat.jpg';
    if (lower.contains('rice')) return 'assets/images/farm_rice.jpg';
    if (lower.contains('mustard')) return 'assets/images/farm_mustard.jpg';
    if (lower.contains('vegetable')) return 'assets/images/farm_vegetables.jpg';
    return 'assets/images/farm_wheat.jpg';
  }
}

class DraftFarmNotifier extends StateNotifier<DraftFarm> {
  DraftFarmNotifier() : super(const DraftFarm());

  /// Step 1: Farm Location
  void setLocation({
    required String location,
    required String stateName,
    required double areaAcres,
  }) {
    state = state.copyWith(
      location: location,
      state: stateName,
      areaAcres: areaAcres,
    );
  }

  /// Step 2: Farm Details
  void setDetails({
    required String name,
    required double areaAcres,
    required String crop,
    required String soilType,
    required String slope,
    required String irrigation,
    required String gridString,
    required double gridKm,
  }) {
    state = state.copyWith(
      name: name,
      areaAcres: areaAcres,
      crop: crop,
      soilType: soilType,
      slope: slope,
      irrigation: irrigation,
      gridString: gridString,
      gridProximityKm: gridKm,
    );
  }

  /// Step 3: Store computed suitability score
  void setSuitabilityScore(int score) {
    state = state.copyWith(suitabilityScore: score);
  }

  /// Step 4: Store the selected design
  void setDesign(AgriPvDesign design) {
    state = state.copyWith(design: design);
  }

  /// Reset wizard for a new farm
  void reset() {
    state = const DraftFarm();
  }

  /// Generate design from current draft parameters
  AgriPvDesign generateDesign({
    MountingType mountingType = MountingType.elevated,
    double tiltDegrees = 20.0,
    PanelOrientation orientation = PanelOrientation.south,
    double rowSpacingMeters = 6.0,
    double panelCoveragePercent = 40.0,
  }) {
    return AgriPvCalculationService.generateDesign(
      id: 'design_${DateTime.now().millisecondsSinceEpoch}',
      name: '${state.name} Design',
      areaAcres: state.areaAcres,
      crop: state.crop,
      mountingType: mountingType,
      tiltDegrees: tiltDegrees,
      orientation: orientation,
      rowSpacingMeters: rowSpacingMeters,
      panelCoveragePercent: panelCoveragePercent,
    );
  }
}
