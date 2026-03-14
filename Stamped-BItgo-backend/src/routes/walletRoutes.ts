import { Router, Request, Response } from 'express';
import { WorkspaceWalletService } from '../services/workspaceWalletService';
import { EarningsService } from '../services/earningsService';

const router = Router();
const walletService = new WorkspaceWalletService();
const earningsService = new EarningsService();

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

export default router;

