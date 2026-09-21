import { Router } from 'express';
import { ReportController } from '../controllers/report.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// Public download endpoint for viewing/sharing PDF file
router.get('/download/:fileName', ReportController.downloadReport);

router.use(authenticate);

router.post('/generate', ReportController.generateReport);
router.get('/', ReportController.getReports);
router.get('/:id', ReportController.getReportById);
router.delete('/:id', ReportController.deleteReport);

export default router;
