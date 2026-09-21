import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import farmRoutes from './farm.routes';
import designRoutes from './design.routes';
import visualizationRoutes from './visualization.routes';
import reportRoutes from './report.routes';
import dashboardRoutes from './dashboard.routes';
import notificationRoutes from './notification.routes';
import supportRoutes from './support.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/farms', farmRoutes);
router.use('/designs', designRoutes);
router.use('/visualization', visualizationRoutes);
router.use('/reports', reportRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/notifications', notificationRoutes);
router.use('/support', supportRoutes);

export default router;
