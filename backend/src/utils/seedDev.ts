import mongoose from 'mongoose';
import { connectDB, disconnectDB } from '../config/db';
import { AuthService } from '../services/auth.service';
import { FarmService } from '../services/farm.service';

const runSeed = async () => {
  console.log('[Seed] Seeding development demo account and sample farms...');
  await connectDB();

  try {
    // 1. Create default demo user
    let user;
    try {
      const reg = await AuthService.register({
        firstName: 'Shivam',
        lastName: 'Kumar',
        email: 'shivam@example.com',
        password: 'Password123!',
        phone: '+91 98765 43210',
      });
      user = reg.user;
      console.log('[Seed] Created user shivam@example.com');
    } catch (e: any) {
      if (e.code === 'EMAIL_ALREADY_EXISTS') {
        const { User } = await import('../models/user.model');
        const existing = await User.findOne({ email: 'shivam@example.com' });
        user = AuthService.formatUser(existing!);
        console.log('[Seed] Demo user already exists.');
      } else {
        throw e;
      }
    }

    // 2. Create sample farms if user has none
    const existingFarms = await FarmService.getFarms(user.id);
    if (existingFarms.length === 0) {
      await FarmService.createFarm(user.id, {
        name: 'Farm A',
        areaAcres: 2.35,
        cropType: 'Wheat',
        locationName: 'Phulpur, Prayagraj',
        state: 'Uttar Pradesh, India',
        soilType: 'Loamy',
        slope: '1.8% (Almost flat)',
        irrigation: 'Available',
        gridProximityKm: 2.4,
        latitude: 25.5484,
        longitude: 82.0833,
      });

      await FarmService.createFarm(user.id, {
        name: 'Farm B',
        areaAcres: 1.8,
        cropType: 'Rice',
        locationName: 'Jhunsi, Prayagraj',
        state: 'Uttar Pradesh, India',
        soilType: 'Alluvial',
        slope: '2.1%',
        irrigation: 'Available',
        gridProximityKm: 4.1,
        latitude: 25.4384,
        longitude: 81.8953,
      });

      console.log('[Seed] Created initial farms for shivam@example.com');
    }

    console.log('[Seed] Completed successfully.');
  } catch (error) {
    console.error('[Seed] Error during seeding:', error);
  } finally {
    await disconnectDB();
  }
};

runSeed();
