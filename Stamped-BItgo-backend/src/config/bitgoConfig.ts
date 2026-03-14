import dotenv from 'dotenv';
dotenv.config();

export const config = {
  accessToken: process.env.BITGO_ACCESS_TOKEN || '',
  env: process.env.BITGO_ENV || 'test',
  walletId: process.env.BITGO_WALLET_ID || '',
  coin: process.env.BITGO_COIN || 'teth',
  port: parseInt(process.env.PORT || '4000', 10),
  enterpriseId : "69b2afd58445ab5ac1ba9738f1c8afed",
  fileverseApiKey: process.env.FILEVERSE_API_KEY || '',
  fileverseServerUrl: process.env.FILEVERSE_SERVER_URL || 'http://localhost:8001'
};
