import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '5555', 10),
  fileverseApiKey: process.env.FILEVERSE_API_KEY || '',
  fileverseServerUrl: process.env.FILEVERSE_SERVER_URL || 'https://fileverse-cloudflare-worker.utsosarkar1.workers.dev'
};
