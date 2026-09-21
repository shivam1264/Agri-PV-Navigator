import { Router } from 'express';
import { DesignController } from '../controllers/design.controller';
import { VisualizationController } from '../controllers/visualization.controller';
import { EconomicsController } from '../controllers/economics.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { updateDesignSchema } from '../validators/design.validator';

const router = Router();

router.use(authenticate);

router.get('/:id', DesignController.getDesignById);
router.patch('/:id', validate(updateDesignSchema), DesignController.updateDesign);
router.delete('/:id', DesignController.deleteDesign);

router.get('/:id/visualization-config', VisualizationController.getVisualizationConfig);
router.get('/:id/economics', EconomicsController.getEconomics);

export default router;
