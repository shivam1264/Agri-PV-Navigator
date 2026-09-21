import mongoose from 'mongoose';
import { env } from './env';

const redactUri = (uri: string): string => {
  try {
    const u = new URL(uri);
    if (u.password) u.password = '***';
    return u.toString();
  } catch {
    return uri.replace(/:[^:@/]+@/, ':***@');
  }
};

export const connectDB = async (): Promise<void> => {
  try {
    mongoose.set('strictQuery', true);
    await mongoose.connect(env.MONGODB_URI);
    console.log(`[Database] Successfully connected to MongoDB: ${redactUri(env.MONGODB_URI)}`);
  } catch (error) {
    console.error('[Database] MongoDB connection error:', error);
    process.exit(1);
  }
};

export const disconnectDB = async (): Promise<void> => {
  try {
    await mongoose.disconnect();
    console.log('[Database] Disconnected from MongoDB');
  } catch (error) {
    console.error('[Database] MongoDB disconnection error:', error);
  }
};
