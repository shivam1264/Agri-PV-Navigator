import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../models/user_profile.dart';
import '../../models/suitability_factor.dart';
import '../../models/site_assessment.dart';
import '../../models/agri_pv_design.dart';
import '../../models/economic_assessment.dart';
import '../../models/proposal_report.dart';
import '../../core/theme/app_colors.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // User Profile
  final UserProfile user = const UserProfile(
    id: 'user_01',
    name: 'Shivam Kumar',
    email: 'shivam@example.com',
    phone: '+91 98765 43210',
    initials: 'SK',
    totalFarms: 2,
    totalAreaAcres: 5.60,
    designsCreated: 3,
  );

  // Farms
  List<Farm> farms = [
    const Farm(
      id: 'farm_01',
      name: 'Farm A',
      areaAcres: 2.35,
      crop: 'Wheat',
      location: 'Phulpur, Prayagraj',
      state: 'Uttar Pradesh, India',
      suitabilityScore: 82,
      status: FarmStatus.active,
      soilType: 'Loamy',
      slope: '1.8% (Almost flat)',
      irrigation: 'Available',
      gridProximityKm: 2.4,
      imagePath: 'assets/images/farm_wheat.jpg',
    ),
    const Farm(
      id: 'farm_02',
      name: 'Farm B',
      areaAcres: 1.80,
      crop: 'Rice',
      location: 'Jhunsi, Prayagraj',
      state: 'Uttar Pradesh, India',
      suitabilityScore: 76,
      status: FarmStatus.active,
      soilType: 'Alluvial',
      slope: '2.1%',
      irrigation: 'Available',
      gridProximityKm: 4.1,
      imagePath: 'assets/images/farm_rice.jpg',
    ),
    const Farm(
      id: 'farm_03',
      name: 'Farm C',
      areaAcres: 4.10,
      crop: 'Mustard',
      location: 'Kaushambi',
      state: 'Uttar Pradesh, India',
      suitabilityScore: 88,
      status: FarmStatus.draft,
      soilType: 'Sandy Loam',
      slope: '1.2%',
      irrigation: 'Available',
      gridProximityKm: 1.8,
      imagePath: 'assets/images/farm_mustard.jpg',
    ),
    const Farm(
      id: 'farm_04',
      name: 'Farm D',
      areaAcres: 3.20,
      crop: 'Vegetables',
      location: 'Naini, Prayagraj',
      state: 'Uttar Pradesh, India',
      suitabilityScore: 85,
      status: FarmStatus.active,
      soilType: 'Loamy',
      slope: '1.5%',
      irrigation: 'Drip Irrigation',
      gridProximityKm: 1.5,
      imagePath: 'assets/images/farm_vegetables.jpg',
    ),
  ];

  // Current draft farm for assessment wizard
  Farm currentDraftFarm = const Farm(
    id: 'draft_new',
    name: 'My Farm',
    areaAcres: 2.35,
    crop: 'Wheat',
    location: 'Phulpur, Prayagraj',
    state: 'Uttar Pradesh, India',
    suitabilityScore: 82,
    status: FarmStatus.draft,
    soilType: 'Loamy',
    slope: '< 2% (Almost flat)',
    irrigation: 'Available',
    gridProximityKm: 2.4,
    imagePath: 'assets/images/farm_wheat.jpg',
  );

  // Site assessment for Farm A (matching Screens 8 & 9)
  SiteAssessment get defaultSiteAssessment => const SiteAssessment(
    farmId: 'farm_01',
    overallScore: 82,
    summary: 'Your land is well-suited for Agri-PV with minimal constraints.',
    recommendations: [
      'Elevated stilt mounting structure (2.8m) is recommended for tractor clearance.',
      'South orientation at 20° tilt maximizes annual solar irradiance with minimal winter shading.',
      'Maintain 6m row spacing to optimize sunlight penetration for wheat crops.',
    ],
    factors: [
      SuitabilityFactor(
        id: 'f1',
        name: 'Solar Resource',
        score: 85,
        metricValue: '4.8 kWh/m²/day',
        shortReason: 'Good annual solar irradiation.',
        fullAssessment: 'High solar irradiation across all seasons supports robust PV output.',
        impact: 'Positive: Projected high capacity utilization factor (~19.2%).',
        icon: Icons.wb_sunny_rounded,
        accentColor: AppColors.solar,
      ),
      SuitabilityFactor(
        id: 'f2',
        name: 'Land Slope',
        score: 90,
        metricValue: '1.8% slope',
        shortReason: 'Low slope is suitable for mounting.',
        fullAssessment: '1.8% slope is ideal for installation without civil terracing.',
        impact: 'Positive: Minimal foundation civil work required.',
        icon: Icons.landscape_rounded,
        accentColor: AppColors.slope,
      ),
      SuitabilityFactor(
        id: 'f3',
        name: 'Soil Type',
        score: 75,
        metricValue: 'Loamy soil',
        shortReason: 'Loamy soil supports dual cultivation.',
        fullAssessment: 'Loamy soil has good load-bearing capacity and high agricultural fertility.',
        impact: 'Positive: Good anchor piling stability with healthy root growth.',
        icon: Icons.grass_rounded,
        accentColor: AppColors.soil,
      ),
      SuitabilityFactor(
        id: 'f4',
        name: 'Water Availability',
        score: 70,
        metricValue: 'Irrigation available',
        shortReason: 'Tubewell/canal access ensures panel washing & crop hydration.',
        fullAssessment: 'Regular irrigation enables periodic module dust cleaning during dry months.',
        impact: 'Moderate: Requires scheduled module washing twice a month.',
        icon: Icons.water_drop_rounded,
        accentColor: AppColors.water,
      ),
      SuitabilityFactor(
        id: 'f5',
        name: 'Crop Shade Tolerance',
        score: 80,
        metricValue: 'Wheat (C3 crop)',
        shortReason: 'Wheat can tolerate proposed partial shading.',
        fullAssessment: 'Wheat can tolerate 30–40% partial shading with negligible yield reduction.',
        impact: 'Positive: Microclimate humidity helps reduce evapotranspiration.',
        icon: Icons.eco_rounded,
        accentColor: AppColors.primary,
      ),
      SuitabilityFactor(
        id: 'f6',
        name: 'Grid Proximity',
        score: 85,
        metricValue: '2.4 km to 11kV feeder',
        shortReason: 'Short interconnection line reduces evacuation costs.',
        fullAssessment: 'Local 11kV distribution line available within 2.4 km radius.',
        impact: 'Positive: Low grid interconnection and transmission infrastructure Capex.',
        icon: Icons.electric_bolt_rounded,
        accentColor: AppColors.solar,
      ),
    ],
  );

  // Compare Designs (Screen 13: Design A, Design B, Design C)
  List<AgriPvDesign> get compareDesigns => const [
    AgriPvDesign(
      id: 'design_a',
      name: 'Design A',
      mountingType: MountingType.fixedTilt,
      tiltDegrees: 18,
      orientation: PanelOrientation.south,
      rowSpacingMeters: 8.0,
      panelCoveragePercent: 28.0,
      panelHeightMeters: 2.2,
      pvCapacityKw: 150.0,
      cultivableAreaPercent: 85.0,
      annualEnergyMwh: 210.0,
      cropYieldPercent: 96.0,
      landEquivalentRatio: 1.42,
      projectCostCr: 0.78,
      paybackYears: 6.8,
      npvLakhs: 28.4,
      co2SavedTons: 172.0,
      isMachineryCompatible: true,
      clearanceStatus: 'Tractor (2.2 m)',
    ),
    AgriPvDesign(
      id: 'design_b',
      name: 'Design B',
      mountingType: MountingType.elevated,
      tiltDegrees: 20,
      orientation: PanelOrientation.south,
      rowSpacingMeters: 6.0,
      panelCoveragePercent: 40.0,
      panelHeightMeters: 2.8,
      pvCapacityKw: 250.0,
      cultivableAreaPercent: 78.0,
      annualEnergyMwh: 350.0,
      cropYieldPercent: 94.0,
      landEquivalentRatio: 1.61,
      projectCostCr: 1.25,
      paybackYears: 6.0,
      npvLakhs: 48.6,
      co2SavedTons: 287.0,
      isMachineryCompatible: true,
      clearanceStatus: 'Tractor (2.5 m) | Harvester (3.0 m)',
    ),
    AgriPvDesign(
      id: 'design_c',
      name: 'Design C',
      mountingType: MountingType.singleAxisTracker,
      tiltDegrees: 25,
      orientation: PanelOrientation.south,
      rowSpacingMeters: 5.0,
      panelCoveragePercent: 52.0,
      panelHeightMeters: 3.2,
      pvCapacityKw: 300.0,
      cultivableAreaPercent: 70.0,
      annualEnergyMwh: 420.0,
      cropYieldPercent: 88.0,
      landEquivalentRatio: 1.48,
      projectCostCr: 1.58,
      paybackYears: 5.6,
      npvLakhs: 56.2,
      co2SavedTons: 345.0,
      isMachineryCompatible: true,
      clearanceStatus: 'High Clearance (3.2 m)',
    ),
  ];

  // Techno-Economic Assessment (Screen 14)
  EconomicAssessment get defaultEconomicAssessment => const EconomicAssessment(
    pvCapacityKw: 250.0,
    annualEnergyMwh: 430.0,
    projectCostCr: 1.25,
    annualRevenueLakhs: 12.5,
    paybackPeriodYears: 6.0,
    netPresentValueLakhs: 48.6,
    co2SavedTons: 420.0,
    internalRateOfReturn: 16.4,
    levelizedCostOfEnergy: 2.85,
    costBreakdown: {
      'PV Modules': 45.0,
      'Elevated Steel Structures': 26.0,
      'Inverters & Transformers': 14.0,
      'Installation & Grid Interconnection': 15.0,
    },
    revenueBreakdown: {
      'Feed-in Energy Revenue': 76.0,
      'Crop Sale Harvest': 24.0,
    },
  );

  // Proposal Reports (Screen 16)
  List<ProposalReport> reports = [
    ProposalReport(
      id: 'rep_01',
      title: 'Agri-PV Proposal',
      farmName: 'Farm A',
      date: DateTime(2025, 9, 15),
      type: ReportType.proposal,
      fileSize: '3.4 MB',
      downloadUrl: '#',
    ),
    ProposalReport(
      id: 'rep_02',
      title: 'Technical Report',
      farmName: 'Farm A',
      date: DateTime(2025, 9, 12),
      type: ReportType.technical,
      fileSize: '5.1 MB',
      downloadUrl: '#',
    ),
    ProposalReport(
      id: 'rep_03',
      title: 'Financial Analysis',
      farmName: 'Farm A',
      date: DateTime(2025, 9, 10),
      type: ReportType.financial,
      fileSize: '2.8 MB',
      downloadUrl: '#',
    ),
    ProposalReport(
      id: 'rep_04',
      title: 'Impact Assessment',
      farmName: 'Farm A',
      date: DateTime(2025, 9, 8),
      type: ReportType.environmental,
      fileSize: '1.9 MB',
      downloadUrl: '#',
    ),
  ];

  void addFarm(Farm newFarm) {
    farms.insert(0, newFarm);
  }
}
