import { Router } from 'express';
import { FileverseController } from '../controllers/fileverseController';

const router = Router();
const fileverseController = new FileverseController();

// Create POST endpoint for Fileverse doc creation
router.post('/createFileverseDoc', fileverseController.createFileverseDoc);

// PUT endpoint for updating an existing Fileverse doc
router.put('/updateFileverseDoc/:docId', fileverseController.updateFileverseDoc);

// GET endpoint to poll for document status
router.get('/status/:docId', fileverseController.getFileverseDocStatus);

export default router;
