# Connecting IACG CallIQ to Zoho CRM

Once configured, every successfully analyzed call will automatically create a Lead in Zoho CRM with score, sentiment, summary, and action items.

## Step 1 — Register a Zoho API client (one-time, 5 minutes)

1. Open: https://api-console.zoho.in (use `.in` since you're in India — if you're on Zoho US use `.com`, EU use `.eu`)
2. Log in with your Zoho account.
3. Click **"GET STARTED"** next to **"Self Client"** (this is the simplest option).
4. Click **"CREATE NOW"**.
5. Copy the **Client ID** and **Client Secret** that appear. Save them somewhere safe (do NOT paste them in chat).

## Step 2 — Generate a refresh token (one-time)

A refresh token lets the server access Zoho on your behalf forever (without you needing to log in each time).

1. In the same Zoho API Console, click your Self Client → go to **"Generate Code"** tab.
2. In the **Scope** field, paste:
   ```
   ZohoCRM.modules.leads.ALL,ZohoCRM.users.READ
   ```
3. Set **Time Duration**: `10 minutes`.
4. Set **Scope Description**: `IACG CallIQ`.
5. Click **CREATE**. A **code** appears — copy it (you have 10 min to use it).

6. Open PowerShell (or any terminal) and run this — replacing the three placeholders with your code, client ID, and client secret:

   ```
   curl.exe -X POST "https://accounts.zoho.in/oauth/v2/token?grant_type=authorization_code&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&code=YOUR_CODE"
   ```

7. The response contains `"refresh_token": "1000.xxxxx..."` — **copy that refresh_token value**. This is the one you need.

## Step 3 — Add Zoho keys to your `.env`

Open `.env` in your AI-admission folder. Add these four lines at the bottom:

```
ZOHO_CLIENT_ID=1000.YOUR_CLIENT_ID
ZOHO_CLIENT_SECRET=YOUR_CLIENT_SECRET
ZOHO_REFRESH_TOKEN=1000.YOUR_REFRESH_TOKEN
ZOHO_REGION=in
```

(Use `com` if your Zoho is on the US data center, `eu` for European.)

Save the file.

## Step 4 — (Optional) Add custom fields in Zoho CRM

The server tries to write these custom fields on each Lead:
- `Call_Score__c` (Number)
- `Sentiment__c` (Single Line)
- `Interest_Level__c` (Single Line)
- `Walkin_Interested__c` (Checkbox)
- `Course_Interested__c` (Single Line)

To add them in Zoho:
1. Go to Setup → Customization → Modules and Fields → Leads.
2. Click "Create Custom Field" for each one.
3. Use the exact API names above (with `__c` suffix).

If you skip this step, the Lead still gets created with name, phone, summary, and action items — just no custom score columns.

## Step 5 — Restart the server

```powershell
node server.js
```

You should now see:
```
✅ CallIQ standalone server running on http://localhost:3001
   Speaker-labeled transcripts: ON
   Zoho CRM push: ON
```

If it says `Zoho CRM push: OFF`, your `.env` doesn't have all four `ZOHO_*` keys correctly. Re-check.

## Step 6 — Test it

Re-upload the Excel:
```powershell
curl.exe -X POST -F "file=@test_admission_calls.xlsx" http://localhost:3001/upload
```

Watch the server terminal. After each `✓ done`, you'll now see:
```
    📤 pushed to Zoho CRM
```

Then go to Zoho CRM → Leads → you'll see 3 new leads (M.karthik, Nithin, Suresh Kumar) with score, sentiment, summary.

## Troubleshooting

**"Zoho push failed: invalid_token"** → refresh token expired or wrong. Re-run Step 2.

**"Zoho push failed: INVALID_FIELD"** → custom field name doesn't exist. Either create it in Zoho (Step 4) or remove that field from the `pushToZoho()` function in server.js.

**"Zoho push failed: DUPLICATE_DATA"** → a lead with that phone number already exists. That's OK — Zoho prevents duplicates by default.

**Nothing pushed and no error** → check that the server log says `Zoho CRM push: ON` at startup. If it says OFF, your `.env` keys aren't being read.

## Important — Zoho is OPTIONAL

If you don't want Zoho:
- Just don't add the `ZOHO_*` keys to `.env`
- The server runs perfectly without it, you just won't see "📤 pushed to Zoho CRM"
- Everything else (Supabase, transcripts, analysis) still works

You can add Zoho later anytime by just adding the keys and restarting.
