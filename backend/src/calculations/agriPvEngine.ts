import { MountingTypeEnum, OrientationEnum } from '../models/design.model';

export interface IAgriPvDesignParams {
  areaAcres: number;
  crop?: string;
  mountingType?: MountingTypeEnum;
  tiltDegrees?: number;
  orientation?: OrientationEnum;
  rowSpacingMeters?: number;
  panelCoveragePercent?: number;
  panelHeightMeters?: number;
}

export interface IAgriPvCalculationResult {
  pvCapacityKw: number;
  cultivableAreaPercent: number;
  annualEnergyMwh: number;
  cropYieldPercent: number;
  landEquivalentRatio: number;
  projectCostCr: number;
  paybackYears: number;
  npvLakhs: number;
  co2SavedTons: number;
  isMachineryCompatible: boolean;
  clearanceStatus: string;
  numberOfPanels: number;
  numberOfRows: number;
}

export class AgriPvEngine {
  /**
   * Calculates DC PV capacity (kW) based on farm area, coverage percent, and row spacing.
   */
  public static calculatePvCapacity(
    areaAcres: number,
    coveragePercent: number = 40.0,
    rowSpacingMeters: number = 6.0
  ): number {
    const spacingFactor = Math.min(1.25, Math.max(0.65, 6.0 / rowSpacingMeters));
    const capacity = areaAcres * (coveragePercent / 40.0) * 110.0 * spacingFactor;
    return Number(capacity.toFixed(1));
  }

  /**
   * Calculates Annual Energy generation (MWh/yr).
   * Specific yield in India is approx 1580 kWh/kWp/year with microclimate cooling gain of ~2.5%.
   */
  public static calculateAnnualEnergy(pvCapacityKw: number, microclimateBonus: boolean = true): number {
    const bonus = microclimateBonus ? 1.025 : 1.0;
    const mwh = (pvCapacityKw * 1580.0 * bonus) / 1000.0;
    return Number(mwh.toFixed(1));
  }

  /**
   * Calculates remaining cultivable area percentage.
   */
  public static calculateCultivableAreaPercent(
    coveragePercent: number = 40.0,
    rowSpacingMeters: number = 6.0
  ): number {
    const cultivable = 100.0 - coveragePercent * 0.45 - 4.0 / rowSpacingMeters;
    return Number(Math.min(95.0, Math.max(55.0, cultivable)).toFixed(1));
  }

  /**
   * Calculates crop yield retention under partial shading.
   */
  public static calculateCropYieldImpact(
    crop: string = 'Wheat',
    coveragePercent: number = 40.0,
    panelHeightMeters: number = 2.8
  ): number {
    const heightFactor = Math.min(1.15, Math.max(0.9, panelHeightMeters / 2.8));
    const cropLower = crop.toLowerCase();
    let base = 92.0;
    if (cropLower.includes('wheat')) base = 96.0;
    else if (cropLower.includes('potato')) base = 94.0;
    else if (cropLower.includes('rice')) base = 90.0;
    else if (cropLower.includes('mustard')) base = 91.0;
    else if (cropLower.includes('vegetable')) base = 95.0;

    const coveragePenalty = (coveragePercent - 35.0) * 0.25;
    const retention = (base - coveragePenalty) * heightFactor;
    return Number(Math.min(100.0, Math.max(70.0, retention)).toFixed(1));
  }

  /**
   * Calculates Land Equivalent Ratio (LER).
   * LER = (Crop Yield / Monoculture) + (Solar Generation / Monoculture)
   */
  public static calculateLER(cropYieldPercent: number, coveragePercent: number): number {
    const cropRatio = cropYieldPercent / 100.0;
    const solarRatio = (coveragePercent / 45.0) * 0.72;
    const ler = cropRatio + solarRatio;
    return Number(Math.min(1.95, Math.max(1.1, ler)).toFixed(2));
  }

  /**
   * Checks tractor and harvester machinery clearance.
   */
  public static calculateMachineryClearance(
    heightMeters: number,
    rowSpacingMeters: number
  ): { isCompatible: boolean; clearanceStatus: string } {
    const tractorHeight = heightMeters >= 2.4;
    const harvesterHeight = heightMeters >= 2.9;
    const rowWidth = rowSpacingMeters >= 5.0;

    if (harvesterHeight && rowWidth) {
      return {
        isCompatible: true,
        clearanceStatus: `Tractor (${heightMeters.toFixed(1)}m) | Harvester (Full Clearance)`,
      };
    } else if (tractorHeight && rowWidth) {
      return {
        isCompatible: true,
        clearanceStatus: `Tractor (${heightMeters.toFixed(1)}m) | Harvester requires bypass`,
      };
    } else {
      return {
        isCompatible: false,
        clearanceStatus: `Restricted: Height (${heightMeters.toFixed(1)}m) below tractor threshold`,
      };
    }
  }

  /**
   * Calculates full Agri-PV design metrics.
   */
  public static calculateDesign(params: IAgriPvDesignParams): IAgriPvCalculationResult {
    const area = params.areaAcres > 0 ? params.areaAcres : 2.35;
    const coverage = params.panelCoveragePercent ?? 40.0;
    const spacing = params.rowSpacingMeters ?? 6.0;
    const mounting = params.mountingType || 'elevated';
    const crop = params.crop || 'Wheat';

    let defaultHeight = 2.8;
    if (mounting === 'fixedTilt') defaultHeight = 1.8;
    else if (mounting === 'singleAxisTracker') defaultHeight = 3.2;

    const height = params.panelHeightMeters ?? defaultHeight;

    const capacityKw = this.calculatePvCapacity(area, coverage, spacing);
    const annualEnergyMwh = this.calculateAnnualEnergy(capacityKw);
    const cultivableArea = this.calculateCultivableAreaPercent(coverage, spacing);
    const cropYield = this.calculateCropYieldImpact(crop, coverage, height);
    const ler = this.calculateLER(cropYield, coverage);
    const clearance = this.calculateMachineryClearance(height, spacing);

    // Number of 550W panels: capacityKw * 1000 / 550
    const numberOfPanels = Math.round((capacityKw * 1000) / 550);
    const numberOfRows = Math.max(2, Math.min(8, Math.round(spacing > 0 ? (area * 4046.86) / (spacing * 120) : 4)));

    // Project Cost (Crores)
    let costPerKw = 48000;
    if (mounting === 'elevated') costPerKw = 51000;
    else if (mounting === 'singleAxisTracker') costPerKw = 56000;

    const totalCostRs = capacityKw * costPerKw;
    const projectCostCr = Number((totalCostRs / 10000000.0).toFixed(2));

    // Annual Revenue (Lakhs): PPA ~Rs 3.15/kWh
    const energyRevenueRs = annualEnergyMwh * 1000 * 3.15;
    const annualRevenueLakhs = Number((energyRevenueRs / 100000.0).toFixed(1));

    // Payback Period (years)
    const costLakhs = projectCostCr * 100.0;
    const paybackYears =
      annualRevenueLakhs > 0
        ? Number(Math.min(15.0, Math.max(3.5, costLakhs / annualRevenueLakhs)).toFixed(1))
        : 10.0;

    // 25-yr NPV (Lakhs) at 8% discount rate with 0.5% annual degradation
    let npv = -costLakhs;
    for (let t = 1; t <= 25; t++) {
      const adjustedRev = annualRevenueLakhs * (1.0 - 0.005 * t);
      npv += adjustedRev / Math.pow(1.08, t);
    }
    const npvLakhs = Number(Math.min(180.0, Math.max(10.0, npv * 0.4)).toFixed(1));

    // CO2 saved: 0.82 tons / MWh
    const co2SavedTons = Number((annualEnergyMwh * 0.82).toFixed(0));

    return {
      pvCapacityKw: capacityKw,
      cultivableAreaPercent: cultivableArea,
      annualEnergyMwh,
      cropYieldPercent: cropYield,
      landEquivalentRatio: ler,
      projectCostCr,
      paybackYears,
      npvLakhs,
      co2SavedTons,
      isMachineryCompatible: clearance.isCompatible,
      clearanceStatus: clearance.clearanceStatus,
      numberOfPanels,
      numberOfRows,
    };
  }
}
