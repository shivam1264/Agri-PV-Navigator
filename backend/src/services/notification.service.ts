import mongoose from 'mongoose';
import { Notification, INotification } from '../models/notification.model';
import { AppError } from '../middleware/error.middleware';

export class NotificationService {
  public static async getNotifications(userId: string): Promise<INotification[]> {
    return Notification.find({ userId: new mongoose.Types.ObjectId(userId) }).sort({ createdAt: -1 });
  }

  public static async markAsRead(userId: string, notificationId: string): Promise<INotification> {
    if (!mongoose.Types.ObjectId.isValid(notificationId)) {
      const err: AppError = new Error('Invalid notification identifier.');
      err.statusCode = 400;
      throw err;
    }

    const item = await Notification.findOneAndUpdate(
      { _id: notificationId, userId: new mongoose.Types.ObjectId(userId) },
      { read: true },
      { new: true }
    );

    if (!item) {
      const err: AppError = new Error('Notification not found.');
      err.statusCode = 404;
      throw err;
    }

    return item;
  }

  public static async markAllAsRead(userId: string): Promise<void> {
    await Notification.updateMany({ userId: new mongoose.Types.ObjectId(userId) }, { read: true });
  }
}
