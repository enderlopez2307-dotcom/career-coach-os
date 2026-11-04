---
description: First-run setup. A real conversation about your career, goals and wins, then a guided setup of your dashboard, daily scan, Gmail and the commands. Run once, or again any time your targets change.
---

**Agent:** `coach` · runs in this session (it's a conversation).

Open by telling them the shape in two lines: about fifteen minutes of
questions about their career, then about ten minutes setting up their
dashboard and daily scan together. On a re-run, skip any Part 2 step that
`vault/Automation/Setup.md` already shows as done or skipped.

## Task
0. Seed the vault. For each file in `templates/vault/` (Dashboard.md,
   Strategy.md, Tracking/Contacts.md, Tracking/Companies.md, Outreach
   Drafts/_queue.md, Automation/Run Log.md, Automation/Setup.md), copy it to
   the same path under
   `vault/` only if it does not already exist there. Never overwrite one.
   These files, and everything else under `vault/` and `config/`, are
   private to the candidate and gitignored.

Then interview the candidate, plain language, one question at a time:

1. Current role, years of experience, the through-line of the career.
2. Target roles, ranked, with seniority band for each. Skip levels that
   don't apply — ask "IC or management, or open to either?"
3. Comp floor — the number below which a role isn't worth discussing.
4. Location rules: preferred, acceptable, dealbreaker, and any exception
   worth naming now.
5. Companies to exclude (current employer at minimum) and industries to avoid.
6. Target companies, tiered, with their careers/ATS URL if known — offer to
   find the URL via `WebSearch` for anything named without one.
7. Three to five real wins, STAR-shaped, with a number wherever honest.
   Don't accept a vague claim — ask "how much, how many, compared to what."
8. A paragraph of their own writing, pasted in, to seed `config/voice.md`.
   Ask for any hard rule they already know they want followed.

Write the four files (`config/profile.md`, `wins.md`, `voice.md`,
`scoring_rubric.md`) from the templates in `config/`, filled with what they
said — never invent an answer to a question they didn't answer; mark it
`UNCONFIRMED` instead. Draft `scoring_rubric.md`'s weights and anchors from
what they emphasized, then show it to them and ask if the weights feel
right before finishing.

Then write `config/feeds.json` from `config/feeds.template.json`, so the
morning scan reads their target companies' job boards directly. Don't ask
them to do any of this; work it out yourself:
- `filters.places`: their acceptable cities and country from question 4.
  `remote_regions`: the regions a remote role must cover for them.
  `target_keywords`: the words their target role titles use, from question 2.
  `not_target_keywords`: look-alike words to keep off the top table (for a
  trust and safety search, "health and safety"). `exclude`: every excluded
  company from the profile.
- One entry per target company, never an excluded one. For each, find its
  job feed: try `boards-api.greenhouse.io/v1/boards/<slug>/jobs`,
  `api.ashbyhq.com/posting-api/job-board/<slug>`,
  `api.lever.co/v0/postings/<slug>?mode=json` and
  `apply.workable.com/api/v1/widget/accounts/<slug>` and
  `api.smartrecruiters.com/v1/companies/<slug>/postings` with `WebFetch`, guessing
  the slug from the company name and its careers page. Keep the one that
  returns jobs. If its careers page links to `myworkdayjobs.com`, add a
  `workday` entry from that address (the template's `_how` note shows how).
  Google, Meta, TikTok, Apple, Amazon, Shopify and Etsy have their own
  readers: copy their template entries and set the location fields as the
  template's `_how` notes say.
- `discover`: 30 to 60 more employers in their field and places that
  aren't in the list yet, names only. Don't look up their boards: the
  morning fetch finds and checks them itself, and keeps finding more.
- A company with none of these stays out of the file. Name it in the
  profile's URL table so Scout searches it by hand, and tell them it isn't
  covered automatically.

## Part 2: set up, together, before the session ends

The interview is half of onboarding. Everyone who stopped after it went
quiet, so never end here. Tell them in one line that there are five short
steps left, about ten minutes, then walk them in order, one at a time,
waiting for each answer. Write `vault/Automation/Setup.md` as you go (format
below), so a later session knows exactly what is left.

1. **First look at the market.** Run `/jobs-scout` once. Show the top two or
   three verified roles in plain words, not the whole report.
2. **The dashboard.** Run `/dashboard`. It publishes their Search Desk, a
   private page they open in the browser, and fills it with what the
   interview and the scan just produced. Open it, ask them to bookmark it,
   and point at the Today tab: "this is where your next moves live; tick
   them off here."
3. **The daily morning scan.** Explain in two lines: every morning at 07:30
   a locked-down run scans their companies and the market and files a
   report, with no email access and nothing it can send. Ask if they want
   it. On yes, install it for them and show the result:
   - **Mac:** `bash scripts/install-launchd.sh`
   - **Windows:** `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-task.ps1`
     (Task Scheduler, runs as them while signed in, no admin needed)
   - **Linux:** no installer yet; record `skipped` and tell them
     `/jobs-daily` does the same thing by hand.
   On no, record `skipped` and tell them about `/jobs-daily`.
4. **Gmail.** Check whether this session has a Gmail tool (search threads,
   read a thread). If it does, say `/jobs-mail` is ready and that it only
   reads and drafts, never sends. If not, tell them how to connect it in the
   app they are using (desktop app or claude.ai: Settings, Connectors,
   Gmail) and that it is optional: everything else works without it.
5. **The tour.** Two minutes, plain words, no list of every command:
   - Their day: open a session in this folder and say what happened, or
     type `/whats-next`. That is the only habit that matters.
   - When a reply or invite lands: `/jobs-mail`, then `/checkin`.
   - Before applying anywhere: `/warm-path <Company>`. Before an interview:
     `/jobs-prep`, then `/mock-interview`.
   - Every drafted message waits in `/review-queue`. Nothing is sent
     without their own click.
   - After a rejection: `/postmortem`.
   - `README.md` lists everything else; they never need to memorise it.

Then seed the dashboard's Today tab with their first week (as `actions`
through `/dashboard`): the one or two best roles from the scan with a
`/warm-path` step each, "Tomorrow: open a session and type /whats-next",
and any setup step they skipped. Close with a short Recruiter's read: the
one move that matters most this week.

### `vault/Automation/Setup.md`
```markdown
# Setup

Where this search's setup stands. `/onboard` writes it; the session-start
hook reads it to decide what to offer next. Each step is `done <date>`,
`skipped <date>`, `not on a Mac`, or `not yet`.

- Profile: done <date>
- Dashboard: not yet
- Daily schedule: not yet
- Gmail: not yet
- Tour: not yet
```
A step they decline is `skipped`, never left as `not yet`, so they are
offered it again only if they ask.

## Rules
- Never write a number they didn't say.
- If they mention a company without a URL, look it up rather than asking
  them to find it.
- Never stop after the interview. Part 2 is what turns the config files
  into a search they actually use. If they have to leave mid-way, write
  `Setup.md` with what is done and tell them the next session will pick up
  from there on its own.
