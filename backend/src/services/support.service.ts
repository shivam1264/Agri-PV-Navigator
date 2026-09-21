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
      // Getting Started
      {
        category: 'Getting Started',
        question: 'How do I add a new farm?',
        answer: 'Tap the "+ Add Farm" button on your Home screen or open the Farm Location tab. Name your farm, choose your soil and primary crop, and drop boundary pins on the interactive map to calculate acreage.',
        order: 1,
      },
      {
        category: 'Getting Started',
        question: 'How to draw farm boundary on the map?',
        answer: 'Open the Farm Location screen and switch to Satellite View. Tap the corners of your plot in order (minimum 3 pins). Drag any pin along fence lines, and double-tap the first pin to calculate your exact acreage and solar capacity.',
        order: 2,
      },
      {
        category: 'Getting Started',
        question: 'What crop types are supported?',
        answer: 'Agri-PV Navigator models 20+ major cultivars including shade-tolerant vegetables (tomatoes, potatoes, lettuce), moderate grains (wheat, barley, mustard), and high-light cereals (rice paddy, corn). The engine runs automated DLI simulations.',
        order: 3,
      },
      // Using the App
      {
        category: 'Using the App',
        question: 'How to set solar panel tilt angle?',
        answer: 'In the Agri-PV System Design screen, adjust the Tilt Angle slider (0° to 45°). For Northern India, 18°-22° is optimal to maximize solar generation while allowing diffuse winter sunlight for rabi crops.',
        order: 4,
      },
      {
        category: 'Using the App',
        question: 'How do I configure row spacing?',
        answer: 'Adjust the Row Spacing slider between 3m and 12m. For 40-55 HP tractors, 5.5m-6.5m is recommended. For combine harvesters, choose 7.5m-9.0m to maintain clear machinery lanes and ground sunlight.',
        order: 5,
      },
      {
        category: 'Using the App',
        question: 'What is the BCI score?',
        answer: 'BCI (Bifacial Co-location Index) is our composite health score (0-100) combining crop photosynthesis light (35%), solar kWh yield (30%), water conservation (20%), and financial IRR (15%). Scores above 80 represent optimal dual-use setups.',
        order: 6,
      },
      // Technical Support
      {
        category: 'Technical Support',
        question: '3D view is not rendering correctly',
        answer: 'Tap the "Reset View" button at top right to center coordinates. Ensure your farm boundary does not cross itself, and toggle "Reduce Motion / Performance Mode" in Settings if your device has limited GPU memory.',
        order: 7,
      },
      {
        category: 'Technical Support',
        question: 'PDF report is not generating',
        answer: 'Confirm your farm design has boundary and tilt parameters configured. Allow 4-6 seconds for 8,760 hourly solar angles to simulate, and ensure device storage permission is granted to download the dossier.',
        order: 8,
      },
      {
        category: 'Technical Support',
        question: 'The app crashes on AR mode',
        answer: 'Verify your device supports Google Play Services for AR (ARCore). Ensure camera permissions are granted and the field has adequate ambient daylight. You can always use the 3D Orbit Canvas as an alternative without AR hardware.',
        order: 9,
      },
      // FAQs
      {
        category: 'FAQs',
        question: 'Are there government subsidies for Agri-PV?',
        answer: 'Yes! Under PM-KUSUM Component A and C, farmers can receive up to 60% combined Central and State financial support on solar pumps and sell surplus power via guaranteed 25-year PPAs at ₹2.90-₹3.30/kWh.',
        order: 10,
      },
      {
        category: 'FAQs',
        question: 'How much crop yield reduction to expect?',
        answer: 'For cool-season and shade-tolerant crops (wheat, potatoes, tomatoes), yields often increase 0% to +12% due to canopy heat stress reduction. High-light crops experience minimal (-3% to -8%) variation, offset by solar power income and 20-35% water savings.',
        order: 11,
      },
      {
        category: 'FAQs',
        question: 'Can I integrate with existing solar systems?',
        answer: 'Yes! You can retrofit existing DC solar pumps (PM-KUSUM Component B) with elevated trackers, integrate existing inverters with bifacial arrays, or connect daytime surplus generation to battery energy storage systems.',
        order: 12,
      },
    ];

    await FaqItem.deleteMany({});
    await FaqItem.insertMany(defaults);
    return FaqItem.find().sort({ order: 1 });
  }
}
