import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { NotificationService } from '../services/notification.service';

export class NotificationController {
  public static async getNotifications(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const notifications = await NotificationService.getNotifications(req.user!._id.toString());
      res.status(200).json({
        success: true,
        message: 'Notifications retrieved.',
        data: { notifications },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async markAsRead(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const notification = await NotificationService.markAsRead(
        req.user!._id.toString(),
        req.params.id
      );
      res.status(200).json({
        success: true,
        message: 'Notification marked as read.',
        data: { notification },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async markAllAsRead(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      await NotificationService.markAllAsRead(req.user!._id.toString());
      res.status(200).json({
        success: true,
        message: 'All notifications marked as read.',
      });
    } catch (error) {
      next(error);
    }
  }
}
