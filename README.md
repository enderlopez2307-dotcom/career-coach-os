# CareerCoachOS

A job search run by three Claude Code agents that share one folder of notes on your own computer.
Your CV, your LinkedIn, interview prep, job scouting and outreach drafts, all in one place, all
yours.

It is built to be installed by **your own AI agent**, or by you in about ten minutes. Give an agent
this repository and one sentence:

> Clone this repository and follow `INSTALL.md` to set up CareerCoachOS for me.

Spanish speaker? Read `INSTALL.es.md`.

## The three agents

- **Coach** is the judgment. It helps with your CV and LinkedIn story, interview prep, mock
  interviews, your library of stories, drafting messages and cover letters, and a daily read on
  where your search really stands. It can read your Gmail for recruiter replies and can create a
  Gmail draft. It cannot send anything.
- **Scout** is the crawler. It scans the careers pages of the companies you care about, checks that
  each posting is still live, reads the real requirements and scores the role against what you told
  it you want.
- **Signal** is the market analyst. It watches funding rounds, new executives, new teams and
  renamed job titles, so you hear about a door opening before the posting appears.

## Who it is for

Anyone looking for work, in any field, at any level. A nurse, a teacher, a designer, a fraud
analyst, someone changing careers. Nothing in it assumes a field. The first thing it does is
interview you about yours.

## What it never does

- It never sends an email or a message. It writes drafts, and you decide.
- It never clicks send, submit, post or apply. That click is always yours.
- No agent has a tool that sends. The Gmail rule is built into what the agents are allowed to
  touch, not just a rule they are asked to follow.

You see every drafted message in `/review-queue`, one at a time, and approve, edit or kill each
one.

## Requirements

- A Claude subscription that includes Claude Code (Pro or higher).
- Claude Code installed.
- macOS if you want the optional daily scheduler. Everything else works anywhere Claude Code runs.

## Quick start

```bash
git clone https://github.com/enderlopez2307-dotcom/career-coach-os.git CareerCoachOS
cd CareerCoachOS
claude
```

Then, inside Claude Code, run this once:

```
/onboard
```

It is a real conversation about your career, your targets and a few genuine wins. It writes four
private files under `config/`. After that, use the daily commands below. Full steps are in
`INSTALL.md`.

## Commands

Daily use:

- `/jobs-daily` runs Scout and Signal in parallel, then Coach drafts into your review queue and
  writes a daily digest.
- `/whats-next` sweeps your whole pipeline and gives you a ranked menu of the best next moves. You
  pick one and do it together.
- `/checkin` records what happened, ages every thread against reality and refreshes your
  dashboard.
- `/jobs-mail` checks your Gmail while you are in the session: recruiter replies, interview
  invites and rejections go into your notes, and replies are drafted. The scheduler never reads
  your mail.
- `/review-queue` is where drafted messages wait for you. It shows each one and stages approved
  ones in Gmail Drafts or the LinkedIn compose box. You press send yourself.

Finding and researching:

- `/jobs-scout` scans your target companies' careers pages, verifies each promising posting is
  live and logs the strong ones.
- `/market-pulse` scans your target companies for funding, leadership moves and renamed roles.
- `/jobs-research` writes a research brief on one company before you talk to anyone there.
- `/warm-path` answers one question before you apply: who do you know, or can reach, at this
  company.

Preparing:

- `/jobs-prep` builds an interview prep brief for one company, role and stage.
- `/mock-interview` has Coach play the interviewer for one round, then scores your answers
  honestly.
- `/jobs-cover` writes a tailored cover letter for one role, in your voice, and queues it.

Reaching out:

- `/draft-message` drafts a reply, a nudge, a thank you or a cold note and adds it to the queue.
- `/network-outreach` finds two or three peers at a company and drafts a researched note to each.
- `/voice-check` scans a draft for AI tells and returns pass, rewrite or do not send.

Learning from the process:

- `/postmortem` classifies a rejection, withdrawal or silence and names the real fix.
- `/profile` deepens your wins library and voice profile over time.
- `/onboard` first run setup. Run it again whenever your targets change.

## Privacy

Everything lives in the folder you downloaded, on your computer. Your job search is private by
default: your profile, your notes, your companies, your contacts and your drafts are all listed in
`.gitignore`, so even if you put this folder in a Git repository and commit, none of it is
included. Nothing is uploaded by this project.

Claude Code itself sends your prompts and the files it reads to Anthropic to do its work, under
your own Claude account and its terms. If you connect Gmail, Coach reads your mail through that
connection. Read Anthropic's privacy terms if that matters to you.

## Before you use this

This is a personal project, written by one person with AI assistance and shared because it turned
out to be useful. It is not a product and there is no company behind it. Please read this before
you rely on it.

- **No human has security reviewed this.** `SECURITY.md` describes the design, but a design is not
  an audit. The protections are real, and they have not been tested by a stranger trying to break
  them.
- **It has been used on one person's search.** Your field, your country or your job boards may
  behave differently. Scout reads company careers pages directly, and some sites block that.
- **Agents make mistakes.** Scores, research and drafts can be wrong. Check a posting yourself
  before you apply and read every draft before you send it. That is what the review queue is for.
- **The daily scheduler is optional and advanced.** It runs Claude unattended on your Mac. Read
  `SECURITY.md` before you turn it on.
- **Fetched web pages can try to give instructions to an agent.** The design treats everything
  fetched as data, but no defence is perfect.

It is MIT licensed and comes with no warranty of any kind.

## Layout

```
.claude/agents/     coach.md, scout.md, signal.md
.claude/commands/   the 18 commands above
config/             templates for your four private files (your real ones are gitignored)
vault/              your notes: companies, drafts, dashboard (all gitignored except templates)
templates/vault/    blank starting copies of the dashboard, strategy, tracking and queue files
scripts/            the optional daily scheduler and its macOS installer
CLAUDE.md           the rules every agent follows
```
