# Local Handyman Austin Estimating Command Center

Standalone static site for the Local Handyman Austin Estimating Command Center. GitHub Pages publishes the repository root.

This page is a mockup. It shows sample data only. Nothing is sent to a customer.

## Sample mode

`config.js` ships with an empty Supabase URL and anon key. When both are empty, the page uses its built-in sample quotes, step state, and chat. It does not load Supabase.

## Turn on the Supabase beta

This project is shared with other apps. The demo uses only these `public` tables: `lha_quotes`, `lha_approvals`, `lha_bot_steps`, and `lha_chat_messages`.

1. In the Supabase SQL editor, run `supabase/schema.sql`. It is safe to run again. It creates those tables if they are missing, turns on row level security, and adds anon select and insert policies. It does not read or write any table whose name does not start with `lha_`.
2. The script seeds `lha_quotes` with the same sample quotes shown on the page, and seeds `lha_bot_steps` with the sample step progress.
3. Put the project URL and the anon key in `config.js`. Do not put a service role key in that file. The file is public.
4. Reload the page. The header label reads `Beta · Mockup with sample data`. Quote approvals, bot step progress, and the guide chat are saved in Supabase.

Clear both values in `config.js` to return to the built-in sample data. The label returns to `Mockup with sample data`.

## Pages

Pushes to `main` run `.github/workflows/pages.yml`, which deploys this repository with GitHub Pages.

https://13cristianaguilar-bot.github.io/localhandyman-command-center/
