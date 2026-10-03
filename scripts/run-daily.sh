#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p "$ROOT/logs"

LOG="$ROOT/logs/run-$(date +%Y-%m-%d).log"
echo "$(date -Iseconds)  start" >> "$LOG"

CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || true)}"
if [[ -z "$CLAUDE_BIN" || ! -x "$CLAUDE_BIN" ]]; then
  echo "$(date -Iseconds)  failed: claude CLI not found (set CLAUDE_BIN)" >> "$LOG"
  exit 127
fi

# macOS ships no `timeout` command, so cap each pass with perl's alarm
# (perl is on every Mac). Exit 142 means the cap was hit.
TIMEOUT_SEC="${CAREERCOACHOS_TIMEOUT_SEC:-1800}"
run_capped() { perl -e 'alarm shift; exec @ARGV or die "exec failed: $!"' "$TIMEOUT_SEC" "$@"; }

# The scheduled run: Scout and Signal read job pages from strangers. --tools gives
# this session no Bash, and --strict-mcp-config loads no connectors, so it
# has no Gmail and nothing that sends. Never swap --tools for --allowedTools
# here: with --dangerously-skip-permissions that would auto-approve every
# connector you have linked.
set +e
run_capped "$CLAUDE_BIN" -p "/jobs-daily" \
  --tools "Agent,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch" \
  --strict-mcp-config \
  --dangerously-skip-permissions \
  < /dev/null >> "$LOG" 2>&1
ec=$?
set -e

if [[ "$ec" -ne 0 ]]; then
  echo "$(date -Iseconds)  claude run failed (exit $ec)" >> "$LOG"
  exit "$ec"
fi

# Mail is never read unattended. /jobs-mail runs only in a session you are in.

# Optional git sync. OFF by default. It exists only for people who keep this
# folder in a PRIVATE repository: it commits and pushes vault/, which is your
# whole job search. Never enable it in a public repository. vault/ is
# gitignored in this copy, so you would also have to edit .gitignore on purpose.
cd "$ROOT"
if [[ "${CAREERCOACHOS_GIT_SYNC:-0}" == "1" ]]; then
  if [[ -n "$(git status --porcelain -- vault)" ]]; then
    git add vault
    git commit -m "Daily scan $(date +%Y-%m-%d)" -q
    if [[ "${CAREERCOACHOS_NO_PUSH:-0}" != "1" ]]; then
      git push -q origin "$(git rev-parse --abbrev-ref HEAD)"
      echo "$(date -Iseconds)  committed and pushed" >> "$LOG"
    else
      echo "$(date -Iseconds)  committed (push skipped, CAREERCOACHOS_NO_PUSH=1)" >> "$LOG"
    fi
  else
    echo "$(date -Iseconds)  nothing new to commit" >> "$LOG"
  fi
else
  echo "$(date -Iseconds)  git sync off (CAREERCOACHOS_GIT_SYNC=1 enables it, private repo only)" >> "$LOG"
fi

echo "$(date -Iseconds)  done" >> "$LOG"
