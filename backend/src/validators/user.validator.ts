import { z } from 'zod';

export const updateUserProfileSchema = z.object({
  body: z.object({
    firstName: z.string().min(1).optional(),
    lastName: z.string().min(1).optional(),
    phone: z.string().optional(),
    profileImage: z.string().optional(),
  }),
});

export const updatePreferencesSchema = z.object({
  body: z.object({
    theme: z.enum(['Light', 'Dark']).optional(),
    language: z.string().optional(),
    units: z.string().optional(),
    notificationsEnabled: z.boolean().optional(),
    accessibilityPreferences: z
      .object({
        highContrast: z.boolean().optional(),
        largeText: z.boolean().optional(),
      })
      .optional(),
  }),
});
