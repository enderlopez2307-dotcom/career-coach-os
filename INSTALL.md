# Install CareerCoachOS

This guide is written for someone who has never used a terminal. A terminal is a window where you
type a command and press Return, instead of clicking.

**Hand this to your agent.** If you already use an AI agent that can run commands, give it this
one sentence and skip the rest:

> Clone this repository and follow `INSTALL.md` to set up CareerCoachOS for me, then stop and tell
> me to run `/onboard`.

## What you need first

- A Claude subscription that includes Claude Code (Pro or higher).
- A computer. macOS is needed only for the optional daily scheduler.

## Steps

1. **Install Claude Code.** Go to the official Claude Code setup page at
   https://code.claude.com/docs/en/setup and follow the steps for your computer. When
   it is done, you can type `claude` in a terminal.

2. **Download CareerCoachOS.** Pick one of these.

   *Option A, Download ZIP.* On the repository page, click the green **Code** button, then
   **Download ZIP**. Open the downloaded file so it unpacks into a folder. Move that folder
   somewhere you will remember, such as your Documents folder, and rename it from
   `career-coach-os-main` to `CareerCoachOS`.

   *Option B, git clone.* If you already use Git, run this in a terminal:

   ```bash
   git clone https://github.com/enderlopez2307-dotcom/career-coach-os.git CareerCoachOS
   ```

3. **Open a terminal in that folder.**
   - On a Mac, open the Terminal app, type `cd ` (with a space after it), drag the CareerCoachOS
     folder into the Terminal window, and press Return.
   - Or type the path yourself, for example `cd ~/Documents/CareerCoachOS`.

4. **Start Claude Code.** Type this and press Return. The first time, it asks you to sign in with
   your Claude account.

   ```bash
   claude
   ```

5. **Run the setup conversation, once.** Inside Claude Code, type this and press Return:

   ```
   /onboard
   ```

   Coach interviews you, one question at a time: your current work, the roles you want, the
   salary below which a role is not worth discussing, where you will and will not work, companies
   to avoid, target companies, a few real wins with numbers, and a paragraph of your own writing
   so drafts sound like you. It writes four private files in `config/`. Answer honestly. It will
   not invent answers you did not give.

6. **Use the daily commands.**

   ```
   /jobs-daily      scan the market and draft into your review queue
   /jobs-mail       check Gmail for replies and invites (only while you are there)
   /whats-next      a ranked menu of the best next moves
   /checkin         record what happened and refresh your dashboard
   /review-queue    look at each drafted message, approve it or kill it
   ```

   Before you apply anywhere, run `/warm-path <Company>`. Before an interview, run `/jobs-prep`,
   then `/mock-interview`.

## Things to know

- Nothing is ever sent for you. Approved messages wait in Gmail Drafts or in the LinkedIn message
  box. You press send.
- Your job search stays in this folder. It is ignored by Git by default.
- To use Gmail features, connect Gmail inside Claude Code when it offers. Everything else works
  without it.
- The daily scheduler is optional and Mac only. Read `SECURITY.md` first. To turn it on, run
  `bash scripts/install-launchd.sh` in the folder.
- Stuck? Ask Claude Code in plain words, for example "I downloaded the ZIP, what do I type
  next?"
