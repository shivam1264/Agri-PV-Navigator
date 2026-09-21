import { User, IUserPreferences } from '../models/user.model';
import { AppError } from '../middleware/error.middleware';
import { AuthService } from './auth.service';

export class UserService {
  public static async updateProfile(
    userId: string,
    data: { firstName?: string; lastName?: string; phone?: string; profileImage?: string }
  ) {
    const user = await User.findById(userId);
    if (!user) {
      const err: AppError = new Error('User not found.');
      err.statusCode = 404;
      err.code = 'USER_NOT_FOUND';
      throw err;
    }

    if (data.firstName !== undefined) user.firstName = data.firstName.trim();
    if (data.lastName !== undefined) user.lastName = data.lastName.trim();
    if (data.phone !== undefined) user.phone = data.phone.trim();
    if (data.profileImage !== undefined) user.profileImage = data.profileImage;

    await user.save();
    return AuthService.getMe(userId);
  }

  public static async updatePreferences(userId: string, prefs: Partial<IUserPreferences>) {
    const user = await User.findById(userId);
    if (!user) {
      const err: AppError = new Error('User not found.');
      err.statusCode = 404;
      err.code = 'USER_NOT_FOUND';
      throw err;
    }

    if (prefs.theme !== undefined) user.preferences.theme = prefs.theme;
    if (prefs.language !== undefined) user.preferences.language = prefs.language;
    if (prefs.units !== undefined) user.preferences.units = prefs.units;
    if (prefs.notificationsEnabled !== undefined) {
      user.preferences.notificationsEnabled = prefs.notificationsEnabled;
    }
    if (prefs.accessibilityPreferences) {
      user.preferences.accessibilityPreferences = {
        ...user.preferences.accessibilityPreferences,
        ...prefs.accessibilityPreferences,
      };
    }

    user.markModified('preferences');
    await user.save();
    return AuthService.getMe(userId);
  }
}
