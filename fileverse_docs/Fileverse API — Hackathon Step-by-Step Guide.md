---
title: Fileverse API — Hackathon Step-by-Step Guide
date: 2026-03-14
---

# Fileverse API — Hackathon Step-by-Step Guide

You'll be integrating Fileverse into your project to create, read, update, and delete encrypted documents (called **ddocs**) — either via REST API calls or MCP tools for AI agents. This guide walks you through setup to your first working integration.

* * *

## Step 1 — Create a Fileverse Account

1. Go to [ddocs.new](https://ddocs.new/)
2. Sign up for an account
3. You'll land on your personal dDocs homepage

* * *

## Step 2 — Enable Developer Mode

Developer Mode gives you an isolated **Developer Space** where your app's documents live. API keys only access this space — not your personal documents.

1. Go to **Settings → Developer Mode**
2. Toggle **Enable developer mode** to ON
3. Wait for activation to complete

Once enabled, a new **Default API Space** section appears on your homepage. This is where all documents created via the API will be stored.

* * *

## Step 3 — Generate Your API Key

1. In **Settings → Developer Mode**, scroll to **Your API Keys**
2. Click **\+ New API Key**
3. Give it a name (e.g. `my-hackathon-app`)
4. Click **Generate Key**

⚠️ Keep this key secret. Never commit it to a public repo or put it in client-side code. It has full access to your Developer Space.

> **Note:** You can only have one active API key at a time in the current version.

* * *

## Step 4 — Getting Your Server URL from ddocs.new

**Deploy your server by following this guide:** [https://docs.fileverse.io/0x2d133a10443a13957278e7dfeefbfee826c82fd8/117#key=qoZtMrSyMSnQCJn7A7nMNnYIQHeXPgDXNZKzMrqOWVKhAPhmbjbYBpzyMOx5Vsuv](https://docs.fileverse.io/0x2d133a10443a13957278e7dfeefbfee826c82fd8/117#key=qoZtMrSyMSnQCJn7A7nMNnYIQHeXPgDXNZKzMrqOWVKhAPhmbjbYBpzyMOx5Vsuv)

Take the server URL from the deployed app.

## Step 5 — Verify the Connection

Before writing any code, confirm your server is reachable:

```plaintext
curl https://YOUR_SERVER_URL/ping
```

You should see:

```plaintext
{"reply": "pong"}
```

If you get an error, double-check your SERVER\_URL from Step 4.

* * *

## Step 6 — Choose Your Integration Path

Pick the path that matches how you're building:

* **Path A — REST API:** You're building a JS app and want to call Fileverse directly from your code
* **Path B — MCP Tools:** You're building an AI agent (e.g. with Claude) and want the agent to manage documents natively

You can use both in the same project.

* * *

## Path A — REST API Integration

All requests require your API key as a query parameter: `?apiKey=YOUR_KEY`

### Create a Document

```plaintext
const SERVER_URL = 'https://YOUR_SERVER_URL';
const API_KEY = process.env.FILEVERSE_API_KEY; // store in .env, never hardcode

async function createDoc(title, content) {
  const res = await fetch(`${SERVER_URL}/api/ddocs?apiKey=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title, content })
  });
  const { data } = await res.json();
  return data.ddocId; // save this — you'll need it to update or delete
}
```

### Wait for the Document to Sync

After creating a document, it goes through a sync process before it gets a shareable link. Poll until `syncStatus` is `"synced"`:

```plaintext
async function waitForLink(ddocId) {
  for (let i = 0; i < 20; i++) {
    const res = await fetch(`${SERVER_URL}/api/ddocs/${ddocId}?apiKey=${API_KEY}`);
    const doc = await res.json();
    if (doc.syncStatus === 'synced') return doc.link;
    await new Promise(r => setTimeout(r, 3000)); // wait 3 seconds between attempts
  }
  throw new Error('Sync timed out');
}

// Put it together
const ddocId = await createDoc('My Project Notes', '# Notes\n\nHello from the hackathon!');
const link = await waitForLink(ddocId);
console.log('Shareable link:', link);
```

Sync typically takes 5–30 seconds.

### Read a Document

```plaintext
async function getDoc(ddocId) {
  const res = await fetch(`${SERVER_URL}/api/ddocs/${ddocId}?apiKey=${API_KEY}`);
  return res.json(); // includes title, content, syncStatus, link
}
```

### Update a Document

```plaintext
async function updateDoc(ddocId, content) {
  const res = await fetch(`${SERVER_URL}/api/ddocs/${ddocId}?apiKey=${API_KEY}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content }) // title is optional — only send what you want to change
  });
  return res.json();
}
```

### List Documents

```plaintext
async function listDocs(limit = 10, skip = 0) {
  const res = await fetch(`${SERVER_URL}/api/ddocs?apiKey=${API_KEY}&limit=${limit}&skip=${skip}`);
  return res.json(); // { ddocs: [...], total, hasNext }
}
```

### Search Documents

```plaintext
async function searchDocs(query) {
  const res = await fetch(`${SERVER_URL}/api/search?apiKey=${API_KEY}&q=${encodeURIComponent(query)}`);
  return res.json(); // { nodes: [...], total, hasNext }
}
```

> **Note:** Search returns `nodes`, not `ddocs`.

### Delete a Document

```plaintext
async function deleteDoc(ddocId) {
  const res = await fetch(`${SERVER_URL}/api/ddocs/${ddocId}?apiKey=${API_KEY}`, {
    method: 'DELETE'
  });
  return res.json();
}
```

* * *

## Path B — MCP Integration (AI Agents)

If you're building with an AI agent (e.g. Claude), connect Fileverse as an MCP server. The agent can then create, search, update, and delete documents using natural language — no manual API calls needed.

### Connect to Claude (Web)

1. Open [claude.ai](https://claude.ai/) → **Settings → Connectors → Add Custom Connector**
2. Fill in:
    
    * **Name:** Fileverse API
    * **Server URL:** `https://YOUR_SERVER_URL/`
3. Click **Add**

The MCP server is now connected. Claude will have access to 8 Fileverse tools automatically.

### Connect to Claude Code (Terminal)

```plaintext
claude mcp add fileverse-api --transport http https://YOUR_SERVER_URL/mcp
```

Verify it was added:

```plaintext
claude mcp list
```

### Available MCP Tools

Once connected, these tools are available to the agent:

| Tool                            | What it does                                              |
| ------------------------------- | --------------------------------------------------------- |
| `fileverse_create_document`     | Creates a doc and waits for blockchain sync automatically |
| `fileverse_get_document`        | Fetches full content of a doc by `ddocId`                 |
| `fileverse_update_document`     | Updates title and/or content, waits for sync              |
| `fileverse_list_documents`      | Lists documents with pagination                           |
| `fileverse_search_documents`    | Full-text search across all documents                     |
| `fileverse_delete_document`     | Permanently deletes a document                            |
| `fileverse_get_sync_status`     | Checks sync state and returns shareable link              |
| `fileverse_retry_failed_events` | Retries all failed sync events                            |

> The create and update tools automatically wait for blockchain sync (up to 60 seconds) and return the final shareable link — no polling code needed.

### Example Prompts for the Agent

* _"Create a ddoc with today's meeting notes and give me the link"_
* _"Search my ddocs for anything about authentication"_
* _"Update the project roadmap ddoc with the changes we just discussed"_
* _"List all my ddocs and tell me which ones haven't synced yet"_

* * *

## Understanding Sync Status

Every document goes through this lifecycle:

```plaintext
Create / Update → pending → synced ✓
                          → failed  (call retry)
```

| Status    | Meaning                                                             |
| --------- | ------------------------------------------------------------------- |
| `pending` | Saved, blockchain sync in progress                                  |
| `synced`  | On-chain. The `link` field is now available                         |
| `failed`  | Sync failed. Call `fileverse_retry_failed_events` or retry manually |

Only share the `link` with users once `syncStatus === "synced"`.

* * *

## Storing Your API Key Safely

Never hardcode your API key. Use a `.env` file:

```plaintext
# .env
FILEVERSE_API_KEY=your_key_here
FILEVERSE_SERVER_URL=https://your_server_url_here
```

```plaintext
// In your code
import 'dotenv/config';
const API_KEY = process.env.FILEVERSE_API_KEY;
const SERVER_URL = process.env.FILEVERSE_SERVER_URL;
```

Add `.env` to your `.gitignore`:

```plaintext
echo ".env" >> .gitignore
```

* * *

## Troubleshooting

| Problem                          | Fix                                                                                |
| -------------------------------- | ---------------------------------------------------------------------------------- |
| `{"reply": "pong"}` not returned | Double-check your SERVER\_URL from ddocs.new                                       |
| `401 Unauthorized`               | Check your API key — make sure it's passed as `?apiKey=...`                        |
| `syncStatus` stuck on `pending`  | Wait up to 60s, then poll `GET /api/ddocs/:ddocId` manually                        |
| `syncStatus: "failed"`           | Use the `fileverse_retry_failed_events` MCP tool or re-run the create              |
| MCP tools not showing in Claude  | Restart Claude after adding the connector and check Settings → Connectors          |
| `link` is undefined              | The document hasn't synced yet — only access `link` when `syncStatus === "synced"` |

* * *

## API Quick Reference

| Method | Path                 | Description                   |
| ------ | -------------------- | ----------------------------- |
| GET    | `/ping`              | Health check (no auth needed) |
| GET    | `/api/ddocs`         | List documents                |
| GET    | `/api/ddocs/:ddocId` | Get a document                |
| POST   | `/api/ddocs`         | Create a document             |
| PUT    | `/api/ddocs/:ddocId` | Update a document             |
| DELETE | `/api/ddocs/:ddocId` | Delete a document             |
| GET    | `/api/search?q=...`  | Search documents              |

All authenticated endpoints require `?apiKey=YOUR_KEY` as a query parameter.

* * *

_Questions? Find me at the hackathon or reach out at hello@fileverse.io_