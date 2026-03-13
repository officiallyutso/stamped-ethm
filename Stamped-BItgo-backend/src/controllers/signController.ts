import { Request, Response } from 'express';
import { SigningService } from '../services/signingService';

export class SignController {
  private signingService: SigningService;

  constructor() {
    this.signingService = new SigningService();
  }

  public signCommitment = async (req: Request, res: Response): Promise<void> => {
    try {
      const { commitmentHash, deviceWalletAddress, timestamp } = req.body;

      // Validate input constraints
      if (!commitmentHash || typeof commitmentHash !== 'string' || commitmentHash.length > 256) {
        res.status(400).json({ error: 'Malformed or missing commitmentHash' });
        return;
      }

      if (!deviceWalletAddress || typeof deviceWalletAddress !== 'string') {
        res.status(400).json({ error: 'Malformed or missing deviceWalletAddress' });
        return;
      }

      if (!timestamp || typeof timestamp !== 'number') {
        res.status(400).json({ error: 'Malformed or missing timestamp' });
        return;
      }

      console.log(`[INFO] Received sign request for commitment: ${commitmentHash.substring(0, 10)}...`);

      // Execute signing workflow
      const signedCommitment = await this.signingService.signCommitment(
        commitmentHash,
        deviceWalletAddress,
        timestamp
      );

      console.log(`[SUCCESS] Successfully signed commitment: ${commitmentHash.substring(0, 10)}...`);
      res.status(200).json(signedCommitment);
      
    } catch (error: any) {
      console.error(`[ERROR] Signing failed:`, error.message);
      // Return 500 without leaking raw BitGo credentials or objects
      res.status(500).json({ error: 'Internal Server Error' });
    }
  };
}
