#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p "$ROOT/logs"

LOG="$ROOT/logs/run-$(date +%Y-%m-%d).log"
echo "$(date -Iseconds)  start" >> "$LOG"

# launchd runs with a bare PATH, so install-launchd.sh writes CLAUDE_BIN into
# the plist. Running by hand, `command -v` finds it on your normal PATH.
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || true)}"
if [[ -z "$CLAUDE_BIN" || ! -x "$CLAUDE_BIN" ]]; then
  echo "$(date -Iseconds)  failed: claude CLI not found (set CLAUDE_BIN)" >> "$LOG"
  exit 127
fi

TIMEOUT_SEC="${CAREERCOACHOS_TIMEOUT_SEC:-1800}"
if ! [[ "$TIMEOUT_SEC" =~ ^[1-9][0-9]*$ ]]; then
  echo "$(date -Iseconds)  failed: CAREERCOACHOS_TIMEOUT_SEC must be whole seconds, got '$TIMEOUT_SEC'" >> "$LOG"
  exit 2
fi

# macOS ships no `timeout` command. This perl wrapper does the same job: the
# run gets its own process group, and when the cap is hit the whole group is
# stopped (TERM, then KILL after 10 s), so no helper process is left behind.
# Exit 142 means the cap was hit.
run_capped() {
  perl -e '
    my $t = shift;
    my $pid = fork() // die "fork failed: $!";
    if ($pid == 0) { setpgrp(0, 0); exec @ARGV or die "exec failed: $!"; }
    $SIG{ALRM} = sub { kill "TERM", -$pid; sleep 10; kill "KILL", -$pid; exit 142; };
    alarm $t;
    waitpid($pid, 0);
    exit(($? & 127) ? 128 + ($? & 127) : $? >> 8);
  ' "$TIMEOUT_SEC" "$@"
}

# The scheduled run. It reads job pages written by strangers, so it gets
# only what it needs, enforced by Claude Code rather than by instructions:
#   --tools               no Bash or other code-running tool exists at all
#   --strict-mcp-config   no connectors load: no Gmail, no browser, nothing
#                         that sends, whatever you have linked to your account
#   dontAsk + allowlist   anything not listed is denied, in subagents too.
#                         Reads stay inside this folder, writes stay inside
#                         vault/ (Edit rules cover Write as well), so a
#                         poisoned page cannot rewrite .git/config, this
#                         script, CLAUDE.md or a command file.
# Never go back to --dangerously-skip-permissions: it approves every write,
# anywhere on your disk.
set +e
run_capped "$CLAUDE_BIN" -p "/jobs-daily" \
  --tools "Agent,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch" \
  --strict-mcp-config \
  --permission-mode dontAsk \
  --allowedTools "Agent,WebFetch,WebSearch,Read(./**),Edit(vault/**)" \
  < /dev/null >> "$LOG" 2>&1
ec=$?
set -e

if [[ "$ec" -ne 0 ]]; then
  echo "$(date -Iseconds)  claude run failed (exit $ec)" >> "$LOG"
  exit "$ec"
fi

# Mail is never read unattended. /jobs-mail runs only in a session you are in.

# Git sync: commits and pushes vault/, which is your whole job search. Only
# for a PRIVATE repository, and OFF unless you set CAREERCOACHOS_GIT_SYNC=1.
# vault/ is gitignored in this copy, so you would also have to edit
# .gitignore on purpose. Never enable it in a public repository. Git runs with hooks and fsmonitor switched off so
# nothing written into the repo can make git execute a command.
GIT=(git -c core.hooksPath=/dev/null -c core.fsmonitor=false)
cd "$ROOT"
if [[ "${CAREERCOACHOS_GIT_SYNC:-0}" == "1" ]]; then
  if [[ -n "$("${GIT[@]}" status --porcelain -- vault)" ]]; then
    "${GIT[@]}" add vault
    "${GIT[@]}" commit -m "Daily scan $(date +%Y-%m-%d)" -q
    if [[ "${CAREERCOACHOS_NO_PUSH:-0}" != "1" ]]; then
      "${GIT[@]}" push -q origin "$("${GIT[@]}" rev-parse --abbrev-ref HEAD)"
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
