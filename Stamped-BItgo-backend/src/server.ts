import express from 'express';
import bodyParser from 'body-parser';
import { config } from './config/bitgoConfig';
import signRoutes from './routes/signRoutes';

const app = express();

// Limit message size to prevent payloads larger than defined norms
app.use(bodyParser.json({ limit: '10kb' }));

// Register routes
app.use('/api', signRoutes);

// Start server
app.listen(config.port, () => {
  console.log(`BitGo MPC Signing Backend Service running on port ${config.port}`);
});
