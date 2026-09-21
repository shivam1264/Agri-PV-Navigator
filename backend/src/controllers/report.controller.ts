import { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import { AuthRequest } from '../middleware/auth.middleware';
import { ReportService } from '../services/report.service';

export class ReportController {
  public static async generateReport(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const { farmId, designId, reportType } = req.body;
      const report = await ReportService.generateReport(
        req.user!._id.toString(),
        farmId,
        designId,
        reportType || 'proposal'
      );
      res.status(201).json({
        success: true,
        message: 'PDF proposal report generated successfully.',
        data: { report },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getReports(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const category = req.query.category as string;
      const reports = await ReportService.getReports(req.user!._id.toString(), category);
      res.status(200).json({
        success: true,
        message: 'Reports retrieved.',
        data: { reports },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getReportById(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const report = await ReportService.getReportById(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Report details retrieved.',
        data: { report },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async downloadReport(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fileName = req.params.fileName;
      const reportsDir = path.resolve(__dirname, '../../public/reports');
      const filePath = path.join(reportsDir, fileName);

      if (!fs.existsSync(filePath)) {
        res.status(404).json({
          success: false,
          message: 'Report file not found.',
          code: 'FILE_NOT_FOUND',
        });
        return;
      }

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
      const fileStream = fs.createReadStream(filePath);
      fileStream.pipe(res);
    } catch (error) {
      next(error);
    }
  }

  public static async downloadReportById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const reportId = req.params.id;
      const { Report } = await import('../models/report.model');
      const report = await Report.findById(reportId);

      if (!report || !report.filePath || !fs.existsSync(report.filePath)) {
        res.status(404).json({
          success: false,
          message: 'Report file not found.',
          code: 'FILE_NOT_FOUND',
        });
        return;
      }

      const fileName = path.basename(report.filePath);
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
      const fileStream = fs.createReadStream(report.filePath);
      fileStream.pipe(res);
    } catch (error) {
      next(error);
    }
  }

  public static async deleteReport(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      await ReportService.deleteReport(req.user!._id.toString(), req.params.id);
      res.status(200).json({
        success: true,
        message: 'Report deleted successfully.',
      });
    } catch (error) {
      next(error);
    }
  }
}
