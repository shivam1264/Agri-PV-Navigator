import { z } from 'zod';

export const createDesignSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Design name is required'),
    mountingType: z.enum(['elevated', 'fixedTilt', 'singleAxisTracker']).default('elevated'),
    tiltDegrees: z.number().min(0).max(50).default(20),
    orientation: z.enum(['south', 'southEast', 'southWest']).default('south'),
    rowSpacingMeters: z.number().min(2).max(15).default(6),
    panelCoveragePercent: z.number().min(10).max(80).default(40),
    panelHeightMeters: z.number().min(1.5).max(6).optional(),
    isDefaultOrPrimary: z.boolean().optional().default(false),
  }),
});

export const updateDesignSchema = z.object({
  body: z.object({
    name: z.string().min(1).optional(),
    mountingType: z.enum(['elevated', 'fixedTilt', 'singleAxisTracker']).optional(),
    tiltDegrees: z.number().min(0).max(50).optional(),
    orientation: z.enum(['south', 'southEast', 'southWest']).optional(),
    rowSpacingMeters: z.number().min(2).max(15).optional(),
    panelCoveragePercent: z.number().min(10).max(80).optional(),
    panelHeightMeters: z.number().min(1.5).max(6).optional(),
    isDefaultOrPrimary: z.boolean().optional(),
  }),
});
