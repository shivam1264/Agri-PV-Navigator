import mongoose, { Document, Schema } from 'mongoose';

export interface ISuitabilityFactor {
  id: string;
  name: string;
  score: number;
  metricValue: string;
  shortReason: string;
  fullAssessment: string;
  impact: string;
  accentColorHex: string;
}

export interface ISuitabilityAnalysis extends Document {
  farmId: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  solarResourceScore: number;
  slopeScore: number;
  soilScore: number;
  waterScore: number;
  cropCompatibilityScore: number;
  gridProximityScore: number;
  overallScore: number;
  summary: string;
  recommendations: string[];
  factors: ISuitabilityFactor[];
  calculationVersion: string;
  createdAt: Date;
  updatedAt: Date;
}

const SuitabilityFactorSchema = new Schema<ISuitabilityFactor>(
  {
    id: { type: String, required: true },
    name: { type: String, required: true },
    score: { type: Number, required: true },
    metricValue: { type: String, required: true },
    shortReason: { type: String, required: true },
    fullAssessment: { type: String, required: true },
    impact: { type: String, required: true },
    accentColorHex: { type: String, required: true, default: '#22C55E' },
  },
  { _id: false }
);

const SuitabilityAnalysisSchema = new Schema<ISuitabilityAnalysis>(
  {
    farmId: { type: Schema.Types.ObjectId, ref: 'Farm', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    solarResourceScore: { type: Number, required: true },
    slopeScore: { type: Number, required: true },
    soilScore: { type: Number, required: true },
    waterScore: { type: Number, required: true },
    cropCompatibilityScore: { type: Number, required: true },
    gridProximityScore: { type: Number, required: true },
    overallScore: { type: Number, required: true },
    summary: { type: String, required: true },
    recommendations: [{ type: String }],
    factors: [SuitabilityFactorSchema],
    calculationVersion: { type: String, default: '1.0.0' },
  },
  {
    timestamps: true,
  }
);

SuitabilityAnalysisSchema.index({ farmId: 1, userId: 1 });

export const SuitabilityAnalysis = mongoose.model<ISuitabilityAnalysis>(
  'SuitabilityAnalysis',
  SuitabilityAnalysisSchema
);
