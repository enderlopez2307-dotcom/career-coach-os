---
description: A tailored cover letter for one specific role, built from real research and the candidate's actual voice, queued for review.
---

**Agent:** `coach` · runs in this session.
**Usage:** `/jobs-cover <Company> <Role>`

## Task
1. Pull the company research and opportunity note (research first if
   missing).
2. Pick one to two wins from `config/wins.md` that best match this specific
   role, not the most impressive wins in general.
3. Write it: a hook or a real observation about the company, not a
   greeting; the match, grounded in the actual wins; one honest line if
   there's a real gap, per `config/voice.md`'s honesty guardrails; a plain
   close.
4. Run `/voice-check` on the draft before it's queued.
5. Add to `vault/Outreach Drafts/_queue.md`, status `needs review`,
   `Channel: email`, `Draft ref` set to a new Gmail draft's link — cover
   letters go through the same door as everything else.
