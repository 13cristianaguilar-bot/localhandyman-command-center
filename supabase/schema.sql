-- Local Handyman Austin Estimating Command Center
-- Beta tables for this demo only. Safe to run more than once.
-- Every statement touches only public tables whose names start with lha_.
-- Anon can select and insert. Anon cannot update or delete.
-- Seeded quotes match the sample quotes on the page. No prices are stored.

create table if not exists public.lha_quotes (
  id text primary key,
  zip text not null,
  area text not null,
  job text not null,
  job_type text not null,
  status text not null check (status in ('wait', 'draft', 'hold', 'sent', 'back')),
  inbox text not null,
  waiting numeric,
  bot_hours numeric,
  first_draft_hours numeric,
  past_hours numeric,
  past_ref text,
  materials jsonb not null default '[]'::jsonb,
  labor jsonb not null default '[]'::jsonb,
  qc jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.lha_approvals (
  id uuid primary key default gen_random_uuid(),
  quote_id text not null references public.lha_quotes (id) on delete cascade,
  action text not null check (action in ('approve', 'send_back')),
  note text,
  actor text,
  created_at timestamptz not null default now()
);

create table if not exists public.lha_bot_steps (
  id uuid primary key default gen_random_uuid(),
  step_key text not null,
  name text not null,
  step_index integer not null,
  paused boolean not null default false,
  path_now integer,
  created_at timestamptz not null default now()
);

create table if not exists public.lha_chat_messages (
  id uuid primary key default gen_random_uuid(),
  role text not null check (role in ('me', 'bot')),
  body text not null,
  created_at timestamptz not null default now()
);

alter table public.lha_quotes enable row level security;
alter table public.lha_approvals enable row level security;
alter table public.lha_bot_steps enable row level security;
alter table public.lha_chat_messages enable row level security;

revoke all on table public.lha_quotes from public, anon, authenticated;
grant select, insert on table public.lha_quotes to anon;

drop policy if exists lha_quotes_anon_select on public.lha_quotes;
create policy lha_quotes_anon_select
  on public.lha_quotes
  for select
  to anon
  using (true);

drop policy if exists lha_quotes_anon_insert on public.lha_quotes;
create policy lha_quotes_anon_insert
  on public.lha_quotes
  for insert
  to anon
  with check (true);

revoke all on table public.lha_approvals from public, anon, authenticated;
grant select, insert on table public.lha_approvals to anon;

drop policy if exists lha_approvals_anon_select on public.lha_approvals;
create policy lha_approvals_anon_select
  on public.lha_approvals
  for select
  to anon
  using (true);

drop policy if exists lha_approvals_anon_insert on public.lha_approvals;
create policy lha_approvals_anon_insert
  on public.lha_approvals
  for insert
  to anon
  with check (true);

revoke all on table public.lha_bot_steps from public, anon, authenticated;
grant select, insert on table public.lha_bot_steps to anon;

drop policy if exists lha_bot_steps_anon_select on public.lha_bot_steps;
create policy lha_bot_steps_anon_select
  on public.lha_bot_steps
  for select
  to anon
  using (true);

drop policy if exists lha_bot_steps_anon_insert on public.lha_bot_steps;
create policy lha_bot_steps_anon_insert
  on public.lha_bot_steps
  for insert
  to anon
  with check (true);

revoke all on table public.lha_chat_messages from public, anon, authenticated;
grant select, insert on table public.lha_chat_messages to anon;

drop policy if exists lha_chat_messages_anon_select on public.lha_chat_messages;
create policy lha_chat_messages_anon_select
  on public.lha_chat_messages
  for select
  to anon
  using (true);

drop policy if exists lha_chat_messages_anon_insert on public.lha_chat_messages;
create policy lha_chat_messages_anon_insert
  on public.lha_chat_messages
  for insert
  to anon
  with check (true);

create index if not exists lha_quotes_sort_idx
  on public.lha_quotes (sort_order);

create index if not exists lha_approvals_quote_created_idx
  on public.lha_approvals (quote_id, created_at);

create index if not exists lha_bot_steps_key_created_idx
  on public.lha_bot_steps (step_key, created_at);

create index if not exists lha_chat_messages_created_idx
  on public.lha_chat_messages (created_at);

insert into public.lha_quotes (
  id, zip, area, job, job_type, status, inbox, waiting, bot_hours,
  first_draft_hours, past_hours, past_ref, materials, labor, qc, sort_order
) values
  ('HM-1048', '78745', 'South Austin', 'Attic stairs and attic decking', 'Residential', 'wait', 'Leads inbox', 5, 17, 25, 16, 'Job HM-0731, attic stairs and decking, 2025', $lha$[{"item":"Attic ladder, 22.5 in x 54 in, aluminum","store":"Lowe's 78745","qty":1,"stock":"In stock"},{"item":"3/4 in plywood, 4 ft x 8 ft","store":"Home Depot 78745","qty":12,"stock":"In stock"},{"item":"2x6x8 lumber, framing for opening","store":"Home Depot 78745","qty":6,"stock":"In stock"},{"item":"Construction screws, 3 in, 5 lb box","store":"Home Depot 78745","qty":1,"stock":"In stock"},{"item":"Trim and casing kit","store":"Lowe's 78745","qty":1,"stock":"Low stock"}]$lha$::jsonb, $lha$[["Frame and cut attic opening",3],["Install attic ladder",3],["Lay attic decking, about 300 sq ft",9],["Trim, clean up, haul-off",2]]$lha$::jsonb, $lha${"level":"fl","short":"QC fixed labor: 25 h to 17 h","title":"Caught and corrected before it reached you","text":"First draft came in at 25 labor hours. A similar past job (HM-0731, attic stairs and decking) took 16 hours. QC Reviewer flagged the gap and the Estimator re-ran with that job as the reference. New draft: 17 hours."}$lha$::jsonb, 1),
  ('HM-1047', '78704', 'Bouldin', 'Fence tear-out and replace, 40 ft', 'Residential', 'wait', 'Leads inbox', 26, 14, 13, 13, 'Job HM-0655, 36 ft cedar fence, 2025', $lha$[{"item":"Cedar fence pickets, 6 ft","store":"Lowe's 78704","qty":80,"stock":"In stock"},{"item":"Pressure-treated post, 4x4x8","store":"Lowe's 78704","qty":7,"stock":"In stock"},{"item":"2x4x8 rails","store":"Lowe's 78704","qty":14,"stock":"In stock"},{"item":"Fast-setting concrete, 50 lb","store":"Home Depot 78704","qty":7,"stock":"In stock"},{"item":"Disposal and haul-away, old fence","store":"Added by QC","qty":1,"stock":"Added by QC"}]$lha$::jsonb, $lha$[["Tear out old fence",4],["Set posts",4],["Rails and pickets",5],["Haul-off and clean up",1]]$lha$::jsonb, $lha${"level":"fl","short":"QC added missing disposal","title":"Disposal was missing, now added","text":"The first draft had no disposal for the old fence. QC Reviewer added haul-away and 1 hour of labor. Hours now 14 vs 13 on the closest past job, within range."}$lha$::jsonb, 2),
  ('HM-1046', '78739', 'Circle C', 'Cedar deck replacement, 12 ft x 16 ft', 'Residential', 'wait', 'Leads inbox', 3, 22, 22, 24, 'Job HM-0702, 12 ft x 14 ft deck, 2025', $lha$[{"item":"Cedar decking, 5/4 x 6 x 16","store":"Home Depot 78739","qty":34,"stock":"In stock"},{"item":"Pressure-treated joist, 2x8x12","store":"Lowe's 78739","qty":14,"stock":"In stock"},{"item":"Exterior deck screws, 5 lb","store":"Home Depot 78739","qty":2,"stock":"In stock"},{"item":"Deck stain, 1 gal","store":"Lowe's 78739","qty":3,"stock":"In stock"}]$lha$::jsonb, $lha$[["Demo old decking and haul-off",5],["Replace damaged joists",5],["Install new decking",9],["Stain and finish",3]]$lha$::jsonb, $lha${"level":"ok","short":"QC: matches past work","title":"Matches past work","text":"22 hours vs 24 on a similar 12 ft x 14 ft deck. Quantities match the dimensions in the request. Disposal included."}$lha$::jsonb, 3),
  ('HM-1042', '78613', 'Cedar Park', 'Inspection punch list, 12 tasks', 'Residential', 'wait', 'Office inbox', 9, 11, 11, 10.5, 'Job HM-0688, 11-task punch list, 2025', $lha$[{"item":"GFCI outlet, 15 amp","store":"Home Depot 78613","qty":3,"stock":"In stock"},{"item":"Door stop, hinge pin","store":"Home Depot 78613","qty":4,"stock":"In stock"},{"item":"HVAC filter, 20x25x1","store":"Lowe's 78613","qty":2,"stock":"In stock"},{"item":"Exterior caulk, 10 oz","store":"Lowe's 78613","qty":4,"stock":"In stock"}]$lha$::jsonb, $lha$[["Electrical items (3)",2.5],["Doors and hardware (4)",2],["Exterior caulk and seal",3],["Misc items (4)",3.5]]$lha$::jsonb, $lha${"level":"ok","short":"QC: matches past work","title":"Matches past work","text":"11 hours vs 10.5 on a similar 11-task inspection punch list. All 12 tasks from the report are priced."}$lha$::jsonb, 4),
  ('HM-1045', '78731', 'Northwest Hills', 'Roof leak repair and drywall patch', 'Residential', 'draft', 'Leads inbox', null, null, null, 7, null, $lha$[]$lha$::jsonb, $lha$[]$lha$::jsonb, $lha${"level":"ok","short":"Still drafting","title":"Still drafting","text":"Estimator is pulling materials for the 78731 stores. Request came in after this week's rain. CompanyCam photos from the site visit are attached."}$lha$::jsonb, 5),
  ('HM-1044', '78758', 'North Austin', 'Office make-ready, 6 tasks', 'Commercial', 'hold', 'Office inbox', null, null, null, null, null, $lha$[]$lha$::jsonb, $lha$[]$lha$::jsonb, $lha${"level":"fl","short":"Held, commercial","title":"Held for you","text":"Commercial job. Logged and held until the commercial supplier list is added. Nothing was drafted or sent."}$lha$::jsonb, 6),
  ('HM-1043', '78620', 'Dripping Springs', 'Fascia repair, 20 ft', 'Residential', 'sent', 'Leads inbox', null, 6, 6, 6, 'Job HM-0640, fascia and soffit repair, 2025', $lha$[{"item":"Primed fascia board, 1x6x16","store":"Home Depot 78620","qty":2,"stock":"In stock"},{"item":"Exterior paint, 1 gal","store":"Home Depot 78620","qty":1,"stock":"In stock"}]$lha$::jsonb, $lha$[["Remove and replace fascia",4],["Prime, paint, clean up",2]]$lha$::jsonb, $lha${"level":"ok","short":"Approved by Steve","title":"Approved and sent","text":"Approved by Steve at 11:52 AM. Sent back to handyman.com and added to HouseCall Pro."}$lha$::jsonb, 7),
  ('HM-1041', '78748', 'Shady Hollow', 'Interior paint, 2 bedrooms', 'Residential', 'sent', 'Leads inbox', null, 9, 9, 9, 'Job HM-0699, 2 room repaint, 2025', $lha$[{"item":"Interior paint, eggshell, 1 gal","store":"Lowe's 78748","qty":4,"stock":"In stock"},{"item":"Painter's tape and plastic kit","store":"Lowe's 78748","qty":1,"stock":"In stock"}]$lha$::jsonb, $lha$[["Prep and mask",2],["Two coats, walls",6],["Clean up",1]]$lha$::jsonb, $lha${"level":"ok","short":"Approved by Matt","title":"Approved and sent","text":"Approved by Matt at 9:15 AM. Sent back to handyman.com and added to HouseCall Pro."}$lha$::jsonb, 8)
on conflict (id) do nothing;

insert into public.lha_bot_steps (step_key, name, step_index, paused, path_now)
select v.step_key, v.name, v.step_index, v.paused, v.path_now
from (
  values
    ('intake'::text, 'Intake Coordinator'::text, 0, false, 1),
    ('estimator'::text, 'Estimator'::text, 1, false, 1),
    ('qc'::text, 'QC Reviewer'::text, 2, false, 1),
    ('approver'::text, 'Steve or Matt'::text, 3, false, 1),
    ('path'::text, 'Go-live path'::text, 1, false, 1)
) as v(step_key, name, step_index, paused, path_now)
where not exists (select 1 from public.lha_bot_steps);
