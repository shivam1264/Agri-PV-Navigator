import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { DesignService } from '../services/design.service';

export class DesignController {
  public static async getDesignsByFarm(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const designs = await DesignService.getDesignsByFarm(req.user!._id.toString(), req.params.farmId);
      res.status(200).json({
        success: true,
        message: 'Designs retrieved.',
        data: { designs },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getDesignById(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const design = await DesignService.getDesignById(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Design retrieved.',
        data: { design },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async createDesign(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const design = await DesignService.createDesign(
        req.user!._id.toString(),
        req.params.farmId,
        req.body
      );
      res.status(201).json({
        success: true,
        message: 'Design created and calculated.',
        data: { design },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateDesign(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const design = await DesignService.updateDesign(
        req.user!._id.toString(),
        req.params.id,
        req.body
      );
      res.status(200).json({
        success: true,
        message: 'Design updated and recalculated.',
        data: { design },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async deleteDesign(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      await DesignService.deleteDesign(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Design deleted.',
      });
    } catch (error) {
      next(error);
    }
  }
}
