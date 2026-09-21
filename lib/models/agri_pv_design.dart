enum MountingType {
  elevated('Elevated (2.8 m)', 2.8),
  fixedTilt('Fixed Tilt (1.5 m)', 1.5),
  singleAxisTracker('Tracker (3.2 m)', 3.2);

  final String label;
  final double defaultHeight;
  const MountingType(this.label, this.defaultHeight);
}

enum PanelOrientation {
  south('South (180°)'),
  southEast('Southeast (135°)'),
  southWest('Southwest (225°)');

  final String label;
  const PanelOrientation(this.label);
}

class AgriPvDesign {
  final String id;
  final String name;
  final MountingType mountingType;
  final double tiltDegrees;
  final PanelOrientation orientation;
  final double rowSpacingMeters;
  final double panelCoveragePercent;
  final double panelHeightMeters;

  // Calculated metrics
  final double pvCapacityKw;
  final double cultivableAreaPercent;
  final double annualEnergyMwh;
  final double cropYieldPercent;
  final double landEquivalentRatio; // LER
  final double projectCostCr;
  final double paybackYears;
  final double npvLakhs;
  final double co2SavedTons;
  final bool isMachineryCompatible;
  final String clearanceStatus;

  const AgriPvDesign({
    required this.id,
    required this.name,
    this.mountingType = MountingType.elevated,
    this.tiltDegrees = 20.0,
    this.orientation = PanelOrientation.south,
    this.rowSpacingMeters = 6.0,
    this.panelCoveragePercent = 40.0,
    this.panelHeightMeters = 2.8,
    required this.pvCapacityKw,
    required this.cultivableAreaPercent,
    required this.annualEnergyMwh,
    required this.cropYieldPercent,
    required this.landEquivalentRatio,
    required this.projectCostCr,
    required this.paybackYears,
    required this.npvLakhs,
    required this.co2SavedTons,
    required this.isMachineryCompatible,
    required this.clearanceStatus,
  });

  AgriPvDesign copyWith({
    String? id,
    String? name,
    MountingType? mountingType,
    double? tiltDegrees,
    PanelOrientation? orientation,
    double? rowSpacingMeters,
    double? panelCoveragePercent,
    double? panelHeightMeters,
    double? pvCapacityKw,
    double? cultivableAreaPercent,
    double? annualEnergyMwh,
    double? cropYieldPercent,
    double? landEquivalentRatio,
    double? projectCostCr,
    double? paybackYears,
    double? npvLakhs,
    double? co2SavedTons,
    bool? isMachineryCompatible,
    String? clearanceStatus,
  }) {
    return AgriPvDesign(
      id: id ?? this.id,
      name: name ?? this.name,
      mountingType: mountingType ?? this.mountingType,
      tiltDegrees: tiltDegrees ?? this.tiltDegrees,
      orientation: orientation ?? this.orientation,
      rowSpacingMeters: rowSpacingMeters ?? this.rowSpacingMeters,
      panelCoveragePercent: panelCoveragePercent ?? this.panelCoveragePercent,
      panelHeightMeters: panelHeightMeters ?? this.panelHeightMeters,
      pvCapacityKw: pvCapacityKw ?? this.pvCapacityKw,
      cultivableAreaPercent: cultivableAreaPercent ?? this.cultivableAreaPercent,
      annualEnergyMwh: annualEnergyMwh ?? this.annualEnergyMwh,
      cropYieldPercent: cropYieldPercent ?? this.cropYieldPercent,
      landEquivalentRatio: landEquivalentRatio ?? this.landEquivalentRatio,
      projectCostCr: projectCostCr ?? this.projectCostCr,
      paybackYears: paybackYears ?? this.paybackYears,
      npvLakhs: npvLakhs ?? this.npvLakhs,
      co2SavedTons: co2SavedTons ?? this.co2SavedTons,
      isMachineryCompatible: isMachineryCompatible ?? this.isMachineryCompatible,
      clearanceStatus: clearanceStatus ?? this.clearanceStatus,
    );
  }

  factory AgriPvDesign.fromJson(Map<String, dynamic> json) {
    final data = (json['design'] is Map<String, dynamic>)
        ? json['design'] as Map<String, dynamic>
        : json;

    MountingType parseMounting(String? val) {
      if (val == null) return MountingType.elevated;
      return MountingType.values.firstWhere(
        (e) => e.name == val,
        orElse: () => MountingType.elevated,
      );
    }

    PanelOrientation parseOrientation(String? val) {
      if (val == null) return PanelOrientation.south;
      return PanelOrientation.values.firstWhere(
        (e) => e.name == val,
        orElse: () => PanelOrientation.south,
      );
    }

    return AgriPvDesign(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: data['name'] ?? 'Design',
      mountingType: parseMounting(data['mountingType']),
      tiltDegrees: (data['tiltDegrees'] as num?)?.toDouble() ?? 20.0,
      orientation: parseOrientation(data['orientation']),
      rowSpacingMeters: (data['rowSpacingMeters'] as num?)?.toDouble() ?? 6.0,
      panelCoveragePercent: (data['panelCoveragePercent'] as num?)?.toDouble() ?? 40.0,
      panelHeightMeters: (data['panelHeightMeters'] as num?)?.toDouble() ?? 2.8,
      pvCapacityKw: (data['pvCapacityKw'] as num?)?.toDouble() ?? 0.0,
      cultivableAreaPercent: (data['cultivableAreaPercent'] as num?)?.toDouble() ?? 0.0,
      annualEnergyMwh: (data['annualEnergyMwh'] as num?)?.toDouble() ?? 0.0,
      cropYieldPercent: (data['cropYieldPercent'] as num?)?.toDouble() ?? 0.0,
      landEquivalentRatio: (data['landEquivalentRatio'] as num?)?.toDouble() ?? 0.0,
      projectCostCr: (data['projectCostCr'] as num?)?.toDouble() ?? 0.0,
      paybackYears: (data['paybackYears'] as num?)?.toDouble() ?? 0.0,
      npvLakhs: (data['npvLakhs'] as num?)?.toDouble() ?? 0.0,
      co2SavedTons: (data['co2SavedTons'] as num?)?.toDouble() ?? 0.0,
      isMachineryCompatible: data['isMachineryCompatible'] ?? true,
      clearanceStatus: data['clearanceStatus'] ?? 'Adequate Clearance',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mountingType': mountingType.name,
      'tiltDegrees': tiltDegrees,
      'orientation': orientation.name,
      'rowSpacingMeters': rowSpacingMeters,
      'panelCoveragePercent': panelCoveragePercent,
      'panelHeightMeters': panelHeightMeters,
      'pvCapacityKw': pvCapacityKw,
      'cultivableAreaPercent': cultivableAreaPercent,
      'annualEnergyMwh': annualEnergyMwh,
      'cropYieldPercent': cropYieldPercent,
      'landEquivalentRatio': landEquivalentRatio,
      'projectCostCr': projectCostCr,
      'paybackYears': paybackYears,
      'npvLakhs': npvLakhs,
      'co2SavedTons': co2SavedTons,
      'isMachineryCompatible': isMachineryCompatible,
      'clearanceStatus': clearanceStatus,
    };
  }
}
