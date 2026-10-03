---
description: First-run setup. A real conversation about your career, your goals, and a few genuine wins, then writes your private config files. Run once, or again any time your targets change.
---

**Agent:** `coach` · runs in this session (it's a conversation).

## Task
0. Seed the vault. For each file in `templates/vault/` (Dashboard.md,
   Strategy.md, Tracking/Contacts.md, Tracking/Companies.md, Outreach
   Drafts/_queue.md, Automation/Run Log.md), copy it to the same path under
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

## Rules
- Never write a number they didn't say.
- If they mention a company without a URL, look it up rather than asking
  them to find it.
- End by running `/jobs-scout` once, so the first session ends with a real
  first look at the market rather than just a filled-in form.
