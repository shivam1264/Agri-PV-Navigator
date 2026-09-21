import dotenv from 'dotenv';
import path from 'path';
import { z } from 'zod';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const envSchema = z.object({
  PORT: z.string().default('5000').transform(Number),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  MONGODB_URI: z.string().default('mongodb://localhost:27017/agri_pv_navigator'),
  JWT_ACCESS_SECRET: z.string().default('agri_pv_jwt_access_super_secret_key_2026_x99a!'),
  JWT_REFRESH_SECRET: z.string().default('agri_pv_jwt_refresh_super_secret_key_2026_y88b!'),
  ACCESS_TOKEN_EXPIRES: z.string().default('15m'),
  REFRESH_TOKEN_EXPIRES: z.string().default('7d'),
  CORS_ORIGIN: z.string().default('*'),
  GEOCODING_API_KEY: z.string().optional(),
  WEATHER_API_KEY: z.string().optional(),
  SOLAR_API_KEY: z.string().optional(),
});

export const env = envSchema.parse(process.env);
