import mongoose from 'mongoose';
import { SupportTicket, FaqItem, ISupportTicket, IFaqItem } from '../models/support.model';

export class SupportService {
  public static async getFaqs(category?: string, search?: string): Promise<IFaqItem[]> {
    const filter: any = {};
    if (category && category !== 'All') {
      filter.category = category;
    }
    if (search && search.trim()) {
      filter.$or = [
        { question: { $regex: search.trim(), $options: 'i' } },
        { answer: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    let faqs = await FaqItem.find(filter).sort({ order: 1 });
    if (faqs.length === 0 && (!category || category === 'All') && !search) {
      faqs = await this.seedDefaultFaqs();
    }
    return faqs;
  }

  public static async createTicket(userId: string, data: { subject: string; message: string; category?: string }): Promise<ISupportTicket> {
    const ticket = new SupportTicket({
      userId: new mongoose.Types.ObjectId(userId),
      subject: data.subject,
      message: data.message,
      category: data.category || 'General',
      status: 'open',
    });
    await ticket.save();
    return ticket;
  }

  public static async getTickets(userId: string): Promise<ISupportTicket[]> {
    return SupportTicket.find({ userId: new mongoose.Types.ObjectId(userId) }).sort({ createdAt: -1 });
  }

  private static async seedDefaultFaqs(): Promise<IFaqItem[]> {
    const defaults = [
      {
        category: 'Getting Started',
        question: 'How do I add a new farm?',
        answer: 'Navigate to "Add Farm" from the home screen, specify your location on the map, draw boundary pins, and enter basic soil and crop details.',
        order: 1,
      },
      {
        category: 'Getting Started',
        question: 'How to draw farm boundary on the map?',
        answer: 'Tap the boundary pins on the satellite map view to outline your exact plot. The acreage updates automatically.',
        order: 2,
      },
      {
        category: 'Getting Started',
        question: 'What crop types are supported?',
        answer: 'Agri-PV Navigator models C3 and C4 crops including Wheat, Rice (Paddy), Mustard, Horticulture Vegetables, and Potatoes.',
        order: 3,
      },
      {
        category: 'Using the App',
        question: 'How to set solar panel tilt angle?',
        answer: 'In the Agri-PV System Design screen, use the Tilt Angle slider (0° to 45°). 18°-22° is optimal for Northern India.',
        order: 4,
      },
      {
        category: 'Using the App',
        question: 'How do I configure row spacing?',
        answer: 'Adjust the Row Spacing slider between 3m and 12m. 6m provides optimal sunlight for wheat and machinery clearance.',
        order: 5,
      },
      {
        category: 'Technical Support',
        question: '3D view is not rendering correctly',
        answer: 'Ensure your device supports hardware graphics acceleration. You can reset camera view using the Reset button at top right.',
        order: 6,
      },
      {
        category: 'FAQs',
        question: 'Are there government subsidies for Agri-PV?',
        answer: 'Yes, schemes like PM-KUSUM provide capital subsidies and feed-in tariffs for solar farm installations.',
        order: 7,
      },
    ];

    await FaqItem.insertMany(defaults);
    return FaqItem.find().sort({ order: 1 });
  }
}
