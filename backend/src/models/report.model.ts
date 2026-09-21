import mongoose, { Document, Schema } from 'mongoose';

export type ReportTypeEnum = 'proposal' | 'technical' | 'financial' | 'environmental';

export interface IReport extends Document {
  userId: mongoose.Types.ObjectId;
  farmId: mongoose.Types.ObjectId;
  designId?: mongoose.Types.ObjectId;
  title: string;
  farmName: string;
  reportType: ReportTypeEnum;
  fileSize: string;
  fileUrl: string;
  filePath: string;
  status: 'generating' | 'completed' | 'failed';
  downloadCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const ReportSchema = new Schema<IReport>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    farmId: { type: Schema.Types.ObjectId, ref: 'Farm', required: true, index: true },
    designId: { type: Schema.Types.ObjectId, ref: 'AgriPvDesign' },
    title: { type: String, required: true, trim: true },
    farmName: { type: String, required: true, trim: true },
    reportType: {
      type: String,
      enum: ['proposal', 'technical', 'financial', 'environmental'],
      default: 'proposal',
    },
    fileSize: { type: String, default: '2.4 MB' },
    fileUrl: { type: String, required: true },
    filePath: { type: String, required: true },
    status: {
      type: String,
      enum: ['generating', 'completed', 'failed'],
      default: 'completed',
    },
    downloadCount: { type: Number, default: 0 },
  },
  {
    timestamps: true,
  }
);

ReportSchema.index({ userId: 1, createdAt: -1 });

export const Report = mongoose.model<IReport>('Report', ReportSchema);
