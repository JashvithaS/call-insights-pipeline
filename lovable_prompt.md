# IACG CallIQ — Lovable.dev Frontend Prompt
# Paste this ENTIRE prompt into Lovable.dev "Start a new project" chat

---

Build a full admin dashboard web app called "IACG CallIQ" for AI-powered admissions call analysis.

## Tech
- React + TypeScript
- Tailwind CSS
- Shadcn/ui components
- Supabase client (supabase-js)
- React Query for data fetching
- React Router for navigation

## Environment Variables needed
```
VITE_API_URL=http://localhost:3001
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
```

## Pages to build

### 1. Login Page (`/login`)
- Simple email + password login
- Uses Supabase Auth
- Redirect to /dashboard on success

### 2. Dashboard (`/dashboard`)
- Stat cards: Total Calls, Avg Score (/100), Interested Leads, Walk-in Conversions, Positive Sentiment %
- Sentiment distribution bar (green/amber/red horizontal bar)
- Team performance table (Team Name | Total Calls | Avg Score | Walk-in Conversions)
- Recent batches list with progress bars
- Export button (GET /export)

### 3. Upload Page (`/upload`)
- Drag-and-drop file zone accepting .xlsx .csv
- POST to /upload with multipart/form-data (field name: "file")
- Show real-time processing progress by polling GET /batch/:id every 3 seconds
- Progress bars for: Download → Convert → Transcribe → Analyse
- Show done/total count per stage

### 4. Calls Page (`/calls`)
- Table with columns: Lead Name | SF Number | Course | Sentiment | Score | Quality | Walk-in | Team | Actions
- Filter bar: Sentiment, Quality Category, Team Name, Call Type, Search (name/SF number)
- Score shown as colored badge (green >75, amber 50-75, red <50)
- Sentiment badge (green=Positive, amber=Neutral, red=Negative)
- Click row → opens call detail drawer/sheet

### 5. Call Detail Drawer
Opens from clicking a row in Calls page. Shows:
- Header: Lead name, SF number, team, call type, date
- Sentiment + quality badges
- Audio player (HTML5 audio tag with mp3_url)
- Download MP3 button
- Lead details table: Course, Program, Walk-in date, Phone, Follow-up, College Interested
- AI Score ring chart (circular progress) with score/100
- Expandable full transcript section
- Action items as bullet list
- Objections as tags/pills
- Summary text

### 6. Rules Page (`/rules`)
- List of AI rules (GET /rules)
- Each rule shows: Name, Description, Condition, Action, Enabled toggle
- "Add Rule" button → modal form with fields: Name, Description, Condition (textarea), Action (textarea), Priority (number), Enabled (toggle)
- Edit button → same modal pre-filled
- Delete button → confirm then DELETE /rules/:id
- Toggle enabled → PATCH /rules/:id

## API calls
All go to VITE_API_URL:
- POST /upload (multipart) → upload Excel
- GET /batch/:id → batch status polling
- GET /calls?sentiment=&quality_category=&team_name=&search=&page=&limit= → list calls
- GET /dashboard → stats
- GET /export?batch_id= → download Excel (triggers file download)
- GET /rules → list rules
- POST /rules → create rule
- PATCH /rules/:id → update rule
- DELETE /rules/:id → delete rule

## Design
- Color scheme: white background, dark sidebar
- Sidebar nav: Dashboard, Upload, Calls, Rules, Team (icons from lucide-react)
- Top bar with: page title, user avatar, logout
- Responsive (works on tablet)
- Toast notifications for: upload success, errors, export started

## Color coding
- Score > 75 → green
- Score 50–75 → amber/yellow
- Score < 50 → red
- Sentiment Positive → green badge
- Sentiment Neutral → amber badge
- Sentiment Negative → red badge
- Quality High → blue badge
- Quality Average → gray badge
- Quality Poor/Very Poor → red badge
