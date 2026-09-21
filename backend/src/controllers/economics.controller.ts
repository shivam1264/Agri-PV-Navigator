import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { EconomicsService } from '../services/economics.service';

export class EconomicsController {
  public static async getEconomics(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const assessment = await EconomicsService.getEconomics(
        req.user!._id.toString(),
        req.params.id
      );
      res.status(200).json({
        success: true,
        message: 'Techno-economic assessment calculated.',
        data: { assessment },
      });
    } catch (error) {
      next(error);
    }
  }
}
