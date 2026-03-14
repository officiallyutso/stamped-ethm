import express from 'express';
import bodyParser from 'body-parser';
import { config } from './config/fileverseConfig';
import fileverseRoutes from './routes/fileverseRoutes';

const app = express();

// Limit message size to handle Base64 images (expanded to 50MB)
app.use(bodyParser.json({ limit: '50mb' }));

// Register routes
app.use('/api/fileverse', fileverseRoutes);

// Start server
app.listen(config.port, () => {
  console.log(`Fileverse Backend Service running on port ${config.port}`);
});
