import { BitGoAPI } from "@bitgo/sdk-api";
import { Hteth } from "@bitgo/sdk-coin-eth";
import {config} from "../config/bitgoConfig"
import { CustodyArchitectureService } from "./custodialWalletService";
import path from "path";

interface TransactionRecipient {
  address: string;
  amount: number; // base units (lamports for SOL)
}

const CUSTODY_FILE = path.join(__dirname, 'custodial_wallet.txt');
const STANDBY_FILE = path.join(__dirname, 'standby_wallet.txt');
const DEPOSIT_FILE = path.join(__dirname, 'deposit_wallet.txt');

export class BitGoTransactionService {
  private bitgo: BitGoAPI;
  private coin;
  private custodyService: CustodyArchitectureService;

  constructor() {
    this.bitgo = new BitGoAPI({
          accessToken: config.accessToken,
          env: config.env === 'prod' ? 'prod' : 'test',
        });
    this.bitgo.register('hteth', Hteth.createInstance);
    this.coin = this.bitgo.coin(config.coin);
    this.custodyService = new CustodyArchitectureService();
  }

  /* ======================================================
     1️⃣ Create Transaction (Creates Pending Approval)
  ====================================================== */

  public async initiateTransaction(recipients: TransactionRecipient[]) {
    const walletId = this.custodyService.readFromFile(CUSTODY_FILE);
    console.log(`[INFO] Initiating transaction from Custody Wallet (ID: ${walletId}) to recipients:`);
    const wallet = await this.coin.wallets().get({ id: walletId as string });
    const balance = wallet.balance();
    const spendableBalance = wallet.spendableBalance();
    const confirmedBalance = wallet.confirmedBalance();
    console.log(`[INFO] Current Custody Wallet Balance: ${balance} base units`);
    console.log(`[INFO] Current Custody Wallet Spendable Balance: ${spendableBalance} base units`);
    console.log(`[INFO] Current Custody Wallet Confirmed Balance: ${confirmedBalance} base units`);

    console.log("📦 Prebuilding transaction...");

    let params = {
        recipients: recipients
    }

    console.log("📨 Submitting transaction request...");

    const tx = await wallet.prebuildTransaction(params);
    console.dir(tx)

    console.log("✅ Transaction Submitted");
    console.log("Transaction ID:", tx.reqId);

    return tx;
  }

  public async sendFromStandbyToDepositWithdraw(recepients : TransactionRecipient[]) {
    this.bitgo.unlock({ otp: "0000000", duration: 3600 }); // Replace with actual OTP method if needed
    const standbyWallet = await this.coin.wallets().get({ 
      id: '69b4079a24ec6b07205df18dfc9d0214' 
    });
    console.log(standbyWallet.receiveAddress())

    const allowedAddresses = await Promise.all(
      recepients.map(async (r) => {
        const wallet = await this.coin.wallets().getWalletByAddress({
          address: r.address,
        });

        return {
          address: r.address,
          label: wallet.label(),
        };
      })
    );

    this.custodyService.createWhitelistPolicy(standbyWallet.id(), "Deposit/Withdraw Wallet", allowedAddresses);
    // Get the deposit/withdraw wallet's receive address
    // const depositWithdrawWallet = await this.coin.wallets().get({ 
    //   id: '69b407ae55eeb6dce2aa8890d0ca09d0'
    // });

    console.log(standbyWallet.balanceString())

    // Send transaction from standby wallet to deposit/withdraw wallet
    const tx = await standbyWallet.sendMany(
      {
        recipients : recepients,
        walletPassphrase: "standby-wallet-passphrase", // Replace with actual passphrase
        txFormat: 'psbt',
        type: 'transfer',
      }
    );

    console.log('Transaction sent!');
    console.log('Transaction ID:', tx.txid);
    console.log('Transfer details:', tx.transfer);
  }

  public async getBalanceByAddress(address : string) {
    try {
      const wallet = await this.coin.wallets().getWalletByAddress({ 
        address: address 
      });

      console.log('Address:', address);
      console.log('Wallet ID:', wallet.id());
      console.log('Wallet Label:', wallet.label());
      console.log('Balance (wei):', wallet.balanceString());
      console.log('Confirmed Balance (wei):', wallet.confirmedBalanceString());
      console.log('Spendable Balance (wei):', wallet.spendableBalanceString());
      
      // Convert wei to ETH for readability
      const balanceInEth = Number(wallet.balanceString()) / 1e18;
      console.log('Balance (ETH):', balanceInEth);

      // Show token balances if any
      if (wallet._wallet.tokens) {
        console.log('\nToken Balances:');
        Object.entries(wallet._wallet.tokens).forEach(([token, data]) => {
          if (data.balanceString !== '0') {
            console.log(`  ${token}: ${data.balanceString}`);
          }
        });
      }

    } catch (error : any) {
      console.error('Error:', error.message);
    }
  }


  /* ======================================================
     2️⃣ List Pending Approvals
  ====================================================== */

  public async listPendingApprovals() {
    const pending = await this.coin.pendingApprovals().list({});

    console.log("📋 Pending Approvals:");
    console.dir(pending, { depth: 4 });

    return pending;
  }

  /* ======================================================
     3️⃣ Approve Transaction (Admin Side)
  ====================================================== */

  public async approvePendingApproval(pendingApprovalId: string) {
    const pendingApproval = await this.coin
      .pendingApprovals()
      .get({ id: pendingApprovalId });

    console.log("✍️ Approving Pending Transaction...");

    const result = await pendingApproval.approve({});

    console.log("✅ Transaction Approved");
    console.dir(result, { depth: 4 });

    return result;
  }
}