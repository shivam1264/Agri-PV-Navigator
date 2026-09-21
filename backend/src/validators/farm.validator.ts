import { z } from 'zod';

export const createFarmSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Farm name is required'),
    locationName: z.string().nullish(),
    district: z.string().nullish(),
    state: z.string().nullish().default('Uttar Pradesh, India'),
    areaAcres: z.number().positive('Area must be positive'),
    cropType: z.string().min(1, 'Crop type is required'),
    soilType: z.string().nullish().default('Loamy'),
    slope: z.string().nullish().default('< 2% (Almost flat)'),
    irrigation: z.string().nullish().default('Available'),
    irrigationSource: z.string().nullish().default('Borewell'),
    electricityTariff: z.number().nullish().default(6.5),
    surveyNumber: z.string().nullish(),
    gridProximityKm: z.number().nonnegative().optional().default(2.4),
    currentLandUse: z.string().optional().default('Agriculture'),
    coordinates: z.array(z.string()).optional().default([]),
    latitude: z.number().optional().default(25.4358),
    longitude: z.number().optional().default(81.8463),
    boundary: z
      .object({
        type: z.literal('Polygon'),
        coordinates: z.array(z.array(z.array(z.number()))),
      })
      .optional(),
    status: z.enum(['active', 'draft', 'analyzed']).optional().default('draft'),
    imagePath: z.string().optional().default('assets/images/farm_wheat.jpg'),
  }),
});

export const updateFarmSchema = z.object({
  body: z.object({
    name: z.string().min(1).optional(),
    locationName: z.string().min(1).optional(),
    state: z.string().optional(),
    areaAcres: z.number().positive().optional(),
    cropType: z.string().min(1).optional(),
    soilType: z.string().optional(),
    slope: z.string().optional(),
    irrigation: z.string().optional(),
    gridProximityKm: z.number().nonnegative().optional(),
    currentLandUse: z.string().optional(),
    coordinates: z.array(z.string()).optional(),
    latitude: z.number().optional(),
    longitude: z.number().optional(),
    boundary: z
      .object({
        type: z.literal('Polygon'),
        coordinates: z.array(z.array(z.array(z.number()))),
      })
      .optional(),
    status: z.enum(['active', 'draft', 'analyzed']).optional(),
    imagePath: z.string().optional(),
  }),
});
