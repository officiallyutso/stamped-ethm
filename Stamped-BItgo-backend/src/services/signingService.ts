import { BitGoService } from './bitgoService';
import { SignedCommitment } from '../models/signedCommitment';

export class SigningService {
  private bitgoService: BitGoService;

  constructor() {
    this.bitgoService = new BitGoService();
  }

  public async signCommitment(
    commitmentHash: string,
    deviceWalletAddress: string,
    timestamp: number
  ): Promise<SignedCommitment> {


    // 2. call bitgoService.signCommitment()
    const signature = await this.bitgoService.signCommitment(commitmentHash);

    // 3. assemble SignedCommitment object
    return {
      commitmentHash,
      deviceWalletAddress,
      signature,
      timestamp
    };
  }
}
