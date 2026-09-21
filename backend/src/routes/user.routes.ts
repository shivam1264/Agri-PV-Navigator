import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { updateUserProfileSchema, updatePreferencesSchema } from '../validators/user.validator';

const router = Router();

router.use(authenticate);

router.get('/me', UserController.getProfile);
router.patch('/me', validate(updateUserProfileSchema), UserController.updateProfile);
router.patch('/me/preferences', validate(updatePreferencesSchema), UserController.updatePreferences);

export default router;
