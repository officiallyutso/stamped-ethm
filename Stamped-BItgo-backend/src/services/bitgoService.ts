import { BitGoAPI } from '@bitgo/sdk-api';
import { Eth, Hteth } from '@bitgo/sdk-coin-eth';
import { config } from '../config/bitgoConfig';
import fs from 'fs';
import path from 'path';
import { MessageStandardType } from '@bitgo/sdk-core';

const WALLET_FILE_PATH = path.join(__dirname, 'wallet.txt');
const CUSTODIAL_WALLET_FILE_PATH = path.join(__dirname, 'custodial_wallet.txt');

const bitgo = new BitGoAPI({
  accessToken: config.accessToken,
  env: config.env === 'prod' ? 'prod' : 'test',
});

bitgo.register('eth', Eth.createInstance);
bitgo.register('teth', Eth.createInstance);
bitgo.register('hteth', Hteth.createInstance);

export class BitGoService {
  
  /**
   * Read wallet ID from file if exists
   */
  private readWalletIdFromFile(): string | null {
    try {
      if (fs.existsSync(WALLET_FILE_PATH)) {
        const walletId = fs.readFileSync(WALLET_FILE_PATH, 'utf8').trim();
        if (walletId) {
          console.log(`[INFO] Wallet ID found in wallet.txt`);
          return walletId;
        }
      }
      return null;
    } catch (err) {
      console.error(`[ERROR] Failed to read wallet file`, err);
      return null;
    }
  }
  /**
 * Read Custodial Wallet ID from file if exists
 */
private readCustodialWalletIdFromFile(): string | null {
  try {
    if (fs.existsSync(CUSTODIAL_WALLET_FILE_PATH)) {
      const walletId = fs.readFileSync(CUSTODIAL_WALLET_FILE_PATH, 'utf8').trim();
      if (walletId) {
        console.log(`[INFO] Custodial Wallet ID found in custodial_wallet.txt`);
        return walletId;
      }
    }
    return null;
  } catch (err) {
    console.error(`[ERROR] Failed to read custodial wallet file`, err);
    return null;
  }
}

/**
 * Save Custodial Wallet ID to file
 */
private saveCustodialWalletIdToFile(walletId: string) {
  try {
    fs.writeFileSync(CUSTODIAL_WALLET_FILE_PATH, walletId, 'utf8');
    console.log(`[INFO] Custodial Wallet ID saved to custodial_wallet.txt`);
  } catch (err) {
    console.error(`[ERROR] Failed to write custodial wallet file`, err);
  }
}

  /**
   * Save wallet ID to file
   */
  private saveWalletIdToFile(walletId: string) {
    try {
      fs.writeFileSync(WALLET_FILE_PATH, walletId, 'utf8');
      console.log(`[INFO] Wallet ID saved to wallet.txt`);
    } catch (err) {
      console.error(`[ERROR] Failed to write wallet file`, err);
    }
  }

  /**
 * Create or Get Custodial Wallet (Cold Storage)
 */
public async createCustodyWallet() {
  console.log('\n=== Creating Custody Wallet (Cold Storage) ===');

  try {
    const coin = bitgo.coin(config.coin);

    // Step 1: Check if custodial wallet already exists
    const savedWalletId = this.readCustodialWalletIdFromFile();

    if (savedWalletId) {
      try {
        console.log(`[INFO] Loading Custodial Wallet using ID: ${savedWalletId}`);
        return await coin.wallets().get({ id: savedWalletId });
      } catch (err) {
        console.log(`[WARN] Custodial Wallet ID invalid. Creating new one...`);
      }
    }

    // Step 2: Create Custodial Wallet
    const custodyWallet = await coin.wallets().add({
      label: 'Custody Wallet - Cold Storage',
      enterprise: config.enterpriseId,
      isCustodial: true,
      type: 'custodial',
    });

    console.log('✅ Custody Wallet Created:');
    console.log('   Wallet ID:', custodyWallet.id());
    console.log('   Label:', custodyWallet.label());
    console.log('   Type:', custodyWallet._wallet.type);
    console.log('   Receive Address:', custodyWallet.receiveAddress());

    // Step 3: Save wallet ID to file
    this.saveCustodialWalletIdToFile(custodyWallet.id());

    return custodyWallet;

  } catch (error: any) {
    console.error('❌ Error creating custody wallet:', error.message);
    throw error;
  }
}

  /**
   * Get existing wallet or create new one
   */
  public async getOrCreateWallet() {
    const coin = bitgo.coin(config.coin);

    // Step 1: Check wallet.txt
    const savedWalletId = this.readWalletIdFromFile();

    if (savedWalletId) {
      try {
        console.log(`[INFO] Loading wallet from BitGo using ID: ${savedWalletId}`);
        return await coin.wallets().get({ id: savedWalletId });
      } catch (err) {
        console.log(`[WARN] Wallet ID in file invalid. Creating new wallet...`);
      }
    }

    // Step 2: Create wallet if not found
    if (!config.enterpriseId) {
      throw new Error("Enterprise ID is required for creating ETH wallets");
    }

    console.log(`[INFO] Creating new HTETH wallet...`);

    const newWallet = await coin.wallets().generateWallet({
      label: 'My Test ETH Wallet',
      passphrase: "supersecretpassphrase",
      enterprise: config.enterpriseId,
      multisigType: 'tss',
      walletVersion: 5,
      type: "hot"
    });

    const newWalletId = newWallet.wallet.id();

    console.log(`[SUCCESS] Wallet Created`);
    console.log(`Wallet ID: ${newWalletId}`);
    console.log(`Receive Address: ${newWallet.wallet.receiveAddress()}`);

    // Save wallet ID into wallet.txt
    this.saveWalletIdToFile(newWalletId);

    // ⚠️ DO NOT log keys in production
    console.log(`User Keychain:`, newWallet.userKeychain);
    console.log(`Backup Keychain:`, newWallet.encryptedWalletPassphrase);

    return newWallet.wallet;
  }

  /**
   * Sign message using wallet
   */
  public async signCommitment(messagePayload: string): Promise<string> {
    const wallet = await this.getOrCreateWallet();

    console.log(`[DEBUG] Signing message using wallet: ${wallet.id()}`);

    const signedData = await wallet.signMessage({
      message: {
        messageRaw: messagePayload,
        messageStandardType : MessageStandardType.EIP191
      },
      walletPassphrase: "supersecretpassphrase",
    });

    console.log(`[DEBUG] Signature received`);

    return signedData.signature;
  }

  public async sendTransactionOnChain() {

  }
}