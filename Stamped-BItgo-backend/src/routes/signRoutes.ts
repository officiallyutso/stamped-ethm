import { Router } from 'express';
import { SignController } from '../controllers/signController';

const router = Router();
const signController = new SignController();

// Create POST endpoint exactly as required
router.post('/sign-commitment', signController.signCommitment);

export default router;
