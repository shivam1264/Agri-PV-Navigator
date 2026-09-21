import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { SupportService } from '../services/support.service';

export class SupportController {
  public static async getFaqs(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const category = req.query.category as string;
      const search = req.query.search as string;
      const faqs = await SupportService.getFaqs(category, search);
      res.status(200).json({
        success: true,
        message: 'FAQs retrieved.',
        data: { faqs },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async createTicket(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const ticket = await SupportService.createTicket(req.user!._id.toString(), req.body);
      res.status(201).json({
        success: true,
        message: 'Support ticket submitted successfully.',
        data: { ticket },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getTickets(req: AuthRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const tickets = await SupportService.getTickets(req.user!._id.toString());
      res.status(200).json({
        success: true,
        message: 'Support tickets retrieved.',
        data: { tickets },
      });
    } catch (error) {
      next(error);
    }
  }
}
