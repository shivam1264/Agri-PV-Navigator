import { DesignService } from './design.service';
import { FarmService } from './farm.service';

export interface IVisualizationConfig {
  designId: string;
  farmId: string;
  panelTilt: number; // 0 - 45 deg
  panelHeight: number; // 1.5 - 5.0 m
  rowSpacing: number; // 3.0 - 12.0 m
  orientationDegrees: number; // 90 to 270, south = 180
  panelRows: number; // 2 to 6
  cropType: string;
  farmSizeAcres: number;
  pvCapacityKw: number;
  isMachineryCompatible: boolean;
  clearanceStatus: string;
}

export class VisualizationService {
  public static async getVisualizationConfig(userId: string, designId: string): Promise<IVisualizationConfig> {
    const design = await DesignService.getDesignById(userId, designId);
    const farm = await FarmService.getFarmById(userId, design.farmId.toString());

    let orientationDegrees = 180.0;
    if (design.orientation === 'southEast') orientationDegrees = 135.0;
    else if (design.orientation === 'southWest') orientationDegrees = 225.0;

    return {
      designId: design._id.toString(),
      farmId: farm._id.toString(),
      panelTilt: design.tiltDegrees,
      panelHeight: design.panelHeightMeters,
      rowSpacing: design.rowSpacingMeters,
      orientationDegrees,
      panelRows: design.numberOfRows || 3,
      cropType: farm.cropType,
      farmSizeAcres: farm.areaAcres,
      pvCapacityKw: design.pvCapacityKw,
      isMachineryCompatible: design.isMachineryCompatible,
      clearanceStatus: design.clearanceStatus,
    };
  }
}
