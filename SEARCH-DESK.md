# Search Desk

A live, good-looking dashboard for your CareerCoachOS job search. It's a
private Claude artifact you open in your browser, like any web page. It has
five tabs:

- **Today:** your next moves as a checklist you can tick, Coach's read on
  where things stand, a few numbers at a glance, and the latest morning scan.
- **Pipeline:** every role as a card, with a journey through each round
  (the current one glows), the next step with a countdown, your contact, and
  links to your prep docs.
- **Prep:** what to focus on for the next round, a chart of your mock
  interview scores, your prep docs, and a "never say" list.
- **Market:** signals from the daily scan, each marked Confirmed, Reported
  or Unverified, with links to the source, so you know what's safe to repeat.
- **Scan logs:** every morning scan, filed by month, with each role it
  checked and a link to the posting.

The design is called **Dawn**: a slowly drifting soft colour field behind
frosted glass panels, with a serif greeting that changes with the time of
day.

## How it works

The page and your data are kept apart:

- **The page** is a Claude artifact: an HTML file hosted privately on
  claude.ai. Only you can open the link unless you share it.
- **Your data** lives in the artifact's own small database, not in the page
  code. Claude reads and writes it with its artifact data tool, and you can
  tick moves off on the page, which saves straight away.

So Claude keeps it current during your CareerCoachOS chats, and you never
have to edit the page yourself.

**One thing to know:** the scheduled morning scan (`scripts/run-daily.sh`)
can't update the dashboard on its own. That run is locked down on purpose:
no connectors and no tools beyond reading the web and writing to `vault/`.
So the dashboard refreshes when you open a chat and ask for it. It also syncs at the end of
`/checkin`, `/jobs-mail`, `/whats-next` and `/postmortem`, and you can ask
any time: type `/dashboard` or say **"update my Search Desk"**.

## Set it up

You don't have to. `/onboard` builds it for you in its second half, right
after your first market scan, and opens it in your browser. Bookmark it.

If you onboarded before the dashboard was part of setup, or skipped it,
type `/dashboard` in a session in your CareerCoachOS folder. It publishes
the page from `templates/search-desk.html`, saves the link to
`config/dashboard.json` (private, never committed), fills it from your
vault and opens it.

You need Claude Code in the Claude desktop app (Code tab) or on claude.ai,
signed in to an account that can publish artifacts. In an app without
artifacts, `vault/Dashboard.md` is your dashboard: the same facts as plain
text.

## The data model

Everything is plain JSON documents. Dates are `YYYY-MM-DD`.

| Path | What it holds |
|---|---|
| `meta/summary` | `name` (first name for the greeting), `updatedAt`, `headline` (one line under the greeting), `read` (Coach's read, 2 to 4 sentences), `scanDate`, `scanNew` (number of new verified roles), `scanSummary`, `coverage` (what the last scan couldn't reach) |
| `meta/mocks` | `points`: a list of `{label, date, score}`, score out of 10 |
| `meta/prep` | `title`, `focus`: a list of `{title, items: [..]}`, `docs`: a list of `{company, current, label, url, note}` (https links only; `current: true` for the next round's docs, older ones fold away), `never`: a list of phrases to avoid |
| `pipeline/<id>` | `order`, `caseId` (short code like `ACME-PM`), `company`, `role`, `status` (`interview` a round is booked, `next` passed a round and the next isn't booked, `live`, `waiting` applied with no reply, `watch`, `offer`, or `closed` plus a `closedReason`), `score` (fit out of 10), `stages` (round names in order), `stageNotes` (who and when for each stage, same order), `stagesDone` (how many are finished), `roundsPassed`, `nextStep`, `nextDate`, `contact`, `timeline`: a list of `{date, text}` newest first, `links`: a list of `{label, url}` |
| `actions/<id>` | `order`, `title`, `detail`, `due` (a date) or `when` (free text like "Next week"), `tag` (usually the company), `done`. The page sets `done` and `doneAt` when you tick it |
| `signals/<id>` | `order`, `title`, `text`, `confidence` (`confirmed`, `reported` or `unverified`), `date`, `links`: a list of `{label, url, date}` for the sources |
| `scanlogs/<date>` | `date`, `trigger`, `newRoles`, `headline`, `summary`, `roles`: a list of `{company, role, score, url, note, verified}`, `coverage`, `read`. No market news here; that lives on the Market tab |

A role's journey shows `stages` top to bottom. The first `stagesDone`
stages show as finished, and the next one glows as current.

Due dates colour themselves: amber when they're 3 days away or less, red
once they're overdue.

### Example seed

These are made-up examples to show the shape. Replace them with your own
data.

```json
{
  "meta/summary": {"name": "Sam", "updatedAt": "2026-01-15", "headline": "Final round booked for Thursday.", "read": "Your strongest story is the payments fraud work. Lead with the number, then stop.", "scanDate": "2026-01-15", "scanNew": 1, "scanSummary": "One new verified role at Example Co.", "coverage": "Two boards didn't load this run."},
  "meta/mocks": {"points": [{"label": "Mon", "date": "2026-01-12", "score": 6.5}, {"label": "Wed", "date": "2026-01-14", "score": 8}]},
  "pipeline/acme": {"order": 1, "caseId": "ACME-PM", "company": "Acme", "role": "Risk Product Manager", "status": "live", "score": 8, "stages": ["Screen", "Hiring manager", "Final", "Offer"], "stageNotes": ["Recruiter · 6 Jan", "Hiring manager · 9 Jan", "Booked for 16 Jan", ""], "stagesDone": 2, "roundsPassed": 2, "nextStep": "Final round, panel of three", "nextDate": "2026-01-16", "contact": "Recruiter: Alex", "timeline": [{"date": "2026-01-09", "text": "Hiring manager round. Went well."}], "links": []},
  "actions/a1": {"order": 1, "title": "Prep the final round", "detail": "Two stories with numbers, three questions to ask.", "due": "2026-01-15", "tag": "Acme", "done": false},
  "signals/s1": {"order": 1, "title": "Acme raised a Series C", "text": "Expect hiring in risk and ops.", "confidence": "reported", "date": "2026-01-14"}
}
```

## Changing the look

All colours sit as tokens at the top of `templates/search-desk.html`'s `<style>`: `--sage`,
`--peach`, `--sky` and `--lilac` for the background field, `--green` for
done and on-track, `--ember` for the current stage and anything due soon,
and `--rose` for overdue. Ask Claude to change them, or the fonts
(Instrument Serif for headings, DM Sans for text), and republish to the
same URL. Your data stays where it is.

Want a completely different style? Ask Claude for a few design prototypes
using your real data first, then pick one. That's how Dawn was chosen.

## Privacy

- The artifact is **private by default**. Only you can open it.
- Anyone you share the link with can see everything in it, so keep out what
  you wouldn't show a friend: your comp floor and salary figures, health or
  legal matters, and anything in `config/` you keep off GitHub.
- The data never goes into your git repo. It lives in the artifact.
- Rows you tick on the page are just data. Claude treats what it reads back
  as data, never as instructions.

## If something's off

- **"Open this page in Claude"** means the data couldn't load. Make sure
  you're signed in to claude.ai in that browser.
- **Old information:** ask Claude to "update my Search Desk". The morning
  scan doesn't update it on its own.
- **A tick didn't save:** you're probably viewing a copy someone shared
  with you as a viewer. Only the owner and editors can save.
