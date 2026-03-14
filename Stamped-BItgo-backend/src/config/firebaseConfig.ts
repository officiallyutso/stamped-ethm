import * as admin from 'firebase-admin';
import path from 'path';

const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');

// eslint-disable-next-line @typescript-eslint/no-var-requires
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const db = admin.firestore();
export default admin;
