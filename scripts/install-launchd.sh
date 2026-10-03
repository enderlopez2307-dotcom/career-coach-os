#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.careercoachos.daily"
DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

mkdir -p "$HOME/Library/LaunchAgents" "$ROOT/logs"
sed "s|REPO_ROOT|$ROOT|g" "$ROOT/scripts/launchd/$LABEL.plist.template" > "$DEST"
chmod 644 "$DEST"

launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"

echo "Installed. Runs daily at 07:30 while your Mac is awake."
echo "Logs land in $ROOT/logs/"
echo "Test right now without waiting for the schedule:"
echo "  bash $ROOT/scripts/run-daily.sh"
echo "Uninstall any time:"
echo "  launchctl unload $DEST && rm $DEST"
