import { config } from './src/config/bitgoConfig';
import * as fs from 'fs';

const baseUrl = config.fileverseServerUrl || 'http://localhost:8001';
const apiKey = config.fileverseApiKey;

async function runTests() {
  let logOutput = `\n--- Fileverse API GET Endpoint Tests ---\n`;
  logOutput += `Base URL: ${baseUrl}\n`;
  logOutput += `API Key: ${apiKey ? apiKey.substring(0, 5) + '...' : 'MISSING'}\n\n`;

  // 1. GET /ping
  try {
    logOutput += `[TEST 1] GET /ping\n`;
    const resPing = await fetch(`${baseUrl}/ping`);
    logOutput += `Status: ${resPing.status}\n`;
    const pingData = await resPing.text();
    logOutput += `Response: ${pingData}\n\n`;
  } catch(e: any) { logOutput += `Failed: ${e.message}\n\n`; }

  // 2. GET /api/ddocs
  let latestDdocId: string | null = null;
  try {
    logOutput += `[TEST 2] GET /api/ddocs\n`;
    const resDdocs = await fetch(`${baseUrl}/api/ddocs?apiKey=${apiKey}&limit=5`);
    logOutput += `Status: ${resDdocs.status}\n`;
    const ddocsData = await resDdocs.json();
    logOutput += `Response:\n${JSON.stringify(ddocsData, null, 2)}\n\n`;
    
    if (ddocsData.ddocs && ddocsData.ddocs.length > 0) {
      latestDdocId = ddocsData.ddocs[0].ddocId;
    }
  } catch(e: any) { logOutput += `Failed: ${e.message}\n\n`; }

  // 3. GET /api/ddocs/:ddocId
  if (latestDdocId) {
    try {
      logOutput += `[TEST 3] GET /api/ddocs/${latestDdocId}\n`;
      const resDoc = await fetch(`${baseUrl}/api/ddocs/${latestDdocId}?apiKey=${apiKey}`);
      logOutput += `Status: ${resDoc.status}\n`;
      const docData = await resDoc.json();
      logOutput += `Response:\n${JSON.stringify(docData, null, 2)}\n\n`;
      
      logOutput += `> Extracted syncStatus: ${docData.syncStatus}\n`;
      logOutput += `> Extracted link: ${docData.link}\n\n`;
    } catch(e: any) { logOutput += `Failed: ${e.message}\n\n`; }
  } else {
    logOutput += `[TEST 3] Skipped GET /api/ddocs/:ddocId because no documents were found.\n\n`;
  }

  // 4. GET /api/search?q=...
  try {
    const query = 'Report';
    logOutput += `[TEST 4] GET /api/search?q=${query}\n`;
    const resSearch = await fetch(`${baseUrl}/api/search?apiKey=${apiKey}&q=${encodeURIComponent(query)}`);
    logOutput += `Status: ${resSearch.status}\n`;
    const searchData = await resSearch.json();
    logOutput += `Response:\n${JSON.stringify(searchData, null, 2)}\n\n`;
  } catch(e: any) { logOutput += `Failed: ${e.message}\n\n`; }

  logOutput += `--- Tests Complete ---\n`;
  
  fs.writeFileSync('test_results.txt', logOutput, 'utf8');
  console.log("Tests completed, results written to test_results.txt");
}

runTests();
