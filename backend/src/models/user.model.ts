import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUserPreferences {
  theme: 'Light' | 'Dark';
  language: 'English' | 'Hindi (हिंदी)';
  units: string;
  notificationsEnabled: boolean;
  accessibilityPreferences: {
    highContrast: boolean;
    largeText: boolean;
  };
}

export interface IUser extends Document {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  passwordHash: string;
  profileImage?: string;
  preferences: IUserPreferences;
  refreshTokenHash?: string;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
}

const UserSchema = new Schema<IUser>(
  {
    firstName: { type: String, required: true, trim: true },
    lastName: { type: String, required: false, default: '', trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    phone: { type: String, trim: true },
    passwordHash: { type: String, required: true },
    profileImage: { type: String, default: 'assets/images/farmer_avatar.jpg' },
    preferences: {
      theme: { type: String, enum: ['Light', 'Dark'], default: 'Light' },
      language: { type: String, default: 'English' },
      units: { type: String, default: 'Metric (SI, acres)' },
      notificationsEnabled: { type: Boolean, default: true },
      accessibilityPreferences: {
        highContrast: { type: Boolean, default: false },
        largeText: { type: Boolean, default: false },
      },
    },
    refreshTokenHash: { type: String },
  },
  {
    timestamps: true,
  }
);

UserSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

export const User = mongoose.model<IUser>('User', UserSchema);
