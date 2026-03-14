import express from 'express';
import bodyParser from 'body-parser';
import { config } from './config/bitgoConfig';
import signRoutes from './routes/signRoutes';
import walletRoutes from './routes/walletRoutes';
import fileverseRoutes from './routes/fileverseRoutes';
import { CustodyArchitectureService } from './services/custodialWalletService';
import { BitGoTransactionService } from './services/bitgoTransactionService';

const app = express();

// Increased limit to 50mb for Fileverse document content
app.use(bodyParser.json({ limit: '50mb' }));

// Register routes
app.use('/api', signRoutes);
app.use('/api', walletRoutes);
app.use('/api/fileverse', fileverseRoutes);

const custodyService = new CustodyArchitectureService();
const transactionService = new BitGoTransactionService();
app.get('/setup', async (req, res) => {
  try {
    const result = await custodyService.buildCustodyArchitecture();
    console.log(`[INFO] Custody architecture built successfully:`, result);
    console.log(`[INFO] Please check the console output for wallet details and policies.`);
    res.json(result);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

const txRecipients = [
  {
    address: '0x863dc71af42709b4032324c56ec466be6bfb51b9',
    amount: 1000000000000000, 
  },
  {
    address: '0xd78a32cd4ebf7516f231571400f433e88703f8fb',
    amount: 5000000000000000, // 0.5 ETH in base units
  },
];

app.post('/initiate-transaction', async (req, res) => {
  try {
    await transactionService.getBalanceByAddress("0xe812fd10093d1f1c0d11b7f41bb71af4d60989dd")
    // const tx = await transactionService.sendFromStandbyToDepositWithdraw(txRecipients);
    res.json({ message: 'Transaction initiated successfully', /* transactionId: tx.reqId */ });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/pending-approvals', async (req, res) => {
  try {
    const approvals = await transactionService.listPendingApprovals();
    res.json(approvals);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(config.port, () => {
  console.log(`BitGo MPC Signing Backend Service running on port ${config.port}`);
});
