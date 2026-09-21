import { Router } from 'express';
import { SupportController } from '../controllers/support.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// FAQs are publicly accessible
router.get('/faqs', SupportController.getFaqs);

router.use(authenticate);

router.post('/tickets', SupportController.createTicket);
router.get('/tickets', SupportController.getTickets);

export default router;
