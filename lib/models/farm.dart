enum FarmStatus {
  active,
  draft,
  analyzed;

  static FarmStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'active':
        return FarmStatus.active;
      case 'analyzed':
        return FarmStatus.analyzed;
      default:
        return FarmStatus.draft;
    }
  }

  String get name => toString().split('.').last;
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
  final String imagePath;
  final double? latitude;
  final double? longitude;

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
    this.imagePath = 'assets/images/farm_wheat.jpg',
    this.latitude,
    this.longitude,
  });

  String get suitabilityLabel {
    if (suitabilityScore >= 80) return 'Suitable';
    if (suitabilityScore >= 60) return 'Moderately Suitable';
    return 'Marginal';
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    final data = (json['farm'] is Map<String, dynamic>) ? json['farm'] as Map<String, dynamic> : json;

    double? lat;
    double? lng;

    if (data['location'] is Map<String, dynamic> &&
        data['location']['coordinates'] is List &&
        (data['location']['coordinates'] as List).length >= 2) {
      final coords = data['location']['coordinates'] as List;
      lng = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    } else {
      if (data['latitude'] is num) lat = (data['latitude'] as num).toDouble();
      if (data['longitude'] is num) lng = (data['longitude'] as num).toDouble();
    }

    final rawCoordinates = data['coordinates'];
    List<String> parsedCoords = [];
    if (rawCoordinates is List) {
      parsedCoords = rawCoordinates.map((e) => e.toString()).toList();
    }

    final idVal = (data['id'] ?? data['_id'] ?? '').toString();

    final farmName = (data['name'] ?? 'My Farm').toString();
    String loc = '';
    if (data['locationName'] is String && (data['locationName'] as String).trim().isNotEmpty) {
      loc = (data['locationName'] as String).trim();
    } else if (data['district'] is String && (data['district'] as String).trim().isNotEmpty) {
      loc = (data['district'] as String).trim();
    } else if (data['location'] is String && (data['location'] as String).trim().isNotEmpty) {
      loc = (data['location'] as String).trim();
    }

    // If location is still empty or mismatched default Prayagraj while name is 'Farm at X'
    if ((loc.isEmpty || loc.toLowerCase().contains('prayagraj')) && farmName.toLowerCase().startsWith('farm at ')) {
      final extracted = farmName.substring(8).trim();
      if (extracted.isNotEmpty && !extracted.toLowerCase().contains('prayagraj')) {
        loc = extracted;
      }
    }
    if (loc.isEmpty) {
      loc = 'Farm Site';
    }

    return Farm(
      id: idVal,
      name: farmName,
      areaAcres: (data['areaAcres'] is num) ? (data['areaAcres'] as num).toDouble() : 2.35,
      crop: data['crop'] ?? data['cropType'] ?? 'Wheat',
      location: loc,
      state: data['state'] ?? 'India',
      suitabilityScore: (data['suitabilityScore'] is num) ? (data['suitabilityScore'] as num).toInt() : 80,
      status: FarmStatus.fromString(data['status']),
      soilType: data['soilType'] ?? 'Loamy',
      slope: data['slope'] ?? '< 2% (Almost flat)',
      irrigation: data['irrigation'] ?? 'Available',
      gridProximityKm: (data['gridProximityKm'] is num) ? (data['gridProximityKm'] as num).toDouble() : 2.4,
      currentLandUse: data['currentLandUse'] ?? 'Agriculture',
      coordinates: parsedCoords,
      imagePath: data['imagePath'] ?? 'assets/images/farm_wheat.jpg',
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'areaAcres': areaAcres,
      'cropType': crop,
      'crop': crop,
      'locationName': location,
      'location': location,
      'state': state,
      'suitabilityScore': suitabilityScore,
      'status': status.name,
      'soilType': soilType,
      'slope': slope,
      'irrigation': irrigation,
      'gridProximityKm': gridProximityKm,
      'currentLandUse': currentLandUse,
      'coordinates': coordinates,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
    };
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
    String? imagePath,
    double? latitude,
    double? longitude,
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
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
