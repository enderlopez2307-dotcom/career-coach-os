---
description: Finds 2-3 peer-level people at a company and drafts a research-backed note to each, into the queue.
---

**Agent:** `coach` · runs in this session.
**Usage:** `/network-outreach <Company>`

## Task
1. `WebSearch` for people at the company in roles adjacent to the
   candidate's target function — peers, not just the hiring manager `/warm-
   path` already checked.
2. For each, find one real, specific thing worth mentioning (a talk, a post,
   a project, a shared background) — never a generic "I saw you work at
   X."
3. Draft one short note per person, applying the two-fact rule and
   `config/voice.md`, and add each to the queue via the template in
   `CLAUDE.md`, status `needs review`, `Channel` set to wherever the person
   was actually found (email if you have one, linkedin otherwise) and
   `Draft ref` pointing at their profile URL or a new Gmail draft.
4. Log each contact in `vault/Tracking/Contacts.md` (Last Touch stays blank
   until `/review-queue` actually sends it).

## Rules
- Cap at 3 people per company per run, one unanswered thread per company at
  a time per the weekly caps in `coach.md`.
- Never send two similar messages to two people at the same company.
