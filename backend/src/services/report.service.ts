import mongoose from 'mongoose';
import path from 'path';
import fs from 'fs';
import { Report, IReport, ReportTypeEnum } from '../models/report.model';
import { User } from '../models/user.model';
import { FarmService } from './farm.service';
import { DesignService } from './design.service';
import { SuitabilityService } from './suitability.service';
import { PdfReportGenerator } from '../reports/pdfReportGenerator';
import { Notification } from '../models/notification.model';
import { AppError } from '../middleware/error.middleware';

export class ReportService {
  public static async generateReport(
    userId: string,
    farmId: string,
    designId?: string,
    reportType: ReportTypeEnum = 'proposal'
  ): Promise<IReport> {
    const user = await User.findById(userId);
    if (!user) {
      const err: AppError = new Error('User not found.');
      err.statusCode = 404;
      throw err;
    }

    const farm = await FarmService.getFarmById(userId, farmId);

    let design = undefined;
    if (designId) {
      design = await DesignService.getDesignById(userId, designId);
    } else {
      const designs = await DesignService.getDesignsByFarm(userId, farmId);
      design = designs.find((d) => d.isDefaultOrPrimary) || designs[0];
    }

    const suitability = await SuitabilityService.getByFarm(userId, farmId);

    const timestamp = Date.now();
    const fileName = `Agri-PV_${reportType}_${farm.name.replace(/[^a-zA-Z0-9]/g, '_')}_${timestamp}.pdf`;
    const reportsDir = path.resolve(__dirname, '../../public/reports');
    const outputPath = path.join(reportsDir, fileName);

    const { filePath, fileSizeStr } = await PdfReportGenerator.generate({
      user,
      farm,
      design,
      suitability,
      reportType,
      outputPath,
    });

    let title = `${farm.name} Agri-PV Comprehensive Feasibility & Proposal`;
    if (reportType === 'technical') title = `${farm.name} Technical & Structural Specifications`;
    else if (reportType === 'financial') title = `${farm.name} 25-Year Techno-Economic Analysis`;
    else if (reportType === 'environmental') title = `${farm.name} Environmental & Crop Yield Impact`;

    // Only 1 report per farm: check if existing report exists for this farm
    let report = await Report.findOne({
      userId: new mongoose.Types.ObjectId(userId),
      farmId: farm._id,
    });

    if (report) {
      report.designId = design?._id;
      report.title = title;
      report.farmName = farm.name;
      report.reportType = reportType;
      report.fileSize = fileSizeStr;
      report.fileUrl = `/api/reports/download/${fileName}`;
      report.filePath = filePath;
      report.status = 'completed';
      await report.save();
    } else {
      report = new Report({
        userId: new mongoose.Types.ObjectId(userId),
        farmId: farm._id,
        designId: design?._id,
        title,
        farmName: farm.name,
        reportType,
        fileSize: fileSizeStr,
        fileUrl: `/api/reports/download/${fileName}`,
        filePath,
        status: 'completed',
      });
      await report.save();
    }

    // Trigger user notification
    const notification = new Notification({
      userId: user._id,
      title: 'Report Ready',
      message: `Your ${reportType} report for ${farm.name} is ready for download.`,
      type: 'success',
    });
    await notification.save();

    return report;
  }

  public static async getReports(userId: string, category?: string): Promise<IReport[]> {
    const filter: any = { userId: new mongoose.Types.ObjectId(userId) };

    if (category && category !== 'All') {
      const catLower = category.toLowerCase();
      if (catLower === 'designs') filter.reportType = 'technical';
      else if (catLower === 'financial') filter.reportType = 'financial';
      else if (catLower === 'impact') filter.reportType = 'environmental';
      else filter.reportType = catLower;
    }

    return Report.find(filter).sort({ createdAt: -1 });
  }

  public static async getReportById(userId: string, reportId: string): Promise<IReport> {
    if (!mongoose.Types.ObjectId.isValid(reportId)) {
      const err: AppError = new Error('Invalid report identifier.');
      err.statusCode = 400;
      throw err;
    }

    const report = await Report.findOne({
      _id: reportId,
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!report) {
      const err: AppError = new Error('Report not found or unauthorized.');
      err.statusCode = 404;
      throw err;
    }

    return report;
  }

  public static async deleteReport(userId: string, reportId: string): Promise<void> {
    const report = await this.getReportById(userId, reportId);
    if (fs.existsSync(report.filePath)) {
      try {
        fs.unlinkSync(report.filePath);
      } catch (e) {
        console.error('Failed to delete physical report file:', e);
      }
    }
    await Report.deleteOne({ _id: report._id });
  }
}
