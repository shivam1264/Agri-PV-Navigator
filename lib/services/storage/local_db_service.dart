import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/farm.dart';
import '../../models/agri_pv_design.dart';
import '../../models/proposal_report.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agri_pv_navigator.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE farms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        area_acres REAL NOT NULL,
        crop TEXT NOT NULL,
        location TEXT NOT NULL,
        state TEXT NOT NULL,
        suitability_score INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        soil_type TEXT NOT NULL DEFAULT 'Loamy',
        slope TEXT NOT NULL DEFAULT '< 2%',
        irrigation TEXT NOT NULL DEFAULT 'Available',
        grid_proximity_km REAL NOT NULL DEFAULT 2.4,
        current_land_use TEXT NOT NULL DEFAULT 'Agriculture',
        image_path TEXT NOT NULL DEFAULT 'assets/images/farm_wheat.jpg',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE designs (
        id TEXT PRIMARY KEY,
        farm_id TEXT NOT NULL,
        name TEXT NOT NULL,
        mounting_type TEXT NOT NULL,
        tilt_degrees REAL NOT NULL,
        orientation TEXT NOT NULL,
        row_spacing_m REAL NOT NULL,
        panel_coverage_pct REAL NOT NULL,
        panel_height_m REAL NOT NULL,
        pv_capacity_kw REAL NOT NULL,
        cultivable_area_pct REAL NOT NULL,
        annual_energy_mwh REAL NOT NULL,
        crop_yield_pct REAL NOT NULL,
        ler REAL NOT NULL,
        project_cost_cr REAL NOT NULL,
        payback_years REAL NOT NULL,
        npv_lakhs REAL NOT NULL,
        co2_saved_tons REAL NOT NULL,
        is_machinery_compatible INTEGER NOT NULL DEFAULT 1,
        clearance_status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (farm_id) REFERENCES farms(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        farm_id TEXT,
        design_id TEXT,
        title TEXT NOT NULL,
        farm_name TEXT NOT NULL,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size TEXT NOT NULL DEFAULT '0 KB',
        created_at TEXT NOT NULL
      )
    ''');

    // Seed with initial demo farms
    await _seedInitialFarms(db);
  }

  Future<void> _seedInitialFarms(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = [
      {
        'id': 'farm_01', 'name': 'Farm A', 'area_acres': 2.35, 'crop': 'Wheat',
        'location': 'Phulpur, Prayagraj', 'state': 'Uttar Pradesh, India',
        'suitability_score': 82, 'status': 'active', 'soil_type': 'Loamy',
        'slope': '1.8% (Almost flat)', 'irrigation': 'Available',
        'grid_proximity_km': 2.4, 'current_land_use': 'Agriculture',
        'image_path': 'assets/images/farm_wheat.jpg', 'created_at': now,
      },
      {
        'id': 'farm_02', 'name': 'Farm B', 'area_acres': 1.80, 'crop': 'Rice',
        'location': 'Jhunsi, Prayagraj', 'state': 'Uttar Pradesh, India',
        'suitability_score': 76, 'status': 'active', 'soil_type': 'Alluvial',
        'slope': '2.1%', 'irrigation': 'Available',
        'grid_proximity_km': 4.1, 'current_land_use': 'Agriculture',
        'image_path': 'assets/images/farm_rice.jpg', 'created_at': now,
      },
      {
        'id': 'farm_03', 'name': 'Farm C', 'area_acres': 4.10, 'crop': 'Mustard',
        'location': 'Kaushambi', 'state': 'Uttar Pradesh, India',
        'suitability_score': 88, 'status': 'draft', 'soil_type': 'Sandy Loam',
        'slope': '1.2%', 'irrigation': 'Available',
        'grid_proximity_km': 1.8, 'current_land_use': 'Agriculture',
        'image_path': 'assets/images/farm_mustard.jpg', 'created_at': now,
      },
      {
        'id': 'farm_04', 'name': 'Farm D', 'area_acres': 3.20, 'crop': 'Vegetables',
        'location': 'Naini, Prayagraj', 'state': 'Uttar Pradesh, India',
        'suitability_score': 85, 'status': 'active', 'soil_type': 'Loamy',
        'slope': '1.5%', 'irrigation': 'Drip Irrigation',
        'grid_proximity_km': 1.5, 'current_land_use': 'Agriculture',
        'image_path': 'assets/images/farm_vegetables.jpg', 'created_at': now,
      },
    ];
    for (final farm in seeds) {
      await db.insert('farms', farm, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ─── FARMS ───────────────────────────────────────────────────────────────

  Future<List<Farm>> getAllFarms() async {
    final db = await database;
    final rows = await db.query('farms', orderBy: 'created_at DESC');
    return rows.map(_rowToFarm).toList();
  }

  Future<void> insertFarm(Farm farm) async {
    final db = await database;
    await db.insert('farms', _farmToRow(farm), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateFarm(Farm farm) async {
    final db = await database;
    await db.update('farms', _farmToRow(farm), where: 'id = ?', whereArgs: [farm.id]);
  }

  Future<void> deleteFarm(String id) async {
    final db = await database;
    await db.delete('farms', where: 'id = ?', whereArgs: [id]);
    await db.delete('designs', where: 'farm_id = ?', whereArgs: [id]);
  }

  Future<int> getFarmCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM farms');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalAreaAcres() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(area_acres) as total FROM farms');
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<int> getDesignCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM designs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── DESIGNS ─────────────────────────────────────────────────────────────

  Future<void> insertDesign(AgriPvDesign design, String farmId) async {
    final db = await database;
    await db.insert('designs', _designToRow(design, farmId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AgriPvDesign>> getDesignsForFarm(String farmId) async {
    final db = await database;
    final rows = await db.query('designs', where: 'farm_id = ?', whereArgs: [farmId]);
    return rows.map(_rowToDesign).toList();
  }

  // ─── REPORTS ─────────────────────────────────────────────────────────────

  Future<void> insertReport(ProposalReport report) async {
    final db = await database;
    await db.insert('reports', _reportToRow(report),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ProposalReport>> getAllReports() async {
    final db = await database;
    final rows = await db.query('reports', orderBy: 'created_at DESC');
    return rows.map(_rowToReport).toList();
  }

  // ─── CONVERTERS ──────────────────────────────────────────────────────────

  Farm _rowToFarm(Map<String, dynamic> row) {
    return Farm(
      id: row['id'] as String,
      name: row['name'] as String,
      areaAcres: (row['area_acres'] as num).toDouble(),
      crop: row['crop'] as String,
      location: row['location'] as String,
      state: row['state'] as String,
      suitabilityScore: row['suitability_score'] as int,
      status: _statusFromString(row['status'] as String),
      soilType: row['soil_type'] as String,
      slope: row['slope'] as String,
      irrigation: row['irrigation'] as String,
      gridProximityKm: (row['grid_proximity_km'] as num).toDouble(),
      currentLandUse: row['current_land_use'] as String,
      imagePath: row['image_path'] as String,
    );
  }

  Map<String, dynamic> _farmToRow(Farm farm) {
    return {
      'id': farm.id,
      'name': farm.name,
      'area_acres': farm.areaAcres,
      'crop': farm.crop,
      'location': farm.location,
      'state': farm.state,
      'suitability_score': farm.suitabilityScore,
      'status': farm.status.name,
      'soil_type': farm.soilType,
      'slope': farm.slope,
      'irrigation': farm.irrigation,
      'grid_proximity_km': farm.gridProximityKm,
      'current_land_use': farm.currentLandUse,
      'image_path': farm.imagePath,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  FarmStatus _statusFromString(String s) {
    switch (s) {
      case 'draft': return FarmStatus.draft;
      case 'analyzed': return FarmStatus.analyzed;
      default: return FarmStatus.active;
    }
  }

  AgriPvDesign _rowToDesign(Map<String, dynamic> row) {
    return AgriPvDesign(
      id: row['id'] as String,
      name: row['name'] as String,
      mountingType: MountingType.values.firstWhere(
        (e) => e.name == row['mounting_type'], orElse: () => MountingType.elevated),
      tiltDegrees: (row['tilt_degrees'] as num).toDouble(),
      orientation: PanelOrientation.values.firstWhere(
        (e) => e.name == row['orientation'], orElse: () => PanelOrientation.south),
      rowSpacingMeters: (row['row_spacing_m'] as num).toDouble(),
      panelCoveragePercent: (row['panel_coverage_pct'] as num).toDouble(),
      panelHeightMeters: (row['panel_height_m'] as num).toDouble(),
      pvCapacityKw: (row['pv_capacity_kw'] as num).toDouble(),
      cultivableAreaPercent: (row['cultivable_area_pct'] as num).toDouble(),
      annualEnergyMwh: (row['annual_energy_mwh'] as num).toDouble(),
      cropYieldPercent: (row['crop_yield_pct'] as num).toDouble(),
      landEquivalentRatio: (row['ler'] as num).toDouble(),
      projectCostCr: (row['project_cost_cr'] as num).toDouble(),
      paybackYears: (row['payback_years'] as num).toDouble(),
      npvLakhs: (row['npv_lakhs'] as num).toDouble(),
      co2SavedTons: (row['co2_saved_tons'] as num).toDouble(),
      isMachineryCompatible: (row['is_machinery_compatible'] as int) == 1,
      clearanceStatus: row['clearance_status'] as String,
    );
  }

  Map<String, dynamic> _designToRow(AgriPvDesign d, String farmId) {
    return {
      'id': d.id,
      'farm_id': farmId,
      'name': d.name,
      'mounting_type': d.mountingType.name,
      'tilt_degrees': d.tiltDegrees,
      'orientation': d.orientation.name,
      'row_spacing_m': d.rowSpacingMeters,
      'panel_coverage_pct': d.panelCoveragePercent,
      'panel_height_m': d.panelHeightMeters,
      'pv_capacity_kw': d.pvCapacityKw,
      'cultivable_area_pct': d.cultivableAreaPercent,
      'annual_energy_mwh': d.annualEnergyMwh,
      'crop_yield_pct': d.cropYieldPercent,
      'ler': d.landEquivalentRatio,
      'project_cost_cr': d.projectCostCr,
      'payback_years': d.paybackYears,
      'npv_lakhs': d.npvLakhs,
      'co2_saved_tons': d.co2SavedTons,
      'is_machinery_compatible': d.isMachineryCompatible ? 1 : 0,
      'clearance_status': d.clearanceStatus,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  ProposalReport _rowToReport(Map<String, dynamic> row) {
    return ProposalReport(
      id: row['id'] as String,
      title: row['title'] as String,
      farmName: row['farm_name'] as String,
      date: DateTime.parse(row['created_at'] as String),
      type: ReportType.values.firstWhere(
        (e) => e.name == row['type'], orElse: () => ReportType.proposal),
      fileSize: row['file_size'] as String,
      downloadUrl: row['file_path'] as String,
    );
  }

  Map<String, dynamic> _reportToRow(ProposalReport r) {
    return {
      'id': r.id,
      'title': r.title,
      'farm_name': r.farmName,
      'type': r.type.name,
      'file_path': r.downloadUrl,
      'file_size': r.fileSize,
      'created_at': r.date.toIso8601String(),
    };
  }
}
