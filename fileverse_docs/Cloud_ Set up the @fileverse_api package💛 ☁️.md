Cloud: Set up the @fileverse/api package💛 ☁️

The @fileverse/api package on Cloud keeps your dDocs API Server running 24/7 without requiring any local setup. Deploy once and access from anywhere. Currently we are supporting Heroku & Cloudflare. 

Recommended if you prefer a simple hosted setup and want always-on API access without managing local infrastructure.



Setting up on Heroku 👩‍🔧

Prerequisites: You need to have enabled Developer Mode and generated your API key before starting. If you haven’t done so yet, please follow the API key generation guide.

Access your API key settings

Open Settings in your dDocs account

Click on Developer mode

Navigate to Your API keys section

Click the three dots [...] next to your key

Select Setup

Choose Heroku deployment

This opens the API connection setup screen.

Click the Cloud tab on the right side

Click Deploy on Heroku

Configure your Heroku app

⚠️ Before deploying: Heroku requires a credit card, add payment details to your account before proceeding.

You'll be redirected to Heroku to set up your new app.

Enter an App name 

Select your Runtime location 



Set configuration variables

Scroll down to the Config Vars section and fill in the required values (if not already set):

API_KEY: Your dDocs API key

RPC_URL: https://rpc.gnosischain.com

Deploy your app

Click Deploy app to start the deployment process.

Please note the “configure environment” step might last a few minutes

Once complete, you'll see a success screen with deployment steps checked off.

Access your app

Click Manage App (as shown in image above) to open your app's dashboard

You can also access it by clicking “Dashboard” on the top right menu.

To see the logs of your running app, click on More (top right), then select View logs.

Get your Fileverse API server URL

What this is: Your Fileverse API server URL is the web address where your dDocs API is running. You'll need this URL to connect AI tools to your encrypted documents.

What to do with it: Copy this URL and provide it to any AI agent or tool that needs to access your dDocs. Different tools require different endpoints:

For MCP-compatible tools (Claude, Cursor, Windsurf): Add /mcp to the end (e.g., https://your-app.herokuapp.com/mcp)

For direct API calls: Add /api/ddocs to the end (e.g., https://your-app.herokuapp.com/api/ddocs)

How to find it:

In your app dashboard, click on the Settings tab (as shown in the image below)

Scroll down to the "Domains" section

You'll see the base URL like: https://your-app-name.herokuapp.com

Copy this URL, then add the appropriate endpoint:

For MCP tools (Claude, Cursor, Windsurf): https://your-app-name.herokuapp.com/mcp

For API calls: https://your-app-name.herokuapp.com/api/ddocs?apiKey=YOUR_KEY



Setting up on Cloudflare 👩‍🔧

Prerequisites: You need to have Developer Mode enabled and generated your API key before starting. If you haven’t done so yet, please follow the API key generation guide.

Access your API key settings

Open Settings in your dDocs account

Click on Developer mode

Go to Your API keys

Click the three dots [...] next to your key

Select Finish setup

Choose Cloudflare deployment

The above step opens the API connection setup screen.

Click the Cloud tab on the right side

Click Deploy on Cloudflare



Log in to Cloudflare

You will be redirected to Cloudflare to setup your new app. Before that would you need a Cloudflare account. 



Configure the app

After you’ve created an account and logged in, you will land on a page where you will be asked to configure your app details. 

The first step is to connect to your Git account. 



Connect your Git account

If your Git account is not linked with Cloudflare, you can link it by following the steps below.

Click on the dropdown and choose either Github or Gitlab, whichever is applicable.

Selecting an option from above will redirect you to a screen that looks like the one below. Click on Configure.

After clicking on Configure will land you on the following page. Scroll down to the bottom of this page to give repository access.

Select All repositories and click on Save



Configure remaining app fields

Once your Git account is setup, fill the remaining fields on the same page. 

The fields Project name, NODE_ENV, Select D1 database, Deploy command should be auto-filled. 

The only mandatory field you need to fill is API_KEY. Fill this with the API key you generated in Developer mode. 



Create and deploy

Finally, scroll down to the bottom of the page and click on Create and Deploy. This will build and deploy your app on Cloudflare.



View app dashboard

Once your app is deployed, you will be redirected to the app’s dashboard. 

The endpoint at the top-left of the page (marked by the red rectangle) is your API server url. 



Access your app

Click to Open Cloudflare Dashboard (or go to dash.cloudflare.com)

Open Workers & Pages (or Pages) and select your project



To see logs: Click on the triple dot icon adjacent to your app and select View metrics.





Get your Fileverse API server URL

What this is: Your Fileverse API server URL is the web address where your dDocs API is running. You’ll need this URL to connect AI tools to your encrypted documents.

What to do with it: Copy this URL and give it to any AI agent or tool that needs to access your dDocs. Different tools need different endpoints:

For MCP-compatible tools (Claude, Cursor, Windsurf): Add /mcp to the end (e.g. https://your-project.your-subdomain.workers.dev/mcp)

For direct API calls: Add /api/ddocs to the end (e.g. https://your-project.your-subdomain.workers.dev/api/ddocs)



How to find it:

In the Cloudflare dashboard, open your Workers & Pages (or Pages)



Select your application (in above image it would be fileverse-api)

Go to the Overview or Settings tab

Find your project’s URL — it will look like https://your-project.your-subdomain.workers.dev (or a custom domain if you added one)



Copy this base URL then add the right path:

For MCP tools (Claude, Cursor, Windsurf): https://your-project.your-subdomain.workers.dev/mcp

For API calls: https://your-project.your-subdomain.workers.dev/api/ddocs?apiKey=YOUR_KEY

Test your API 👩‍🔬 

Test with Claude (easiest for beginners)

Test your dDocs API directly in Claude without any technical setup.

Go to claude.ai and open Settings

Click on "Connectors" 

Then "add custom connector" and enable it

Add a new MCP server with these details:

Name: choose a name

URL: https://your-app-name.herokuapp.com/mcp or https://your-project.your-subdomain.workers.dev/mcp(use your base URL from either Heroku or Cloudflare previous steps + /mcp)

Now you can ask Claude: "Create a dDoc explaining what I can do with the Fileverse API”

Claude will use your API to create the document automatically ✨️ 

Test with Postman (for developers)

The image below shows how to create a new document via Postman. The URL (partially-hidden in orange) is the base URL we obtained from the setup section. The request payload accepts two fields: file title and content.

Once you click Send, the document will be created and saved to the SQLite database running on your hosted Heroku or Cloudflare instance.



View your documents 💃 

Soon after the document is created, it will appear on your Default API Space within a few minutes.



Next Steps 👩‍🚀 

Use your API with LLMsConnect Claude, ChatGPT, and other LLMs to your local dDocs setup

Switch to Local setup If you want complete control over where your data lives



FAQ 👩‍🔧 

1. When should I choose cloud setup over local setup?

Choose cloud setup if you want:

Always-on API access

To use @fileverse/api from multiple machines or tools

To avoid running background services locally

Choose local setup if you want full local control or offline usage.

2. What data is stored on Heroku?

Your file’s title and content in unencrypted form.

@fileverse/api uses Postgres as its datastore where it stores your document’s title, content and metadata in unencrypted form. So when you host your application on Heroku, Heroku will host both the Fileverse API server as well as the Postgres DB. 

@fileverse/api encrypts your documents before publishing on chain, but Postgres (on Heroku) would still have your file title and content in unencrypted form.

3. Can I change configuration values after deployment?

You can update environment variables anytime from the Heroku dashboard under Settings → Config Vars. Changes take effect after a restart.

4. How do I know if my Fileverse API server is running?

Open your app in Heroku and check View logs. A running Fileverse API server instance will show startup logs and incoming API requests.

5. What happens if the Heroku app restarts or sleeps?

The Fileverse API server will restart automatically. Your documents and state persist via the database file. No manual action is required.

6. Can I migrate from cloud setup to local setup later?

You can stop or delete the Heroku app and switch to a local @fileverse/api setup at any time. You documents created via Heroku will remain accessible in your Default API Space. 

Note that these documents will not automatically appear in your local setup or in the SQLite database on your local machine. Currently, @fileverse/api does not support syncing documents from your Default API Space (in your dDocs account) back to a local instance.

7. Is Heroku the only supported cloud option?

For now, yes. We're open to adding more platforms based on user feedback.

10. Can I deploy multiple Fileverse API server instances?

You can deploy multiple Fileverse API server instances (e.g. for work and personal), each with its own API key and configuration.

11. What should I do if deployment fails?

Please check the Heroku logs first. Most issues are due to missing environment variables or invalid API keys. If you’re stuck, reach out to us 👩‍🏭 

Need help? Reach out to us on Twitter or hello@fileverse.io 💛