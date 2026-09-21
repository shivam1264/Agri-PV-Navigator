import mongoose from 'mongoose';
import { SuitabilityAnalysis, ISuitabilityAnalysis } from '../models/suitability.model';
import { FarmService } from './farm.service';
import { SuitabilityEngine } from '../calculations/suitabilityEngine';
import { AppError } from '../middleware/error.middleware';

export class SuitabilityService {
  public static async getByFarm(userId: string, farmId: string): Promise<ISuitabilityAnalysis> {
    const farm = await FarmService.getFarmById(userId, farmId);

    let analysis = await SuitabilityAnalysis.findOne({
      farmId: farm._id,
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!analysis) {
      // Generate if missing
      analysis = await this.evaluateAndSave(userId, farmId);
    }

    return analysis;
  }

  public static async evaluateAndSave(userId: string, farmId: string, customInputs?: any): Promise<ISuitabilityAnalysis> {
    const farm = await FarmService.getFarmById(userId, farmId);

    let slopePct = 1.8;
    if (typeof farm.slope === 'number') {
      slopePct = farm.slope;
    } else if (typeof farm.slope === 'string') {
      const match = farm.slope.match(/([0-9.]+)/);
      if (match) slopePct = parseFloat(match[1]);
    }

    const result = SuitabilityEngine.evaluate({
      solarIrradiationKwh: customInputs?.solarIrradiationKwh,
      slopePercent: customInputs?.slopePercent ?? slopePct,
      soilType: customInputs?.soilType || farm.soilType,
      hasIrrigation: customInputs?.hasIrrigation ?? farm.irrigation.toLowerCase().includes('avail'),
      crop: customInputs?.crop || farm.cropType,
      gridDistanceKm: customInputs?.gridDistanceKm ?? farm.gridProximityKm,
      latitude: farm.location.coordinates[1],
      longitude: farm.location.coordinates[0],
    });

    farm.suitabilityScore = result.overallScore;
    farm.status = 'analyzed';
    await farm.save();

    const analysis = await SuitabilityAnalysis.findOneAndUpdate(
      { farmId: farm._id, userId: farm.userId },
      {
        ...result,
      },
      { upsert: true, new: true }
    );

    return analysis!;
  }
}
