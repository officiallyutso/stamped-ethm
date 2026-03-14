---
title: Local: Set Up @fileverse/api package 💛 👩‍💻
date: 2026-03-14
---

# Local: Set Up @fileverse/api package 💛 👩‍💻

The `@fileverse/api` package connects your local terminal to your Developer Space. All interactions stay local and end-to-end encrypted. Your documents, API calls, and data never leave your machine.

**Recommended if:** You're familiar with npm packages and want complete control over where your data lives.

* * *

## Installation 👩‍🏭

### Option 1: Using npx (recommended)

Run the latest version without installing anything globally:

```plaintext
npx @fileverse/api
```

This starts the Fileverse API server on port `8001`, allowing API requests to create and manage documents.

### Option 2: Global installation

Install the package globally on your system:

```plaintext
npm install -g @fileverse/api
```

This makes the `fileverse-api` command available on your system.

To verify the installation run:

```plaintext
fileverse-api --help # or -h
```

If the installation was successful, you should see help output with a list of available options.

* * *

## Available tools 👩‍🔧

When you install `@fileverse/api`, you get access to two command-line tools:

1. `fileverse-api`: Starts and runs the Fileverse API server (HTTP Server + worker). This is the main server that handles document management via REST API.
2. `ddctl`: A CLI tool for managing documents directly from your terminal. Use `ddctl` to create, list, view, update, and delete documents without making HTTP requests. Run `ddctl --help` to see all available commands.  
      
    You can learn more about `ddctl` [here](https://docs.fileverse.io/0x2d133a10443a13957278e7dfeefbfee826c82fd8/123#key=pP0g-V_cbId3AhuhejXD3upKmOePKMt5zPYDUAskY9JxVVVJQtyRSk3qUO5joTKy).

* * *

## Running the API Server 👩‍🔬

Start the Fileverse API server in your terminal:

```bash
fileverse-api \
  --apiKey <API_KEY> \
  --rpcUrl <RPC_URL> \
  --port <PORT_NUMBER> \
  --db <DB_PATH>
```

You can also run the command without any flags, in which case the program will prompt you for the only mandatory variable which is `apiKey`. The rest will fallback to sensible defaults as shown below.

* Default DB\_PATH: `$HOME/.fileverse/fileverse-api.db`
* Default PORT\_NUMBER: `8001`
* Default RPC\_URL: `https://rpc.gnosischain.com`

Once the required values are provided, `@fileverse/api` will start the server in your terminal. You can then make API requests to create and manage documents.

* * *

## What Happens Now 💃

With the API server running:

* Your local environment connects to your dDocs Developer Space
* You can create, edit, read, and delete documents via API
* LLMs and external tools can interact with your dDocs through the local server
* All data processing happens on your machine

* * *

## Next Steps 👩‍🚀

[**Use your API with LLMs**](https://docs.fileverse.io/0x2d133a10443a13957278e7dfeefbfee826c82fd8/131#key=8KgIPT-t2uYEjO5maT5_BIRBeMY7nHpSdGSEO1q_RqV7ioWzu-7gHwBdD-xs1K_a)  
Connect Claude, ChatGPT, and other LLMs to your local dDocs setup

[**Switch to Cloud**](https://docs.fileverse.io/0x2d133a10443a13957278e7dfeefbfee826c82fd8/117#key=qoZtMrSyMSnQCJn7A7nMNnYIQHeXPgDXNZKzMrqOWVKhAPhmbjbYBpzyMOx5Vsuv)  
Deploy a cloud-hosted Fileverse API server that runs 24/7

* * *

## FAQ 👩‍🏫

### 1\. What does `@fileverse/api` install on my machine?

`@fileverse/api` runs as a lightweight HTTP server and a worker on your computer. It stores minimal configuration needed to manage your documents. It does not modify system files or interfere with existing applications.

### 2\. Does the API Server run all the time?

The API Server runs only while it is actively started.  
When you run `fileverse-api`, it runs in the foreground and remains active as long as the terminal session is open.

You can stop it at any time (for example, by pressing `Ctrl+C`). Your documents remain intact, and everything resumes normally the next time you start the API Server.

To keep the API Server running continuously, you’ll need to keep the process running or deploy it using a cloud or managed setup.

### 3\. What data does `@fileverse/api` have access to?

Only the text you explicitly send to the API server is processed. `@fileverse/api` does not scan your files, monitor activity, or access your system without your instruction.

### 4\. Is my data private?

Documents are encrypted before being published, which ensures privacy by design. `@fileverse/api` is self-hosted by default, which means you control where it runs and what data it handles.

### 5\. Do I need an account or login to use `@fileverse/api` locally?

You need a dDocs account to generate an API key. The API key is required for syncing and publishing documents. You generate and control this key from your dDocs account, on your developer space.

### 6\. Does `@fileverse/api` work offline?

You can create and manage documents locally while offline. Publishing or syncing requires an internet connection.

### 7\. Does `@fileverse/api` store my data anywhere?

`@fileverse/api` stores your documents (title, content, and metadata) in a local SQLite database on your machine. This ensures your data stays on your computer and is not uploaded elsewhere.

By default, the database is created at `$HOME/.fileverse/fileverse-api.db`.

You can configure the database location using the `--db` flag when running the `fileverse-api` command.

For example:

```plaintext
fileverse-api --db <DIFFERENT_DB_PATH>
```

### 8\. What ports does `@fileverse/api` use? Can I change them?

`@fileverse/api` runs a local HTTP server on a configurable port. The default port is `8001`, and you can change it if it conflicts with something on your system.

To run the server on a different port, run

```plaintext
fileverse-api --port <DIFFERENT_PORT>
```

### 9\. Is `@fileverse/api` safe to use on a work machine?

Yes, `@fileverse/api` runs locally on your machine without requiring administrator access. It only processes data you explicitly send to it, and all operations are transparent and under your control. Your documents and API keys stay on your device. `@fileverse/api` encrypts your documents before publishing.

### 10\. I’ve installed the package, but running `fileverse-api` shows “command not found”

This usually means the directory where npm installs global command-line executables is not included in your `$PATH`. First, find out where npm installs global executables on your system by running:

```plaintext
npm config get prefix
```

Ensure the `bin` subdirectory of the output directory is included in your PATH. For example, if the above command outputs `/usr/local`, then `/usr/local/bin` should be in your PATH.

After updating your `$PATH`, restart your terminal and run `fileverse-api` again.

* * *

**Need help?** Reach out to us on [Twitter](https://x.com/fileverse) or hello@fileverse.io 💛