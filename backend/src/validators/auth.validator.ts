import { z } from 'zod';

export const registerSchema = z.object({
  body: z.object({
    firstName: z.string().nullish(),
    lastName: z.string().nullish(),
    fullName: z.string().nullish(),
    name: z.string().nullish(),
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters long'),
    phone: z.string().nullish(),
    phoneNumber: z.string().nullish(),
    profileImage: z.string().nullish(),
    organization: z.string().nullish(),
    preferredTheme: z.enum(['Light', 'Dark']).nullish(),
    preferredLanguage: z.string().nullish(),
    units: z.string().nullish(),
    notificationsEnabled: z.boolean().nullish(),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
  }),
});

export const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});
