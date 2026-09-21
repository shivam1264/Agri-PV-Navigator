import mongoose from 'mongoose';
import { Farm } from '../models/farm.model';
import { AgriPvDesign } from '../models/design.model';
import { Notification } from '../models/notification.model';

export interface IDashboardSummary {
  totalFarms: number;
  totalAreaAcres: number;
  designsCreated: number;
  totalPvCapacityKw: number;
  averageSuitabilityScore: number;
  estimatedAnnualEnergyMwh: number;
  totalCo2SavedTons: number;
  unreadNotificationsCount: number;
  recentFarms: any[];
}

export class DashboardService {
  public static async getSummary(userId: string): Promise<IDashboardSummary> {
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const farms = await Farm.find({ userId: userObjectId }).sort({ createdAt: -1 });
    const totalFarms = farms.length;
    const totalAreaAcres = Number(farms.reduce((acc, f) => acc + (f.areaAcres || 0), 0).toFixed(2));

    const avgSuitability =
      totalFarms > 0
        ? Math.round(farms.reduce((acc, f) => acc + (f.suitabilityScore || 0), 0) / totalFarms)
        : 0;

    const designs = await AgriPvDesign.find({ userId: userObjectId });
    const designsCreated = designs.length;

    const totalPvCapacityKw = Number(
      designs.reduce((acc, d) => acc + (d.pvCapacityKw || 0), 0).toFixed(1)
    );

    const estimatedAnnualEnergyMwh = Number(
      designs.reduce((acc, d) => acc + (d.annualEnergyMwh || 0), 0).toFixed(1)
    );

    const totalCo2SavedTons = Number(
      designs.reduce((acc, d) => acc + (d.co2SavedTons || 0), 0).toFixed(0)
    );

    const unreadNotificationsCount = await Notification.countDocuments({
      userId: userObjectId,
      read: false,
    });

    const recentFarms = farms.slice(0, 5).map((f) => ({
      id: f._id.toString(),
      name: f.name,
      location: f.locationName,
      state: f.state,
      areaAcres: f.areaAcres,
      crop: f.cropType,
      suitabilityScore: f.suitabilityScore,
      status: f.status,
      soilType: f.soilType,
      slope: f.slope,
      irrigation: f.irrigation,
      gridProximityKm: f.gridProximityKm,
      imagePath: f.imagePath,
      coordinates: f.coordinates,
    }));

    return {
      totalFarms,
      totalAreaAcres,
      designsCreated,
      totalPvCapacityKw,
      averageSuitabilityScore: avgSuitability,
      estimatedAnnualEnergyMwh,
      totalCo2SavedTons,
      unreadNotificationsCount,
      recentFarms,
    };
  }
}
