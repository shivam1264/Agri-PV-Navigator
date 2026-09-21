import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { FarmService } from '../services/farm.service';

export class FarmController {
  public static async createFarm(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const farm = await FarmService.createFarm(req.user!._id.toString(), req.body);
      res.status(201).json({
        success: true,
        message: 'Farm created and analyzed successfully.',
        data: { farm },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getFarms(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const search = req.query.search as string;
      const farms = await FarmService.getFarms(req.user!._id.toString(), search);
      res.status(200).json({
        success: true,
        message: 'Farms retrieved successfully.',
        data: { farms },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getFarmById(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const farm = await FarmService.getFarmById(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Farm details retrieved.',
        data: { farm },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateFarm(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const farm = await FarmService.updateFarm(req.user!._id.toString(), req.params.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Farm updated successfully.',
        data: { farm },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async deleteFarm(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      await FarmService.deleteFarm(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Farm deleted successfully.',
      });
    } catch (error) {
      next(error);
    }
  }
}
