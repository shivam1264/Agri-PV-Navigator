import mongoose, { Document, Schema } from 'mongoose';

export type MountingTypeEnum = 'elevated' | 'fixedTilt' | 'singleAxisTracker';
export type OrientationEnum = 'south' | 'southEast' | 'southWest';

export interface IAgriPvDesign extends Document {
  farmId: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  name: string;
  mountingType: MountingTypeEnum;
  tiltDegrees: number;
  orientation: OrientationEnum;
  rowSpacingMeters: number;
  panelCoveragePercent: number;
  panelHeightMeters: number;
  panelPowerWatts: number;
  numberOfPanels: number;
  numberOfRows: number;
  // Calculated outputs
  pvCapacityKw: number;
  cultivableAreaPercent: number;
  annualEnergyMwh: number;
  cropYieldPercent: number;
  landEquivalentRatio: number;
  projectCostCr: number;
  paybackYears: number;
  npvLakhs: number;
  co2SavedTons: number;
  isMachineryCompatible: boolean;
  clearanceStatus: string;
  isDefaultOrPrimary: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const AgriPvDesignSchema = new Schema<IAgriPvDesign>(
  {
    farmId: { type: Schema.Types.ObjectId, ref: 'Farm', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    name: { type: String, required: true, trim: true },
    mountingType: {
      type: String,
      enum: ['elevated', 'fixedTilt', 'singleAxisTracker'],
      default: 'elevated',
    },
    tiltDegrees: { type: Number, required: true, min: 0, max: 50, default: 20 },
    orientation: {
      type: String,
      enum: ['south', 'southEast', 'southWest'],
      default: 'south',
    },
    rowSpacingMeters: { type: Number, required: true, min: 2, max: 15, default: 6 },
    panelCoveragePercent: { type: Number, required: true, min: 10, max: 80, default: 40 },
    panelHeightMeters: { type: Number, required: true, min: 1.5, max: 6, default: 2.8 },
    panelPowerWatts: { type: Number, default: 550 },
    numberOfPanels: { type: Number, default: 450 },
    numberOfRows: { type: Number, default: 4 },
    pvCapacityKw: { type: Number, required: true },
    cultivableAreaPercent: { type: Number, required: true },
    annualEnergyMwh: { type: Number, required: true },
    cropYieldPercent: { type: Number, required: true },
    landEquivalentRatio: { type: Number, required: true },
    projectCostCr: { type: Number, required: true },
    paybackYears: { type: Number, required: true },
    npvLakhs: { type: Number, required: true },
    co2SavedTons: { type: Number, required: true },
    isMachineryCompatible: { type: Boolean, required: true, default: true },
    clearanceStatus: { type: String, required: true },
    isDefaultOrPrimary: { type: Boolean, default: false },
  },
  {
    timestamps: true,
  }
);

AgriPvDesignSchema.index({ farmId: 1, userId: 1, createdAt: -1 });

export const AgriPvDesign = mongoose.model<IAgriPvDesign>('AgriPvDesign', AgriPvDesignSchema);
