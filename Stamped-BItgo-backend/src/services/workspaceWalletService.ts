import { BitGoAPI } from '@bitgo/sdk-api';
import { Hteth } from '@bitgo/sdk-coin-eth';
import { config } from '../config/bitgoConfig';
import { db } from '../config/firebaseConfig';

interface WorkspaceWalletInfo {
  walletId: string;
  walletAddress: string;
  walletBalance: string;
  walletBalanceWei: string;
}

interface WalletBalanceInfo {
  balanceWei: string;
  balanceEth: string;
  lastSynced: Date;
}

interface PayoutResult {
  txHash: string;
  status: string;
  newBalanceEth: string;
  newBalanceWei: string;
}

interface PayoutRecord {
  id: string;
  workspaceId: string;
  userId: string;
  toAddress: string;
  amountWei: string;
  amountEth: string;
  txHash: string;
  status: string;
  createdAt: Date;
}

export class WorkspaceWalletService {
  private bitgo: BitGoAPI;
  private coin: any;

  constructor() {
    this.bitgo = new BitGoAPI({
      accessToken: config.accessToken,
      env: config.env === 'prod' ? 'prod' : 'test',
    });
    this.bitgo.register('hteth', Hteth.createInstance);
    this.coin = this.bitgo.coin(config.coin);
  }

  /* ============================================================
     1️⃣ Create Workspace Wallet
  ============================================================ */

  public async createWorkspaceWallet(
    workspaceId: string,
    workspaceName: string
  ): Promise<WorkspaceWalletInfo> {
    console.log(`[INFO] Creating wallet for workspace: ${workspaceName} (${workspaceId})`);

    // Check if workspace already has a wallet
    const workspaceDoc = await db.collection('workspaces').doc(workspaceId).get();
    if (!workspaceDoc.exists) {
      throw new Error(`Workspace ${workspaceId} not found in Firestore`);
    }

    const workspaceData = workspaceDoc.data();
    if (workspaceData?.walletId) {
      console.log(`[INFO] Workspace already has wallet: ${workspaceData.walletId}`);
      // Fetch current balance
      try {
        const wallet = await this.coin.wallets().get({ id: workspaceData.walletId });
        return {
          walletId: workspaceData.walletId,
          walletAddress: workspaceData.walletAddress || wallet.receiveAddress(),
          walletBalance: (Number(wallet.balanceString()) / 1e18).toString(),
          walletBalanceWei: wallet.balanceString(),
        };
      } catch (err) {
        console.log(`[WARN] Existing wallet ID invalid, creating new one...`);
      }
    }

    // Create new hot wallet
    if (!config.enterpriseId) {
      throw new Error('Enterprise ID is required for creating wallets');
    }

    const newWallet = await this.coin.wallets().generateWallet({
      label: `Workspace Wallet - ${workspaceName}`,
      passphrase: 'workspace-wallet-passphrase',
      enterprise: config.enterpriseId,
      multisigType: 'tss',
      walletVersion: 5,
      type: 'hot',
    });

    const wallet = newWallet.wallet;
    const walletId = wallet.id();
    const walletAddress = wallet.receiveAddress();

    console.log(`[SUCCESS] Wallet created for workspace ${workspaceId}`);
    console.log(`   Wallet ID: ${walletId}`);
    console.log(`   Address: ${walletAddress}`);

    // Store wallet info in Firestore
    await db.collection('workspaces').doc(workspaceId).update({
      walletId: walletId,
      walletAddress: walletAddress,
      walletBalance: '0',
      walletBalanceWei: '0',
      walletLastSynced: new Date(),
    });

    console.log(`[INFO] Wallet info stored in Firestore for workspace ${workspaceId}`);

    return {
      walletId,
      walletAddress,
      walletBalance: '0',
      walletBalanceWei: '0',
    };
  }

  /* ============================================================
     2️⃣ Get Wallet Balance
  ============================================================ */

  public async getWalletBalance(workspaceId: string): Promise<WalletBalanceInfo> {
    console.log(`[INFO] Fetching wallet balance for workspace: ${workspaceId}`);

    const workspaceDoc = await db.collection('workspaces').doc(workspaceId).get();
    if (!workspaceDoc.exists) {
      throw new Error(`Workspace ${workspaceId} not found`);
    }

    const workspaceData = workspaceDoc.data();
    if (!workspaceData?.walletId) {
      throw new Error(`Workspace ${workspaceId} has no wallet`);
    }

    const wallet = await this.coin.wallets().get({ id: workspaceData.walletId });
    const balanceWei = wallet.balanceString();
    const balanceEth = (Number(balanceWei) / 1e18).toString();
    const now = new Date();

    // Update Firestore with latest balance
    await db.collection('workspaces').doc(workspaceId).update({
      walletBalance: balanceEth,
      walletBalanceWei: balanceWei,
      walletLastSynced: now,
    });

    console.log(`[INFO] Wallet balance for ${workspaceId}: ${balanceEth} ETH (${balanceWei} wei)`);

    return {
      balanceWei,
      balanceEth,
      lastSynced: now,
    };
  }

  /* ============================================================
     3️⃣ Send Payout
  ============================================================ */

  public async sendPayout(
    workspaceId: string,
    userId: string,
    toAddress: string,
    amountWei: string
  ): Promise<PayoutResult> {
    console.log(`[INFO] Sending payout from workspace ${workspaceId} to ${toAddress}: ${amountWei} wei`);

    // Get workspace wallet
    const workspaceDoc = await db.collection('workspaces').doc(workspaceId).get();
    if (!workspaceDoc.exists) {
      throw new Error(`Workspace ${workspaceId} not found`);
    }

    const workspaceData = workspaceDoc.data();
    if (!workspaceData?.walletId) {
      throw new Error(`Workspace ${workspaceId} has no wallet`);
    }

    // Unlock BitGo session
    await this.bitgo.unlock({ otp: '0000000', duration: 3600 });

    // Get wallet and send
    const wallet = await this.coin.wallets().get({ id: workspaceData.walletId });

    const tx = await wallet.send({
      address: toAddress,
      amount: amountWei,
      walletPassphrase: 'workspace-wallet-passphrase',
      txFormat: 'psbt',
      type: 'transfer',
    });

    const txHash = tx.txid || tx.hash || '';
    const amountEth = (Number(amountWei) / 1e18).toString();

    console.log(`[SUCCESS] Payout sent! TX: ${txHash}`);

    // Create payout record in Firestore
    const payoutRef = db.collection('payouts').doc();
    await payoutRef.set({
      workspaceId,
      userId,
      fromWalletId: workspaceData.walletId,
      fromWalletAddress: workspaceData.walletAddress,
      toAddress,
      amountWei,
      amountEth,
      txHash,
      status: 'completed',
      createdAt: new Date(),
      completedAt: new Date(),
    });

    // Removed updating earnings since payouts are now direct without attendance-based earnings.

    // Refresh balance
    const newBalanceWei = wallet.balanceString();
    const newBalanceEth = (Number(newBalanceWei) / 1e18).toString();

    await db.collection('workspaces').doc(workspaceId).update({
      walletBalance: newBalanceEth,
      walletBalanceWei: newBalanceWei,
      walletLastSynced: new Date(),
    });

    return {
      txHash,
      status: 'completed',
      newBalanceEth,
      newBalanceWei,
    };
  }

  /* ============================================================
     4️⃣ Payout History
  ============================================================ */

  public async getPayoutHistory(workspaceId: string): Promise<PayoutRecord[]> {
    const snapshot = await db
      .collection('payouts')
      .where('workspaceId', '==', workspaceId)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate() || new Date(),
    })) as PayoutRecord[];
  }

  /* ============================================================
     5️⃣ Create User Wallet (auto-generated on workspace join)
  ============================================================ */

  public async createUserWallet(
    workspaceId: string,
    userId: string,
    displayName: string
  ): Promise<{ walletId: string; walletAddress: string }> {
    console.log(`[INFO] Creating user wallet for ${displayName} (${userId}) in workspace ${workspaceId}`);

    // Check if user already has a wallet in this workspace
    const existingQuery = await db
      .collection('workspace_members')
      .where('workspaceId', '==', workspaceId)
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (!existingQuery.empty) {
      const existing = existingQuery.docs[0].data();
      if (existing.walletId && existing.walletAddress) {
        console.log(`[INFO] User already has wallet in this workspace: ${existing.walletAddress}`);
        return {
          walletId: existing.walletId,
          walletAddress: existing.walletAddress,
        };
      }
    }

    // Create new hot wallet for the user (following createDepositWithdrawWallet pattern)
    if (!config.enterpriseId) {
      throw new Error('Enterprise ID is required for creating wallets');
    }

    const newWallet = await this.coin.wallets().generateWallet({
      label: `User Wallet - ${displayName} - ${workspaceId.substring(0, 8)}`,
      passphrase: 'user-wallet-passphrase',
      enterprise: config.enterpriseId,
      multisigType: 'tss',
      walletVersion: 5,
      type: 'hot',
    });

    const wallet = newWallet.wallet;
    const walletId = wallet.id();
    const walletAddress = wallet.receiveAddress();

    console.log(`[SUCCESS] User wallet created`);
    console.log(`   Wallet ID: ${walletId}`);
    console.log(`   Address: ${walletAddress}`);

    // Store in workspace_members collection
    if (!existingQuery.empty) {
      // Update existing membership doc
      await existingQuery.docs[0].ref.update({
        walletId,
        walletAddress,
        walletBalance: '0',
        walletBalanceWei: '0',
      });
    } else {
      // Create new membership doc
      await db.collection('workspace_members').add({
        workspaceId,
        userId,
        walletId,
        walletAddress,
        walletBalance: '0',
        walletBalanceWei: '0',
        joinedAt: new Date(),
      });
    }

    console.log(`[INFO] User wallet stored in workspace_members`);

    return { walletId, walletAddress };
  }

  /* ============================================================
     6️⃣ Get User Wallet Info
  ============================================================ */

  public async getUserWalletInfo(
    workspaceId: string,
    userId: string
  ): Promise<{ walletId: string; walletAddress: string; walletBalance: string; walletBalanceWei: string } | null> {
    const query = await db
      .collection('workspace_members')
      .where('workspaceId', '==', workspaceId)
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (query.empty || !query.docs[0].data().walletId) {
      return null;
    }

    const memberData = query.docs[0].data();

    // Refresh balance from BitGo
    try {
      const wallet = await this.coin.wallets().get({ id: memberData.walletId });
      const balanceWei = wallet.balanceString();
      const balanceEth = (Number(balanceWei) / 1e18).toString();

      // Update Firestore
      await query.docs[0].ref.update({
        walletBalance: balanceEth,
        walletBalanceWei: balanceWei,
      });

      return {
        walletId: memberData.walletId,
        walletAddress: memberData.walletAddress,
        walletBalance: balanceEth,
        walletBalanceWei: balanceWei,
      };
    } catch (err: any) {
      console.log(`[WARN] Could not refresh user wallet balance: ${err.message}`);
      return {
        walletId: memberData.walletId,
        walletAddress: memberData.walletAddress,
        walletBalance: memberData.walletBalance || '0',
        walletBalanceWei: memberData.walletBalanceWei || '0',
      };
    }
  }
}

