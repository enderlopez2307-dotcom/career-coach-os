---
description: The full daily routine. Market pulse and scout run in parallel, then a digest, then a consolidated Recruiter's read. This is what the scheduler runs unattended — it never reads mail, never sends or contacts anyone, it only researches, scores, and drafts into the queue.
---

**Agent:** orchestrator, closing as `coach` — read `.claude/agents/coach.md`
first.

## Task
1. **In parallel:**
   - `signal`: *"Read `.claude/commands/market-pulse.md` and execute its
     Task. Return the report."*
   - `scout`: *"Read `.claude/commands/jobs-scout.md` and execute its Task.
     Return the report."*
2. **Mail is not part of this run.** It never touches Gmail. Mail is read
   only by `/jobs-mail`, in a session the candidate is in. In an
   interactive run with Gmail connected, offer `/jobs-mail` after step 5.
3. **Coach drafts.** For anything from today's scan or pulse that is
   `Verified`, clears the profile's "act on it" score, AND has a human path
   (per the opportunity note's Key Contacts), draft one outreach message,
   run `/voice-check`, and
   add it to `vault/Outreach Drafts/_queue.md` as `needs review` with its
   `Channel` set — a scheduled run never marks its own work `ready`; that
   happens only when a human looks at it during `/review-queue`. For an
   email-channel draft, leave `Draft ref` empty: the next `/jobs-mail` or
   `/review-queue` turns it into a real Gmail draft. For a
   LinkedIn-channel draft, leave `Draft ref` as the target profile URL only
   — staging the actual message into a browser never happens during a
   scheduled run, only inside `/review-queue` with a human watching. An
   unverified role never reaches the queue, no matter how well it scored
   on the first pass.
4. **Consolidate** into `vault/Archive/Daily Scan/<today>.md`: market
   signals, new roles with human paths, pipeline changes, what's now
   queued. No mail section: this run does not read mail.
5. **One Recruiter's read**, covering market, pipeline, the queue, and the
   single most important move today.

## Rules
- Every filter in `config/profile.md` applies.
- If this run has no conversation available (the scheduler), it still does
  steps 1–5 in full — drafting is not gated on a human being present, only
  *sending* is, and that gate is structural (Coach has no send tool), not a
  behavioral rule that could be skipped under time pressure.
