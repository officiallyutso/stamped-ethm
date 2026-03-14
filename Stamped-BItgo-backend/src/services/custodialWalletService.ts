import { BitGoAPI } from '@bitgo/sdk-api';
import { Eth, Hteth } from '@bitgo/sdk-coin-eth';
import fs from 'fs';
import path from 'path';
import { config } from '../config/bitgoConfig';
import { multisigTypes } from '@bitgo/sdk-core';

const CUSTODY_FILE = path.join(__dirname, 'custodial_wallet.txt');
const STANDBY_FILE = path.join(__dirname, 'standby_wallet.txt');
const DEPOSIT_FILE = path.join(__dirname, 'deposit_wallet.txt');

export class CustodyArchitectureService {
  private bitgo: BitGoAPI;

  constructor() {
    this.bitgo = new BitGoAPI({
      accessToken: config.accessToken,
      env: config.env === 'prod' ? 'prod' : 'test',
    });

    this.bitgo.register('eth', Eth.createInstance);
    this.bitgo.register('teth', Eth.createInstance);
    this.bitgo.register('hteth', Hteth.createInstance);
  }

  /* ============================================================
     Utility Methods
  ============================================================ */

  public readFromFile(filePath: string): string | null {
    if (fs.existsSync(filePath)) {
      return fs.readFileSync(filePath, 'utf8').trim();
    }
    return null;
  }

  private saveToFile(filePath: string, walletId: string) {
    fs.writeFileSync(filePath, walletId, 'utf8');
  }

  private coin() {
    return this.bitgo.coin(config.coin);
  }

  /* ============================================================
     1️⃣ Custodial Wallet (Cold Storage)
  ============================================================ */

  public async createCustodyWallet() {
    const existing = this.readFromFile(CUSTODY_FILE);
    const coin = this.coin();

    if (existing) {
      return await coin.wallets().get({ id: existing });
    }

    const options = {
        label: 'Custody Wallet - Cold Storage',
        isCustodial: true,
        enterprise: config.enterpriseId,
        multisigType: multisigTypes.tss,
        type: "custodial"
    };

    console.log("haha")

    const wallet = await coin.wallets().add(options);

    console.log("hehe")

    console.log(wallet);

    console.log(`[INFO] Created Custodial Wallet with ID: ${wallet.wallet}`);

    this.saveToFile(CUSTODY_FILE, wallet.id);
    return wallet;
  }

  /* ============================================================
     2️⃣ Standby Wallet (Hot TSS)
  ============================================================ */

  public async createStandbyWallet() {
    const existing = this.readFromFile(STANDBY_FILE);
    const coin = this.coin();

    if (existing) {
      return await coin.wallets().get({ id: existing });
    }

    const wallet = await coin.wallets().generateWallet({
      label: 'Standby Wallet - Hot',
      passphrase: "standby-wallet-passphrase",
      enterprise: config.enterpriseId,
      multisigType: multisigTypes.tss,
      walletVersion: 5,
      type: 'hot',
    });

    this.saveToFile(STANDBY_FILE, wallet.wallet.id());
    return wallet.wallet;
  }

  /* ============================================================
     3️⃣ Deposit/Withdraw Wallet
  ============================================================ */

  public async createDepositWithdrawWallet() {
    const existing = this.readFromFile(DEPOSIT_FILE);
    const coin = this.coin();

    if (existing) {
      return await coin.wallets().get({ id: existing });
    }

    const wallet = await coin.wallets().generateWallet({
      label: 'Deposit-Withdraw Wallet - Operations',
      passphrase: "deposit-withdraw-passphrase",
      enterprise: config.enterpriseId,
      multisigType: 'tss',
      walletVersion: 5,
      type: 'hot',
    });

    this.saveToFile(DEPOSIT_FILE, wallet.wallet.id());
    return wallet.wallet;
  }

  /* ============================================================
     4️⃣ Whitelist Policy
  ============================================================ */

  public async createWhitelistPolicy(
    walletId: string,
    walletLabel: string,
    allowedAddresses: { address: string; label: string }[]
    ) {
    const wallet = await this.coin().wallets().get({ id: walletId });

    console.log(`[INFO] Creating whitelist policy for ${walletLabel}`);

    const createdPolicies = [];

    for (const entry of allowedAddresses) {
        const policy = await wallet.setPolicyRule({
        id: "standby-wallet-whitelist-custody-wallet",
        type: 'advancedWhitelist',
        action: {
            type: 'deny',
        },
        condition: {
            add: {
            item: entry.address,
            type: 'address',
            metaData: {
                label: entry.label,
            },
            },
        },
        });

        console.log(
        `[INFO] Whitelisted ${entry.label} (${entry.address}) for ${walletLabel}`
        );

        console.log(policy);

        createdPolicies.push(policy);
    }

        return createdPolicies;
    }
  /* ============================================================
     5️⃣ Velocity Limit Policy
  ============================================================ */

  public async createVelocityLimitPolicy(
    walletId: string,
    walletLabel: string,
    limitAmount: string,
    timeWindowSeconds: number
  ) {
    const wallet = await this.coin().wallets().get({ id: walletId });

    console.log(`[INFO] Creating velocity limit policy for ${walletLabel} with limit ${limitAmount} every ${timeWindowSeconds} seconds`);

    const policy = await wallet.createPolicyRule({
      id: `${walletLabel.replace(/\s+/g, '-').toLowerCase()}-velocity-limit`,
      type: 'velocityLimit',
      condition: {
        amount: limitAmount,
        timeWindow: timeWindowSeconds,
      },
      action: {
        type: 'getApproval',
      },
    });
    console.log(`[INFO] Velocity limit policy created for ${walletLabel}:`, policy);
  }

  /* ============================================================
     6️⃣ Create Receive Addresses
  ============================================================ */

  public async createReceiveAddresses(walletId: string, count = 5) {
    const wallet = await this.coin().wallets().get({ id: walletId });
    const addresses = [];

    for (let i = 0; i < count; i++) {
      const addr = await wallet.createAddress({
        label: `Customer Address ${i + 1}`,
      });

      addresses.push(addr.address);
        console.log(`[INFO] Created receive address for ${walletId}: ${addr.address}`);
    }

    return addresses;
  }

  /* ============================================================
     7️⃣ Full Custody Architecture Builder
  ============================================================ */

  public async buildCustodyArchitecture() {
    console.log('🚀 Building BitGo Custody Architecture...\n');

    const custodyWallet = await this.createCustodyWallet();
    const standbyWallet = await this.createStandbyWallet();
    const depositWallet = await this.createDepositWithdrawWallet();

    console.log('\n✅ Wallets Created:');
    console.log('   Custody Wallet ID:', custodyWallet.id());
    console.log('   Standby Wallet ID:', standbyWallet.id());
    console.log('   Deposit/Withdraw Wallet ID:', depositWallet.id());

    console.log(standbyWallet.receiveAddress());

    // Whitelist rules
    // await this.createWhitelistPolicy(custodyWallet.id(), 'Custody Wallet', [
    //   {
    //     address: standbyWallet.receiveAddress() as string,
    //     label: 'Standby Wallet',
    //   },
    // ]);

    console.log(`[INFO] Whitelist policy created for Custody Wallet to allow transfers to Standby Wallet`);

    console.log(custodyWallet.receiveAddress());
    console.log(depositWallet.receiveAddress());

    // await this.createWhitelistPolicy(standbyWallet.id(), 'Standby Wallet', [
    //   {
    //     address: custodyWallet.receiveAddress() as string,
    //     label: 'Custody Wallet',
    //   },
    //   {
    //     address: depositWallet.receiveAddress() as string,
    //     label: 'Deposit Wallet',
    //   },
    // ]);

    // console.log(`[INFO] Whitelist policy created for Standby Wallet to allow transfers to Custody Wallet and Deposit Wallet`);

    // // Velocity Limit on Custody
    // await this.createVelocityLimitPolicy(
    //   custodyWallet.id(),
    //   'Custody Wallet',
    //   '1000000000000000000', // 1 ETH
    //   86400
    // );

    // console.log(`[INFO] Velocity limit policy created for Custody Wallet: 1 ETH per 24 hours`);

    const addresses = await this.createReceiveAddresses(depositWallet.id(), 5);

    console.log(`[INFO] Created 5 receive addresses for Deposit Wallet`);

    console.log('\n✅ Custody Architecture Built Successfully\n');

    return {
      custodyWalletId: custodyWallet.id(),
      standbyWalletId: standbyWallet.id(),
      depositWalletId: depositWallet.id(),
      depositAddresses: addresses,
    };
  }
}