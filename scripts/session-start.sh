#!/usr/bin/env bash
# SessionStart hook: tells Claude where this person is in their setup, so
# every session opens with the next step instead of a blank prompt.
#
# Plain file checks only. It never prints file contents, only fixed text, so
# nothing written into the vault by a fetched page can reach Claude this way.
# It exits quietly on any error and adds nothing to the unattended daily run.
[[ "${CAREERCOACHOS_SCHEDULED:-0}" == "1" ]] && exit 0
# On Windows, Claude Code runs hooks in Git Bash. The Windows checks (Task
# Scheduler, Windows paths) live in the PowerShell twin, so hand over to it.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$HERE/session-start.ps1")"
    ;;
esac
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT" 2>/dev/null || exit 0

say() { printf '%s\n' "$*"; }

if [[ ! -f config/profile.md ]]; then
  say "CareerCoachOS: this person has not run /onboard yet."
  say "Before anything else, greet them in two or three short lines: what CareerCoachOS does"
  say "(a private job search run by three agents: Coach, Scout and Signal), that nothing is ever"
  say "sent without their own click, and that setup is one conversation of about 20 minutes."
  say "Then ask if they are ready to start, and on yes run /onboard. If they asked something"
  say "else first, answer it, then offer /onboard."
  exit 0
fi

SETUP="vault/Automation/Setup.md"
step_open() {  # <label>: true while the step is neither done nor skipped
  [[ -f "$SETUP" ]] || return 0
  ! grep -Eiq "^- $1: (done|skipped|not on a mac)" "$SETUP"
}
OPEN=()
step_open "Dashboard" && OPEN+=("the Search Desk dashboard (/dashboard)")
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ ! -f "$HOME/Library/LaunchAgents/com.careercoachos.daily.plist" ]] && step_open "Daily schedule"; then
    OPEN+=("the daily morning scan (bash scripts/install-launchd.sh, Mac only)")
  fi
fi
step_open "Gmail" && OPEN+=("connecting Gmail so /jobs-mail can spot replies")
step_open "Tour" && OPEN+=("the two-minute command tour (ask: give me the tour)")

# Days since anything in the vault changed: a long gap means they drifted off.
IDLE=""
NEWEST="$(find vault -type f -name '*.md' -newer config/profile.md 2>/dev/null | head -1)"
if [[ -n "$NEWEST" ]]; then
  LAST="$(find vault -type f -name '*.md' -exec stat -f %m {} + 2>/dev/null | sort -n | tail -1)"
  [[ -z "$LAST" ]] && LAST="$(find vault -type f -name '*.md' -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)"
  [[ -n "$LAST" ]] && IDLE=$(( ( $(date +%s) - LAST ) / 86400 ))
fi

say "CareerCoachOS session start. Open your first reply with a short orientation, before or"
say "alongside answering whatever they asked:"
if (( ${#OPEN[@]} > 0 )); then
  say "- Setup is not finished. Still open: $(IFS=';'; echo "${OPEN[*]}" | sed 's/;/; /g')."
  say "  Offer the first one in one line and do it on a yes. Record each step as done or skipped"
  say "  in $SETUP (create it from the /onboard template if missing) so this list shrinks."
fi
if [[ -n "$IDLE" ]] && (( IDLE >= 4 )); then
  say "- Nothing in the vault has changed for $IDLE days. Welcome them back warmly, no guilt,"
  say "  and offer /checkin (what happened while you were away?) then /whats-next."
else
  say "- If they have no specific request, offer /whats-next: the ranked menu of best next moves."
fi
if [[ -f config/dashboard.json ]]; then
  say "- They have a Search Desk (URL in config/dashboard.json). Before ending a turn in which"
  say "  the pipeline changed, run the /dashboard sync so the page stays current."
fi
exit 0
