import mongoose, { Document, Schema } from 'mongoose';

export interface IFarm extends Document {
  userId: mongoose.Types.ObjectId;
  name: string;
  locationName: string;
  state: string;
  areaAcres: number;
  cropType: string;
  soilType: string;
  slope: string;
  irrigation: string;
  gridProximityKm: number;
  currentLandUse: string;
  coordinates: string[];
  location: {
    type: 'Point';
    coordinates: [number, number]; // [longitude, latitude]
  };
  boundary?: {
    type: 'Polygon';
    coordinates: number[][][];
  };
  status: 'active' | 'draft' | 'analyzed';
  suitabilityScore: number;
  imagePath: string;
  createdAt: Date;
  updatedAt: Date;
}

const FarmSchema = new Schema<IFarm>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    name: { type: String, required: true, trim: true },
    locationName: { type: String, required: true, trim: true },
    state: { type: String, default: 'Uttar Pradesh, India', trim: true },
    areaAcres: { type: Number, required: true, min: 0.1 },
    cropType: { type: String, required: true, default: 'Wheat' },
    soilType: { type: String, required: true, default: 'Loamy' },
    slope: { type: String, required: true, default: '< 2% (Almost flat)' },
    irrigation: { type: String, required: true, default: 'Available' },
    gridProximityKm: { type: Number, required: true, default: 2.4 },
    currentLandUse: { type: String, default: 'Agriculture' },
    coordinates: [{ type: String }],
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [lng, lat]
        default: [81.8463, 25.4358], // Prayagraj default
      },
    },
    boundary: {
      type: {
        type: String,
        enum: ['Polygon'],
      },
      coordinates: [[[Number]]],
    },
    status: {
      type: String,
      enum: ['active', 'draft', 'analyzed'],
      default: 'draft',
      index: true,
    },
    suitabilityScore: { type: Number, default: 0 },
    imagePath: { type: String, default: 'assets/images/farm_wheat.jpg' },
  },
  {
    timestamps: true,
  }
);

FarmSchema.index({ location: '2dsphere' });
FarmSchema.index({ userId: 1, createdAt: -1 });

export const Farm = mongoose.model<IFarm>('Farm', FarmSchema);
