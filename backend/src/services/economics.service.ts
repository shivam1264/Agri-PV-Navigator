import { DesignService } from './design.service';
import { FinancialEngine, IEconomicProjection } from '../calculations/financialEngine';

export class EconomicsService {
  public static async getEconomics(userId: string, designId: string): Promise<IEconomicProjection> {
    const design = await DesignService.getDesignById(userId, designId);

    return FinancialEngine.calculateEconomics(
      design.pvCapacityKw,
      design.annualEnergyMwh,
      design.projectCostCr,
      design.paybackYears,
      design.npvLakhs,
      design.co2SavedTons
    );
  }
}
