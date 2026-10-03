# Install CareerCoachOS

Works wherever you use Claude Code: the Claude desktop app, VS Code, or a terminal.

## What you need first

- A Claude plan that includes Claude Code (Pro or higher). The free plan does not.
- Claude Code in any app. If you have none yet, the simplest is the **Claude desktop app**: download
  it from https://claude.com/download, sign in, and open the **Code** tab. It already includes
  Claude Code.

## The easy way: ask your agent

**1. Paste one sentence.** Open a Claude Code session anywhere (in the desktop app: Code tab,
Local, Select folder, and pick your Documents folder) and send:

> Install CareerCoachOS for me: read https://raw.githubusercontent.com/enderlopez2307-dotcom/career-coach-os/main/AGENT_INSTALL.md and follow it.

The agent downloads CareerCoachOS into a new `CareerCoachOS` folder in your Documents and tells you
what to do next. It runs no scripts and connects nothing.

**2. Open a fresh session on the new folder.** This step matters: CareerCoachOS's commands only
load in a session started inside its folder.

- **Claude desktop app:** Code tab, new session, Local, Select folder, pick `CareerCoachOS`.
  Setting the permission mode to Accept edits saves you approving every note the Coach writes.
- **VS Code:** File, Open Folder, pick `CareerCoachOS`, then open the Claude Code panel.
- **Terminal:** `cd ~/Documents/CareerCoachOS` on a Mac, or in Windows PowerShell
  `cd (Join-Path ([Environment]::GetFolderPath('MyDocuments')) CareerCoachOS)` (that finds
  Documents even when it lives inside OneDrive), then `claude`.

**3. Type `/onboard`.** See "Your first session" below.

## By hand, without an agent

1. On the repository page, click the green **Code** button, then **Download ZIP**.
2. Unpack it, rename the folder from `career-coach-os-main` to `CareerCoachOS`, and move it into
   your Documents folder.
3. Open a fresh session on that folder, as in step 2 above, and type `/onboard`.

## Your first session

`/onboard` is a real conversation. Coach interviews you, one question at a time: your current work,
the roles you want, the salary below which a role is not worth discussing, where you will and will
not work, companies to avoid, target companies, a few real wins with numbers, and a paragraph of
your own writing so drafts sound like you. It writes four private files in `config/`. Answer
honestly. It will not invent answers you did not give. You can write in any language; commands
stay in English.

After that, the daily commands:

```
/whats-next      a ranked menu of the best next moves
/jobs-daily      scan the market and draft into your review queue
/jobs-mail       check Gmail for replies and invites (only while you are there)
/checkin         record what happened and refresh your dashboard
/review-queue    look at each drafted message, approve it or kill it
```

Before you apply anywhere, run `/warm-path <Company>`. Before an interview, run `/jobs-prep`, then
`/mock-interview`.

## Things to know

- Nothing is ever sent for you. Approved messages wait in Gmail Drafts or in the LinkedIn message
  box. You press send.
- Your job search stays in this folder. It is ignored by Git by default.
- To use `/jobs-mail`, connect Gmail in your Claude app's connector settings. Everything else works
  without it.
- The daily scheduler is optional, Mac only, and runs from a terminal. Read `SECURITY.md` first.
  To turn it on, run `bash scripts/install-launchd.sh` inside the folder.
- Stuck? Ask Claude in plain words, for example "I downloaded the folder, what do I do next?"
