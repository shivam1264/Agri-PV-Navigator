import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { VisualizationService } from '../services/visualization.service';
import { SunPositionEngine } from '../calculations/sunPositionEngine';

export class VisualizationController {
  public static async getVisualizationConfig(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const config = await VisualizationService.getVisualizationConfig(
        req.user!._id.toString(),
        req.params.id
      );
      res.status(200).json({
        success: true,
        message: 'Visualization configuration retrieved.',
        data: { config },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getSunSimulation(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const hour = req.query.hour ? parseFloat(req.query.hour as string) : 10.5;
      const lat = req.query.lat ? parseFloat(req.query.lat as string) : 25.4358;
      const lng = req.query.lng ? parseFloat(req.query.lng as string) : 81.8463;

      const sun = SunPositionEngine.calculateSun(hour, lat, lng);
      res.status(200).json({
        success: true,
        message: 'Sun simulation parameters calculated.',
        data: { sun },
      });
    } catch (error) {
      next(error);
    }
  }
}
