import { Router } from 'express';
import { VisualizationController } from '../controllers/visualization.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/sun-simulation', VisualizationController.getSunSimulation);

export default router;
