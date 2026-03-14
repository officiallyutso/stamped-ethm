import { Router } from 'express';
import { FileverseController } from '../controllers/fileverseController';

const router = Router();
const fileverseController = new FileverseController();

// Create POST endpoint for Fileverse doc creation
router.post('/createFileverseDoc', fileverseController.createFileverseDoc);

// GET endpoint to poll for document status
router.get('/status/:docId', fileverseController.getFileverseDocStatus);

export default router;
