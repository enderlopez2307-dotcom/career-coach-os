# Installing CareerCoachOS: instructions for an AI agent

You were asked to install CareerCoachOS for the person you are working with. Follow these steps in
order. They only download and place files. Nothing here runs a script, installs software, connects
an account or changes any setting.

## 1. Pick the folder

The default is a folder named `CareerCoachOS` inside the person's Documents folder:

- macOS: `~/Documents/CareerCoachOS`
- Windows: `CareerCoachOS` inside the real Documents folder, which on many PCs lives inside
  OneDrive. Get its path with PowerShell: `[Environment]::GetFolderPath('MyDocuments')`. Do not
  assume `%USERPROFILE%\Documents`.

If they asked for another place, use that. **If the folder already exists, stop and ask.** Never
overwrite or merge into it: it may already hold their job search.

## 2. Download

Use the first option that works.

**With git:**

```
git clone https://github.com/enderlopez2307-dotcom/career-coach-os.git "<folder>"
```

**Without git, macOS:**

```
T="$(mktemp -d)"
curl -fL -o "$T/cco.zip" https://github.com/enderlopez2307-dotcom/career-coach-os/archive/refs/heads/main.zip
unzip -q "$T/cco.zip" -d "$T"
mv "$T/career-coach-os-main" "<folder>"
```

**Without git, Windows PowerShell:**

```
$T = Join-Path $env:TEMP ("cco-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $T | Out-Null
Invoke-WebRequest -Uri https://github.com/enderlopez2307-dotcom/career-coach-os/archive/refs/heads/main.zip -OutFile "$T\cco.zip"
Expand-Archive -Path "$T\cco.zip" -DestinationPath $T
Move-Item "$T\career-coach-os-main" "<folder>"
```

Each run uses a new temporary folder, so a second attempt never trips over the first.

## 3. Check

The folder must contain `CLAUDE.md`, `README.md` and `.claude/commands/onboard.md`. If any is
missing, say so and stop.

## 4. Do not

- Do not run `/onboard` or any other CareerCoachOS command in this session. Its commands only load
  in a session started inside the CareerCoachOS folder, which this one is not.
- Do not create or fill anything in `config/` or `vault/`. That happens in `/onboard`, with the
  person answering for themselves.
- Do not install the daily scheduler, connect Gmail or any other account, or edit any file in the
  folder. Those are the person's choices, later.

## 5. Tell the person how to start

In their language, tell them the install is done and that the next step is a **fresh session
opened on the CareerCoachOS folder**. Give only the steps for the app they are using now:

- **Claude desktop app:** Code tab, start a new session, choose Local, click Select folder and pick
  `CareerCoachOS`. Setting the permission mode to Accept edits saves them approving every note the
  Coach writes.
- **VS Code:** File, Open Folder, pick `CareerCoachOS`, then open the Claude Code panel.
- **Terminal:** go into the folder (`cd` followed by the exact path you used in step 1) and run
  `claude`.

Then they type `/onboard`. It takes about 25 minutes: the Coach interviews them about their career,
one question at a time, in whatever language they write in, then sets up their dashboard, the daily
scan and Gmail with them. Tell them to stay for the second half; that is what makes it useful.

Also tell them, in one line each:

- CareerCoachOS needs a paid Claude plan that includes Claude Code (Pro or higher).
- It never sends an email or a message. It writes drafts, and they decide.
- `README.md` lists every command, and `SECURITY.md` explains what the agents can and cannot do.
