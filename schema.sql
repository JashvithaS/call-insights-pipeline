-- ============================================================
--  ICAG CallIQ — Supabase Schema
--  Run this in Supabase → SQL Editor → New Query
-- ============================================================

create extension if not exists "uuid-ossp";

-- 1. CALLS
create table if not exists calls (
  id                  uuid primary key default uuid_generate_v4(),
  batch_id            uuid,
  sf_number           text,
  lead_name           text,
  phone_number        text,
  team_name           text,
  call_type           text,
  call_status         text,
  recording_link      text,
  mp3_url             text,
  transcript          text,
  summary             text,
  program             text,
  course              text,
  college_interested  boolean,
  walkin_interested   boolean,
  walkin_date         date,
  follow_up_required  boolean,
  sentiment           text,
  quality_category    text,
  score               integer,
  confidence_score    numeric(4,2),
  action_items        text[],
  discussion_points   text[],
  objections          text[],
  interest_level      text,
  lead_qualified      boolean,
  raw_ai_json         jsonb,
  status              text default 'pending',
  error_message       text,
  processing_started  timestamptz,
  processing_done     timestamptz,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- 2. BATCHES
create table if not exists batches (
  id            uuid primary key default uuid_generate_v4(),
  file_name     text not null,
  total_rows    integer default 0,
  done_rows     integer default 0,
  failed_rows   integer default 0,
  status        text default 'processing',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- 3. RULES
create table if not exists rules (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  description text,
  condition   text not null,
  action      text not null,
  enabled     boolean default true,
  priority    integer default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Seed rules
insert into rules (name, description, condition, action, enabled, priority) values
  ('Fee discussion detection','Flag calls where student asks about fees','Student mentions fees, fee structure, payment, scholarship, or financial aid','Set fee_discussion=true. If mentioned more than twice, add +10 to interest score.',true,10),
  ('Walk-in commitment','Detect when student confirms a walk-in date','Student agrees to a specific walk-in date or says they will visit campus','Set walkin_interested=true, extract the date, add +15 to score.',true,20),
  ('Competitor college mention','Detect if student mentions another college','Student mentions any other college, university, or institution by name','Add competitor name to discussion_points, reduce interest score by 5.',true,5),
  ('Negative signal','Student shows clear disinterest','Student says they are not interested or asks not to call again','Set college_interested=false, sentiment=Negative, quality_category=Poor.',true,30),
  ('Callback request','Student asks to be called back','Student says they are busy or requests a callback','Set follow_up_required=true, add callback request to action_items.',true,15);

-- 4. Trigger
create or replace function update_updated_at()
returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

create trigger calls_updated_at   before update on calls   for each row execute function update_updated_at();
create trigger batches_updated_at before update on batches for each row execute function update_updated_at();
create trigger rules_updated_at   before update on rules   for each row execute function update_updated_at();

-- 5. Analytics views
create or replace view dashboard_stats as
select
  count(*)                                                  as total_calls,
  count(*) filter (where status='done')                     as processed_calls,
  count(*) filter (where quality_category='High Quality')   as high_quality,
  count(*) filter (where quality_category in ('Poor','Very Poor')) as poor_quality,
  count(*) filter (where college_interested=true)           as interested_leads,
  count(*) filter (where walkin_interested=true)            as walkin_interested,
  count(*) filter (where sentiment='Positive')              as positive_sentiment,
  count(*) filter (where sentiment='Neutral')               as neutral_sentiment,
  count(*) filter (where sentiment='Negative')              as negative_sentiment,
  round(avg(score),1)                                       as avg_score
from calls;

create or replace view team_performance as
select team_name, count(*) as total_calls, round(avg(score),1) as avg_score,
  count(*) filter (where walkin_interested=true) as walkin_conversions,
  count(*) filter (where sentiment='Positive') as positive_calls
from calls where status='done' and team_name is not null
group by team_name order by avg_score desc;
