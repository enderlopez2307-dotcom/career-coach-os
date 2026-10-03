#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.careercoachos.daily"
DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

# launchd starts jobs with a bare PATH that does not include where Claude
# Code is installed, so record its full path now, while your shell can see it.
CLAUDE_BIN="$(command -v claude || true)"
if [[ -z "$CLAUDE_BIN" ]]; then
  echo "Could not find the claude command. Install Claude Code first, then run this again."
  exit 1
fi
CLAUDE_DIR="$(dirname "$CLAUDE_BIN")"
case "$ROOT$CLAUDE_BIN" in
  *[\|\&\<\>\"\\]*) echo "A folder path contains one of | & < > \" \\ . Move the folder and try again."; exit 1 ;;
esac

mkdir -p "$HOME/Library/LaunchAgents" "$ROOT/logs"
# Render and check in a temp file first, so a bad render never replaces a
# working schedule.
TMP_PLIST="$(mktemp -t careercoachos-plist)"
sed -e "s|REPO_ROOT|$ROOT|g" -e "s|CLAUDE_BIN_PATH|$CLAUDE_BIN|g" -e "s|CLAUDE_DIR|$CLAUDE_DIR|g" \
  "$ROOT/scripts/launchd/$LABEL.plist.template" > "$TMP_PLIST"
plutil -lint "$TMP_PLIST" >/dev/null || { echo "The generated schedule file is invalid, nothing installed."; rm -f "$TMP_PLIST"; exit 1; }
mv "$TMP_PLIST" "$DEST"
chmod 644 "$DEST"

launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"

echo "Installed. Runs daily at 07:30 while your Mac is awake."
echo "Logs land in $ROOT/logs/"
echo "Test right now without waiting for the schedule:"
echo "  bash $ROOT/scripts/run-daily.sh"
echo "Uninstall any time:"
echo "  launchctl unload $DEST && rm $DEST"
