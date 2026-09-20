enum FarmStatus {
  active,
  draft,
  analyzed,
}

class Farm {
  final String id;
  final String name;
  final double areaAcres;
  final String crop;
  final String location;
  final String state;
  final int suitabilityScore;
  final FarmStatus status;
  final String soilType;
  final String slope;
  final String irrigation;
  final double gridProximityKm;
  final String currentLandUse;
  final List<String> coordinates;

  const Farm({
    required this.id,
    required this.name,
    required this.areaAcres,
    required this.crop,
    required this.location,
    required this.state,
    required this.suitabilityScore,
    this.status = FarmStatus.active,
    this.soilType = 'Loamy',
    this.slope = '< 2% (Almost flat)',
    this.irrigation = 'Available',
    this.gridProximityKm = 2.4,
    this.currentLandUse = 'Agriculture',
    this.coordinates = const [],
  });

  String get suitabilityLabel {
    if (suitabilityScore >= 80) return 'Suitable';
    if (suitabilityScore >= 60) return 'Moderately Suitable';
    return 'Marginal';
  }

  Farm copyWith({
    String? id,
    String? name,
    double? areaAcres,
    String? crop,
    String? location,
    String? state,
    int? suitabilityScore,
    FarmStatus? status,
    String? soilType,
    String? slope,
    String? irrigation,
    double? gridProximityKm,
    String? currentLandUse,
    List<String>? coordinates,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      areaAcres: areaAcres ?? this.areaAcres,
      crop: crop ?? this.crop,
      location: location ?? this.location,
      state: state ?? this.state,
      suitabilityScore: suitabilityScore ?? this.suitabilityScore,
      status: status ?? this.status,
      soilType: soilType ?? this.soilType,
      slope: slope ?? this.slope,
      irrigation: irrigation ?? this.irrigation,
      gridProximityKm: gridProximityKm ?? this.gridProximityKm,
      currentLandUse: currentLandUse ?? this.currentLandUse,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
