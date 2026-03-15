import { Router, Request, Response } from 'express';
import { WorkspaceWalletService } from '../services/workspaceWalletService';
import { EarningsService } from '../services/earningsService';
import { BitGoTransactionService } from '../services/bitgoTransactionService';

const router = Router();
const walletService = new WorkspaceWalletService();
const earningsService = new EarningsService();
const transactionService = new BitGoTransactionService();

/* ============================================================
   Workspace Wallet Endpoints
============================================================ */

// POST /api/workspace/create-wallet
router.post('/workspace/create-wallet', async (req: Request, res: Response) => {
  try {
    const { workspaceId, workspaceName } = req.body;

    if (!workspaceId || !workspaceName) {
      res.status(400).json({ error: 'workspaceId and workspaceName are required' });
      return;
    }

    const result = await walletService.createWorkspaceWallet(workspaceId, workspaceName);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Create wallet:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/workspace/wallet-balance?workspaceId=xxx
router.get('/workspace/wallet-balance', async (req: Request, res: Response) => {
  try {
    const workspaceId = req.query.workspaceId as string;

    if (!workspaceId) {
      res.status(400).json({ error: 'workspaceId query parameter is required' });
      return;
    }

    const result = await walletService.getWalletBalance(workspaceId);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Get balance:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/workspace/send-payout
router.post('/workspace/send-payout', async (req: Request, res: Response) => {
  try {
    const { workspaceId, userId, toAddress, amountWei } = req.body;

    if (!workspaceId || !userId || !toAddress || !amountWei) {
      res.status(400).json({ error: 'workspaceId, userId, toAddress, and amountWei are required' });
      return;
    }

    const result = await walletService.sendPayout(workspaceId, userId, toAddress, amountWei);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Send payout:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/workspace/payout-history?workspaceId=xxx
router.get('/workspace/payout-history', async (req: Request, res: Response) => {
  try {
    const workspaceId = req.query.workspaceId as string;

    if (!workspaceId) {
      res.status(400).json({ error: 'workspaceId query parameter is required' });
      return;
    }

    const result = await walletService.getPayoutHistory(workspaceId);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Payout history:', err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ============================================================
   Earnings Endpoints
============================================================ */

// GET /api/workspace/earnings?workspaceId=xxx
router.get('/workspace/earnings', async (req: Request, res: Response) => {
  try {
    const workspaceId = req.query.workspaceId as string;

    if (!workspaceId) {
      res.status(400).json({ error: 'workspaceId query parameter is required' });
      return;
    }

    const result = await earningsService.getPendingEarnings(workspaceId);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Get earnings:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/workspace/calculate-earnings
router.post('/workspace/calculate-earnings', async (req: Request, res: Response) => {
  try {
    const { workspaceId, userId, startDate, endDate } = req.body;

    if (!workspaceId || !userId || !startDate || !endDate) {
      res.status(400).json({ error: 'workspaceId, userId, startDate, and endDate are required' });
      return;
    }

    const result = await earningsService.calculateEarnings(workspaceId, userId, startDate, endDate);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Calculate earnings:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/workspace/user-earnings?workspaceId=xxx&userId=yyy
router.get('/workspace/user-earnings', async (req: Request, res: Response) => {
  try {
    const workspaceId = req.query.workspaceId as string;
    const userId = req.query.userId as string;

    if (!workspaceId || !userId) {
      res.status(400).json({ error: 'workspaceId and userId query parameters are required' });
      return;
    }

    const result = await earningsService.getUserEarnings(workspaceId, userId);
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] User earnings:', err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ============================================================
   User Wallet Endpoints
============================================================ */

// POST /api/workspace/create-user-wallet
router.post('/workspace/create-user-wallet', async (req: Request, res: Response) => {
  try {
    const { workspaceId, userId, displayName } = req.body;

    if (!workspaceId || !userId) {
      res.status(400).json({ error: 'workspaceId and userId are required' });
      return;
    }

    const result = await walletService.createUserWallet(workspaceId, userId, displayName || 'User');
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Create user wallet:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/workspace/user-wallet?workspaceId=xxx&userId=yyy
router.get('/workspace/user-wallet', async (req: Request, res: Response) => {
  try {
    const workspaceId = req.query.workspaceId as string;
    const userId = req.query.userId as string;

    if (!workspaceId || !userId) {
      res.status(400).json({ error: 'workspaceId and userId query parameters are required' });
      return;
    }

    const result = await walletService.getUserWalletInfo(workspaceId, userId);
    if (!result) {
      res.status(404).json({ error: 'User wallet not found in this workspace' });
      return;
    }
    res.json(result);
  } catch (err: any) {
    console.error('[ERROR] Get user wallet:', err.message);
    res.status(500).json({ error: err.message });
  }
});

/* ============================================================
   Proof Generation / On-Chain Hashes
============================================================ */

// POST /api/workspace/send-hash
router.post('/workspace/send-hash', async (req: Request, res: Response) => {
  try {
    const { hashes, workspaceId, userAddress } = req.body;

    if (!hashes || !Array.isArray(hashes) || hashes.length === 0) {
      res.status(400).json({ error: 'hashes array is required in the request body' });
      return;
    }
    if (!workspaceId || !userAddress) {
      res.status(400).json({ error: 'workspaceId and userAddress are required in the request body' });
      return;
    }

    // Since we'll send to the workspace's standby wallet (from the snippet logic),
    // wait, the snippet says to use the workspace standby address. BUT wait, Stamped workspaces
    // don't have "standby addresses", they use a BitGo wallet. The provided code
    // says to get the wallet receiver address from workspace ID.
    
    // Instead of completely reconstructing the standby wallet architecture here:
    // the snippet provided says:
    // send hash in the array then create a recepients for transaction using the workspace standby address and minimal amount and data as "0x" + hash

    // Let's get the workspace's wallet address to act as the "standby"
    const workspaceWallet = await walletService.getWalletBalance(workspaceId);
    // Well, `getWalletBalance` actually just needs the workspaceId, but let's just get the address directly from Firestore or API.
    // Wait, the prompt provided a *fixed* array with a hardcoded address `0x863dc...` as recipient in the snippet.
    // But they mentioned: "get the wallet receiver address from workspace as we have the wallet id of that workspace which we need to get the wallet"

    const workspaceDoc = await require('../config/firebaseConfig').db.collection('workspaces').doc(workspaceId).get();
    if (!workspaceDoc.exists) throw new Error("Workspace not found");
    const workspaceData = workspaceDoc.data();
    if (!workspaceData?.walletAddress) throw new Error("Workspace does not have a wallet");
    
    const standbyAddress = workspaceData.walletAddress;

    // Create recipients array
    const recipients = hashes.map((hash: string) => {
      // Ensure the data is a valid hex string (even length, 0x prefixed)
      let hexData = hash;
      
      // If the string isn't already a strictly valid hex string with 0x prefix, encode it
      if (!hexData.startsWith('0x') || !/^(0x)?[0-9a-fA-F]*$/.test(hexData)) {
        // Convert the string to a utf-8 buffer, then to hex
        const buffer = Buffer.from(hash, 'utf-8');
        hexData = '0x' + buffer.toString('hex');
      } else {
         // Ensure it has 0x
         if (!hexData.startsWith('0x')) {
           hexData = '0x' + hexData;
         }
         // Ensure even length for BitGo parser
         if (hexData.length % 2 !== 0) {
            hexData = hexData.replace('0x', '0x0');
         }
      }

      return {
        address: standbyAddress,
        amount: 1000000, // minimal amount
        data: hexData
      };
    });

    // Send the hash
    const tx = await transactionService.sendHashToWallet(recipients, userAddress);

    res.json({ message: "Hash sent to wallet successfully", txId: tx.txid || tx.hash });
  } catch (err: any) {
    console.error('[ERROR] Send hash:', err.message);
    res.status(500).json({ error: err.message });
  }
});

export default router;

