import mongoose from 'mongoose';
import { AgriPvDesign, IAgriPvDesign } from '../models/design.model';
import { FarmService } from './farm.service';
import { AgriPvEngine } from '../calculations/agriPvEngine';
import { AppError } from '../middleware/error.middleware';

export class DesignService {
  public static async getDesignsByFarm(userId: string, farmId: string): Promise<IAgriPvDesign[]> {
    const farm = await FarmService.getFarmById(userId, farmId);

    let designs = await AgriPvDesign.find({
      farmId: farm._id,
      userId: new mongoose.Types.ObjectId(userId),
    }).sort({ createdAt: -1 });

    // If no designs exist yet, generate the standard 3 comparative design options for this farm
    if (designs.length === 0) {
      designs = await this.seedInitialDesignsForFarm(userId, farm);
    }

    return designs;
  }

  public static async getDesignById(userId: string, designId: string): Promise<IAgriPvDesign> {
    if (!mongoose.Types.ObjectId.isValid(designId)) {
      const err: AppError = new Error('Invalid design identifier.');
      err.statusCode = 400;
      err.code = 'INVALID_ID';
      throw err;
    }

    const design = await AgriPvDesign.findOne({
      _id: designId,
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!design) {
      const err: AppError = new Error('Design not found or unauthorized.');
      err.statusCode = 404;
      err.code = 'DESIGN_NOT_FOUND';
      throw err;
    }

    return design;
  }

  public static async createDesign(userId: string, farmId: string, data: any): Promise<IAgriPvDesign> {
    const farm = await FarmService.getFarmById(userId, farmId);

    const mounting = data.mountingType || 'elevated';
    let defaultHeight = 2.8;
    if (mounting === 'fixedTilt') defaultHeight = 1.8;
    else if (mounting === 'singleAxisTracker') defaultHeight = 3.2;

    const height = data.panelHeightMeters ?? defaultHeight;

    const calc = AgriPvEngine.calculateDesign({
      areaAcres: farm.areaAcres,
      crop: farm.cropType,
      mountingType: mounting,
      tiltDegrees: data.tiltDegrees ?? 20,
      orientation: data.orientation || 'south',
      rowSpacingMeters: data.rowSpacingMeters ?? 6.0,
      panelCoveragePercent: data.panelCoveragePercent ?? 40.0,
      panelHeightMeters: height,
    });

    const design = new AgriPvDesign({
      farmId: farm._id,
      userId: new mongoose.Types.ObjectId(userId),
      name: data.name || 'Agri-PV Design',
      mountingType: mounting,
      tiltDegrees: data.tiltDegrees ?? 20,
      orientation: data.orientation || 'south',
      rowSpacingMeters: data.rowSpacingMeters ?? 6.0,
      panelCoveragePercent: data.panelCoveragePercent ?? 40.0,
      panelHeightMeters: height,
      panelPowerWatts: data.panelPowerWatts || 550,
      isDefaultOrPrimary: data.isDefaultOrPrimary || false,
      ...calc,
    });

    await design.save();
    return design;
  }

  public static async updateDesign(userId: string, designId: string, data: any): Promise<IAgriPvDesign> {
    const design = await this.getDesignById(userId, designId);
    const farm = await FarmService.getFarmById(userId, design.farmId.toString());

    if (data.name !== undefined) design.name = data.name;
    if (data.mountingType !== undefined) design.mountingType = data.mountingType;
    if (data.tiltDegrees !== undefined) design.tiltDegrees = data.tiltDegrees;
    if (data.orientation !== undefined) design.orientation = data.orientation;
    if (data.rowSpacingMeters !== undefined) design.rowSpacingMeters = data.rowSpacingMeters;
    if (data.panelCoveragePercent !== undefined) design.panelCoveragePercent = data.panelCoveragePercent;
    if (data.panelHeightMeters !== undefined) design.panelHeightMeters = data.panelHeightMeters;
    if (data.isDefaultOrPrimary !== undefined) design.isDefaultOrPrimary = data.isDefaultOrPrimary;

    // Recalculate dynamic outputs
    const calc = AgriPvEngine.calculateDesign({
      areaAcres: farm.areaAcres,
      crop: farm.cropType,
      mountingType: design.mountingType,
      tiltDegrees: design.tiltDegrees,
      orientation: design.orientation,
      rowSpacingMeters: design.rowSpacingMeters,
      panelCoveragePercent: design.panelCoveragePercent,
      panelHeightMeters: design.panelHeightMeters,
    });

    Object.assign(design, calc);
    await design.save();

    return design;
  }

  public static async deleteDesign(userId: string, designId: string): Promise<void> {
    const design = await this.getDesignById(userId, designId);
    await AgriPvDesign.deleteOne({ _id: design._id });
  }

  private static async seedInitialDesignsForFarm(userId: string, farm: any): Promise<IAgriPvDesign[]> {
    const configs = [
      {
        name: 'Design A (Fixed Tilt)',
        mountingType: 'fixedTilt' as const,
        tiltDegrees: 18,
        orientation: 'south' as const,
        rowSpacingMeters: 8.0,
        panelCoveragePercent: 28.0,
        panelHeightMeters: 2.2,
      },
      {
        name: 'Design B (Elevated Stilt - Optimal)',
        mountingType: 'elevated' as const,
        tiltDegrees: 20,
        orientation: 'south' as const,
        rowSpacingMeters: 6.0,
        panelCoveragePercent: 40.0,
        panelHeightMeters: 2.8,
        isDefaultOrPrimary: true,
      },
      {
        name: 'Design C (Single Axis Tracker)',
        mountingType: 'singleAxisTracker' as const,
        tiltDegrees: 25,
        orientation: 'south' as const,
        rowSpacingMeters: 5.0,
        panelCoveragePercent: 52.0,
        panelHeightMeters: 3.2,
      },
    ];

    const results: IAgriPvDesign[] = [];
    for (const cfg of configs) {
      const calc = AgriPvEngine.calculateDesign({
        areaAcres: farm.areaAcres,
        crop: farm.cropType,
        ...cfg,
      });

      const d = new AgriPvDesign({
        farmId: farm._id,
        userId: new mongoose.Types.ObjectId(userId),
        ...cfg,
        panelPowerWatts: 550,
        ...calc,
      });
      await d.save();
      results.push(d);
    }

    return results;
  }
}
