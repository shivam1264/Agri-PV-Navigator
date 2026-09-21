import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { User, IUser } from '../models/user.model';
import { AppError } from '../middleware/error.middleware';

export interface IAuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
}

export interface IAuthResponse {
  user: {
    id: string;
    firstName: string;
    lastName: string;
    name: string;
    email: string;
    phone?: string;
    initials: string;
    profileImage: string;
    preferences: any;
    totalFarms: number;
    totalAreaAcres: number;
    designsCreated: number;
  };
  tokens: IAuthTokens;
}

export class AuthService {
  public static generateTokens(userId: string): IAuthTokens {
    const accessToken = jwt.sign({ userId }, env.JWT_ACCESS_SECRET, {
      expiresIn: env.ACCESS_TOKEN_EXPIRES as any,
    });

    const refreshToken = jwt.sign({ userId }, env.JWT_REFRESH_SECRET, {
      expiresIn: env.REFRESH_TOKEN_EXPIRES as any,
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: env.ACCESS_TOKEN_EXPIRES,
    };
  }

  public static async register(data: {
    firstName?: string;
    lastName?: string;
    fullName?: string;
    name?: string;
    email: string;
    password: string;
    phone?: string;
    preferredTheme?: 'Light' | 'Dark';
    preferredLanguage?: string;
    units?: string;
    notificationsEnabled?: boolean;
  }): Promise<IAuthResponse> {
    const combined = data.fullName || data.name;
    let firstName = data.firstName;
    let lastName = data.lastName;
    if ((!firstName || !lastName) && combined) {
      const parts = combined.trim().split(/\s+/);
      firstName = firstName || parts[0] || 'Farmer';
      lastName = lastName || (parts.length > 1 ? parts.slice(1).join(' ') : '');
    }
    const finalFirstName = (firstName || 'Farmer').trim();
    const finalLastName = (lastName || '').trim();

    const normalizedEmail = data.email.toLowerCase().trim();
    const existing = await User.findOne({ email: normalizedEmail });
    if (existing) {
      const err: AppError = new Error('An account with this email address already exists.');
      err.statusCode = 409;
      err.code = 'EMAIL_ALREADY_EXISTS';
      throw err;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const user = new User({
      firstName: finalFirstName,
      lastName: finalLastName,
      email: normalizedEmail,
      phone: data.phone?.trim(),
      passwordHash,
      preferences: {
        theme: data.preferredTheme || 'Light',
        language: data.preferredLanguage || 'English',
        units: data.units || 'Metric (SI, acres)',
        notificationsEnabled: data.notificationsEnabled ?? true,
        accessibilityPreferences: { highContrast: false, largeText: false },
      },
    });

    await user.save();

    const tokens = this.generateTokens(user._id.toString());
    const refreshSalt = await bcrypt.genSalt(10);
    user.refreshTokenHash = await bcrypt.hash(tokens.refreshToken, refreshSalt);
    await user.save();

    return {
      user: this.formatUser(user, 0, 0, 0),
      tokens,
    };
  }

  public static async login(data: { email: string; password: string }): Promise<IAuthResponse> {
    const normalizedEmail = data.email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      const err: AppError = new Error('Invalid email or password.');
      err.statusCode = 401;
      err.code = 'INVALID_CREDENTIALS';
      throw err;
    }

    const isMatch = await user.comparePassword(data.password);
    if (!isMatch) {
      const err: AppError = new Error('Invalid email or password.');
      err.statusCode = 401;
      err.code = 'INVALID_CREDENTIALS';
      throw err;
    }

    const tokens = this.generateTokens(user._id.toString());
    const refreshSalt = await bcrypt.genSalt(10);
    user.refreshTokenHash = await bcrypt.hash(tokens.refreshToken, refreshSalt);
    await user.save();

    // Query real counts from DB
    const { Farm } = await import('../models/farm.model');
    const { AgriPvDesign } = await import('../models/design.model');

    const totalFarms = await Farm.countDocuments({ userId: user._id });
    const farms = await Farm.find({ userId: user._id });
    const totalAreaAcres = farms.reduce((sum, f) => sum + (f.areaAcres || 0), 0);
    const designsCreated = await AgriPvDesign.countDocuments({ userId: user._id });

    return {
      user: this.formatUser(user, totalFarms, Number(totalAreaAcres.toFixed(2)), designsCreated),
      tokens,
    };
  }

  public static async refreshToken(token: string): Promise<IAuthTokens> {
    try {
      const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET) as { userId: string };
      const user = await User.findById(decoded.userId);
      if (!user || !user.refreshTokenHash) {
        const err: AppError = new Error('Invalid session or revoked refresh token.');
        err.statusCode = 401;
        err.code = 'INVALID_REFRESH_TOKEN';
        throw err;
      }

      const isValid = await bcrypt.compare(token, user.refreshTokenHash);
      if (!isValid) {
        const err: AppError = new Error('Revoked refresh token.');
        err.statusCode = 401;
        err.code = 'REVOKED_REFRESH_TOKEN';
        throw err;
      }

      const newTokens = this.generateTokens(user._id.toString());
      const refreshSalt = await bcrypt.genSalt(10);
      user.refreshTokenHash = await bcrypt.hash(newTokens.refreshToken, refreshSalt);
      await user.save();

      return newTokens;
    } catch (e: any) {
      const err: AppError = new Error('Refresh token is expired or invalid.');
      err.statusCode = 401;
      err.code = 'EXPIRED_REFRESH_TOKEN';
      throw err;
    }
  }

  public static async logout(userId: string): Promise<void> {
    await User.findByIdAndUpdate(userId, { $unset: { refreshTokenHash: 1 } });
  }

  public static async getMe(userId: string): Promise<any> {
    const user = await User.findById(userId);
    if (!user) {
      const err: AppError = new Error('User not found.');
      err.statusCode = 404;
      err.code = 'USER_NOT_FOUND';
      throw err;
    }

    const { Farm } = await import('../models/farm.model');
    const { AgriPvDesign } = await import('../models/design.model');

    const totalFarms = await Farm.countDocuments({ userId: user._id });
    const farms = await Farm.find({ userId: user._id });
    const totalAreaAcres = farms.reduce((sum, f) => sum + (f.areaAcres || 0), 0);
    const designsCreated = await AgriPvDesign.countDocuments({ userId: user._id });

    return this.formatUser(user, totalFarms, Number(totalAreaAcres.toFixed(2)), designsCreated);
  }

  public static formatUser(user: IUser, totalFarms: number = 0, totalAreaAcres: number = 0, designsCreated: number = 0) {
    const cleanLastName = (user.lastName && user.lastName.trim().toLowerCase() !== 'user') ? user.lastName.trim() : '';
    const cleanFirstName = user.firstName ? user.firstName.trim() : 'Farmer';
    const fullName = cleanLastName ? `${cleanFirstName} ${cleanLastName}` : cleanFirstName;

    let initials = 'SK';
    if (cleanLastName && cleanLastName.length > 0) {
      initials = `${cleanFirstName.charAt(0)}${cleanLastName.charAt(0)}`.toUpperCase();
    } else if (cleanFirstName.length >= 2) {
      initials = cleanFirstName.substring(0, 2).toUpperCase();
    } else if (cleanFirstName.length === 1) {
      initials = cleanFirstName.toUpperCase();
    }

    return {
      id: user._id.toString(),
      firstName: cleanFirstName,
      lastName: cleanLastName,
      name: fullName,
      email: user.email,
      phone: user.phone || '',
      initials,
      profileImage: user.profileImage || 'assets/images/farmer_avatar.jpg',
      preferences: user.preferences,
      totalFarms,
      totalAreaAcres,
      designsCreated,
    };
  }
}
