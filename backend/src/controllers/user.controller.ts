import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { UserService } from '../services/user.service';

export class UserController {
  public static async getProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const user = await UserService.updateProfile(req.user!._id.toString(), {});
      res.status(200).json({
        success: true,
        message: 'User profile retrieved.',
        data: { user },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const user = await UserService.updateProfile(req.user!._id.toString(), req.body);
      res.status(200).json({
        success: true,
        message: 'Profile updated successfully.',
        data: { user },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updatePreferences(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const user = await UserService.updatePreferences(req.user!._id.toString(), req.body);
      res.status(200).json({
        success: true,
        message: 'Preferences updated successfully.',
        data: { user },
      });
    } catch (error) {
      next(error);
    }
  }
}
