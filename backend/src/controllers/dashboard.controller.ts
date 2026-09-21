import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { DashboardService } from '../services/dashboard.service';

export class DashboardController {
  public static async getSummary(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const summary = await DashboardService.getSummary(req.user!._id.toString());
      res.status(200).json({
        success: true,
        message: 'Dashboard summary retrieved.',
        data: { summary },
      });
    } catch (error) {
      next(error);
    }
  }
}
