import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { SuitabilityService } from '../services/suitability.service';

export class SuitabilityController {
  public static async getSuitability(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const assessment = await SuitabilityService.getByFarm(req.user!._id.toString(), req.params.farmId);
      res.status(200).json({
        success: true,
        message: 'Site suitability assessment retrieved.',
        data: { assessment },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async recalculateSuitability(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const assessment = await SuitabilityService.evaluateAndSave(
        req.user!._id.toString(),
        req.params.farmId,
        req.body
      );
      res.status(200).json({
        success: true,
        message: 'Site suitability re-evaluated successfully.',
        data: { assessment },
      });
    } catch (error) {
      next(error);
    }
  }
}
