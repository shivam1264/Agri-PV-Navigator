import mongoose from 'mongoose';
import { Farm, IFarm } from '../models/farm.model';
import { SuitabilityAnalysis } from '../models/suitability.model';
import { AgriPvDesign } from '../models/design.model';
import { Report } from '../models/report.model';
import { SuitabilityEngine } from '../calculations/suitabilityEngine';
import { AgriPvEngine } from '../calculations/agriPvEngine';
import { AppError } from '../middleware/error.middleware';

export class FarmService {
  public static async createFarm(userId: string, data: any): Promise<IFarm> {
    const lat = data.latitude ?? 25.4358;
    const lng = data.longitude ?? 81.8463;

    // Pick appropriate image based on crop
    let imagePath = data.imagePath || 'assets/images/farm_wheat.jpg';
    const crop = (data.cropType || 'Wheat').toLowerCase();
    if (crop.includes('rice')) imagePath = 'assets/images/farm_rice.jpg';
    else if (crop.includes('mustard')) imagePath = 'assets/images/farm_mustard.jpg';
    else if (crop.includes('vegetable')) imagePath = 'assets/images/farm_vegetables.jpg';

    // Parse slope percentage from string if needed (e.g. "1.8%" or "< 2%")
    let slopePct = 1.8;
    if (typeof data.slope === 'number') {
      slopePct = data.slope;
    } else if (typeof data.slope === 'string') {
      const match = data.slope.match(/([0-9.]+)/);
      if (match) slopePct = parseFloat(match[1]);
    }

    // 1. Calculate Real Site Suitability
    const suitabilityResult = SuitabilityEngine.evaluate({
      slopePercent: slopePct,
      soilType: data.soilType || 'Loamy',
      hasIrrigation: (data.irrigation || 'Available').toLowerCase().includes('avail'),
      crop: data.cropType || 'Wheat',
      gridDistanceKm: data.gridProximityKm ?? 2.4,
      latitude: lat,
      longitude: lng,
    });

    const farmName = (data.name || '').trim();
    let locName = (data.locationName || data.district || '').trim();
    if ((!locName || locName.toLowerCase().includes('prayagraj')) && farmName.toLowerCase().startsWith('farm at ')) {
      const extracted = farmName.substring(8).trim();
      if (extracted.length > 0 && !extracted.toLowerCase().includes('prayagraj')) {
        locName = extracted;
      }
    }
    if (!locName) locName = 'Farm Site';

    const farm = new Farm({
      userId: new mongoose.Types.ObjectId(userId),
      name: farmName || `Farm at ${locName}`,
      locationName: locName,
      state: data.state || 'India',
      areaAcres: data.areaAcres,
      cropType: data.cropType || 'Wheat',
      soilType: data.soilType || 'Loamy',
      slope: data.slope || '< 2% (Almost flat)',
      irrigation: data.irrigation || 'Available',
      gridProximityKm: data.gridProximityKm ?? 2.4,
      currentLandUse: data.currentLandUse || 'Agriculture',
      coordinates: data.coordinates || [],
      location: {
        type: 'Point',
        coordinates: [lng, lat],
      },
      boundary: data.boundary,
      status: data.status || 'active',
      suitabilityScore: suitabilityResult.overallScore,
      imagePath,
    });

    await farm.save();

    // 2. Persist real SuitabilityAnalysis
    const analysis = new SuitabilityAnalysis({
      farmId: farm._id,
      userId: new mongoose.Types.ObjectId(userId),
      solarResourceScore: suitabilityResult.solarResourceScore,
      slopeScore: suitabilityResult.slopeScore,
      soilScore: suitabilityResult.soilScore,
      waterScore: suitabilityResult.waterScore,
      cropCompatibilityScore: suitabilityResult.cropCompatibilityScore,
      gridProximityScore: suitabilityResult.gridProximityScore,
      overallScore: suitabilityResult.overallScore,
      summary: suitabilityResult.summary,
      recommendations: suitabilityResult.recommendations,
      factors: suitabilityResult.factors,
      calculationVersion: '1.0.0',
    });
    await analysis.save();

    // 3. Create initial comparative designs for farm (Design A, B, C)
    const initialConfigs = [
      {
        name: 'Design A',
        mountingType: 'fixedTilt' as const,
        tiltDegrees: 18,
        orientation: 'south' as const,
        rowSpacingMeters: 8.0,
        panelCoveragePercent: 28.0,
        panelHeightMeters: 2.2,
      },
      {
        name: 'Design B',
        mountingType: 'elevated' as const,
        tiltDegrees: 20,
        orientation: 'south' as const,
        rowSpacingMeters: 6.0,
        panelCoveragePercent: 40.0,
        panelHeightMeters: 2.8,
        isDefaultOrPrimary: true,
      },
      {
        name: 'Design C',
        mountingType: 'singleAxisTracker' as const,
        tiltDegrees: 25,
        orientation: 'south' as const,
        rowSpacingMeters: 5.0,
        panelCoveragePercent: 52.0,
        panelHeightMeters: 3.2,
      },
    ];

    for (const cfg of initialConfigs) {
      const designCalc = AgriPvEngine.calculateDesign({
        areaAcres: farm.areaAcres,
        crop: farm.cropType,
        ...cfg,
      });

      const design = new AgriPvDesign({
        farmId: farm._id,
        userId: new mongoose.Types.ObjectId(userId),
        ...cfg,
        panelPowerWatts: 550,
        ...designCalc,
      });
      await design.save();
    }

    return farm;
  }

  public static async getFarms(userId: string, search?: string): Promise<IFarm[]> {
    const filter: any = { userId: new mongoose.Types.ObjectId(userId) };

    if (search && search.trim().length > 0) {
      const q = search.trim();
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { locationName: { $regex: q, $options: 'i' } },
        { cropType: { $regex: q, $options: 'i' } },
      ];
    }

    return Farm.find(filter).sort({ createdAt: -1 });
  }

  public static async getFarmById(userId: string, farmId: string): Promise<IFarm> {
    if (!mongoose.Types.ObjectId.isValid(farmId)) {
      const err: AppError = new Error('Invalid farm identifier.');
      err.statusCode = 400;
      err.code = 'INVALID_ID';
      throw err;
    }

    const farm = await Farm.findOne({
      _id: farmId,
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!farm) {
      const err: AppError = new Error('Farm not found or unauthorized.');
      err.statusCode = 404;
      err.code = 'FARM_NOT_FOUND';
      throw err;
    }

    return farm;
  }

  public static async updateFarm(userId: string, farmId: string, data: any): Promise<IFarm> {
    const farm = await this.getFarmById(userId, farmId);

    const fields = [
      'name',
      'locationName',
      'state',
      'areaAcres',
      'cropType',
      'soilType',
      'slope',
      'irrigation',
      'gridProximityKm',
      'currentLandUse',
      'coordinates',
      'status',
      'imagePath',
    ];

    fields.forEach((f) => {
      if (data[f] !== undefined) {
        (farm as any)[f] = data[f];
      }
    });

    if (data.latitude !== undefined && data.longitude !== undefined) {
      farm.location = {
        type: 'Point',
        coordinates: [data.longitude, data.latitude],
      };
    }

    if (data.boundary !== undefined) {
      farm.boundary = data.boundary;
    }

    // Re-evaluate suitability if physical attributes changed
    let slopePct = 1.8;
    if (typeof farm.slope === 'number') {
      slopePct = farm.slope;
    } else if (typeof farm.slope === 'string') {
      const match = farm.slope.match(/([0-9.]+)/);
      if (match) slopePct = parseFloat(match[1]);
    }

    const suitabilityResult = SuitabilityEngine.evaluate({
      slopePercent: slopePct,
      soilType: farm.soilType,
      hasIrrigation: farm.irrigation.toLowerCase().includes('avail'),
      crop: farm.cropType,
      gridDistanceKm: farm.gridProximityKm,
      latitude: farm.location.coordinates[1],
      longitude: farm.location.coordinates[0],
    });

    farm.suitabilityScore = suitabilityResult.overallScore;
    await farm.save();

    // Update SuitabilityAnalysis record
    await SuitabilityAnalysis.findOneAndUpdate(
      { farmId: farm._id, userId: farm.userId },
      {
        ...suitabilityResult,
      },
      { upsert: true }
    );

    return farm;
  }

  public static async deleteFarm(userId: string, farmId: string): Promise<void> {
    const farm = await this.getFarmById(userId, farmId);
    await Farm.deleteOne({ _id: farm._id });
    await SuitabilityAnalysis.deleteMany({ farmId: farm._id });
    await AgriPvDesign.deleteMany({ farmId: farm._id });
    await Report.deleteMany({ farmId: farm._id });
  }
}
