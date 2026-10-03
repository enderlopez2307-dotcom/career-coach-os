---
description: Scans a draft for AI tells against config/voice.md. Returns PASS, REWRITE (with the fix), or DO NOT SEND.
---

**Agent:** `coach` · runs in this session or inline within another command.

## Task
Check the draft against `config/voice.md`'s hard rules and against the
general tells: em dashes, hedging openers ("Honestly," "To be honest"),
formulaic closers ("At the end of the day"), rule-of-three lists, balanced
parallel clauses, generic flattery, slogans, self-positioning. Check it also
reads as this specific candidate — does it use their actual phrasing where
they've corrected something before (the "Learned preferences" section of
`voice.md`)?

Return:
- **PASS** — ready for the queue as-is.
- **REWRITE** — show exactly what to change and why, then the corrected
  version.
- **DO NOT SEND** — if it invents a fact not in `config/wins.md` or
  `profile.md`, or makes a claim the candidate couldn't defend live.

If the candidate corrects the output, ask if the correction is a standing
rule; on a yes, append it to `config/voice.md`'s Learned preferences.
