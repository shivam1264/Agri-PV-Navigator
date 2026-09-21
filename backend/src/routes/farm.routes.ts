import { Router } from 'express';
import { FarmController } from '../controllers/farm.controller';
import { DesignController } from '../controllers/design.controller';
import { SuitabilityController } from '../controllers/suitability.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { createFarmSchema, updateFarmSchema } from '../validators/farm.validator';
import { createDesignSchema } from '../validators/design.validator';

const router = Router();

router.use(authenticate);

router.post('/', validate(createFarmSchema), FarmController.createFarm);
router.get('/', FarmController.getFarms);
router.get('/:id', FarmController.getFarmById);
router.patch('/:id', validate(updateFarmSchema), FarmController.updateFarm);
router.delete('/:id', FarmController.deleteFarm);

// Nested routes for farm designs & suitability
router.get('/:farmId/designs', DesignController.getDesignsByFarm);
router.post('/:farmId/designs', validate(createDesignSchema), DesignController.createDesign);
router.get('/:farmId/suitability', SuitabilityController.getSuitability);
router.post('/:farmId/suitability', SuitabilityController.recalculateSuitability);

export default router;
