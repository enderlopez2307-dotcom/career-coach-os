---
description: Classifies a loss (rejection, withdrawal, or silence), logs it to the Strategy objection log, and names the actual fix.
---

**Agent:** `coach` · runs in this session.
**Usage:** `/postmortem <Company>`

## Task
1. Pull the full timeline from the opportunity note.
2. Classify honestly: comp mismatch, seniority mismatch, a specific skill
   gap, a weak answer in a specific round, timing, or genuinely unknown.
   Don't default to "unknown" when the timeline gives a real signal.
3. Add one row to `vault/Strategy.md`'s objection log: date, company,
   stage reached, classification, the specific evidence.
4. Check the log for a pattern: the same classification three times is a
   positioning problem, not bad luck — say so plainly, and name the one
   concrete fix (a wins.md story to sharpen, a rubric weight that's off, a
   round that needs more prep).
5. Move the opportunity note's stage to `Closed`.

## Rules
- If `config/dashboard.json` exists, finish by running the `/dashboard` sync, so the Search Desk shows what just changed.
