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
# Always start it in the background with & : it execs, so the background
# job's PID is the wrapper itself and a forwarded signal reaches it.
run_capped() {
  exec perl -e '
    my $t = shift;
    my $pid = fork() // die "fork failed: $!";
    if ($pid == 0) { setpgrp(0, 0); exec @ARGV or die "exec failed: $!"; }
    my $stop = sub { my $code = shift; kill "TERM", -$pid; sleep 10; kill "KILL", -$pid; exit $code; };
    $SIG{ALRM} = sub { $stop->(142) };
    # Ctrl-C or launchctl stopping this wrapper must stop claude too, or it
    # would keep running in its own process group with no cap.
    $SIG{INT}  = sub { $stop->(130) };
    $SIG{TERM} = sub { $stop->(143) };
    $SIG{HUP}  = sub { $stop->(129) };
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
#   --setting-sources     your user-level settings (extra folders, rules)
#                         do not load; only this project's
#   dontAsk + allowlist   anything not listed is denied, in subagents too.
#                         Reads stay inside this folder, writes stay inside
#                         vault/ and only to .md files (Edit rules cover Write), so a
#                         poisoned page cannot rewrite .git/config, this
#                         script, CLAUDE.md or a command file.
#   --disallowedTools     no reading .git/, logs/ or settings files (where a
#                         token could sit), and no CLAUDE.md or .claude/ file
#                         anywhere in vault/, which a later session you run
#                         would otherwise load as trusted instructions.
# Never go back to --dangerously-skip-permissions: it approves every write,
# anywhere on your disk.
set +e
run_capped "$CLAUDE_BIN" -p "/jobs-daily" \
  --tools "Agent,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch" \
  --strict-mcp-config \
  --permission-mode dontAsk \
  --setting-sources project \
  --allowedTools "Agent,WebFetch,WebSearch,Read(./**),Edit(vault/**/*.md)" \
  --disallowedTools "Read(.git/**),Read(logs/**),Read(.claude/settings*.json),Read(**/.env*),Edit(**/CLAUDE.md),Edit(**/CLAUDE.local.md),Edit(**/.claude/**)" \
  < /dev/null >> "$LOG" 2>&1 &
CAP=$!
# launchctl stop signals this bash script, not the wrapper; pass it on so the
# wrapper can stop claude's whole process group before launchd gives up.
trap 'kill -TERM "$CAP" 2>/dev/null' TERM INT HUP
wait "$CAP"; ec=$?
while kill -0 "$CAP" 2>/dev/null; do wait "$CAP"; ec=$?; done
trap - TERM INT HUP
set -e

# Mail is never read unattended. /jobs-mail runs only in a session you are in.

# Belt and braces: if an instruction file, a .claude folder or git plumbing
# turned up in vault/ anyway (any letter case: Mac disks treat .Claude and
# .claude as the same folder, while the deny rules above match case
# exactly), pack it out of vault/ into a sealed archive, log it, and stop
# before git or any later session can load it.
QDIR="$ROOT/logs/quarantine-$(date +%Y%m%d-%H%M%S)"
FOUND=0
while IFS= read -r -d '' f; do
  [[ -e "$f" ]] || continue  # already moved with a parent folder
  mkdir -p "$QDIR"
  # Pack it into a single archive so no file inside keeps a name Claude Code
  # would load (a CLAUDE.md inside a quarantined .claude folder, say), then
  # remove the original. Nothing is lost: the archive holds it all.
  tar -czf "$QDIR/$(printf '%s' "${f#"$ROOT"/}" | tr '/ ' '__').quarantined.tgz" \
    -C "$(dirname "$f")" "$(basename "$f")" && rm -rf -- "$f"
  echo "$(date -Iseconds)  quarantined: ${f#"$ROOT"/}" >> "$LOG"
  FOUND=1
done < <(find "$ROOT/vault" \( -iname 'CLAUDE*.md' -o -iname '.claude' -o -iname '.git' -o -iname '.gitmodules' -o -iname '.gitattributes' \) -print0 2>/dev/null)
if [[ "$FOUND" == "1" ]]; then
  echo "$(date -Iseconds)  STOPPED: unexpected instruction or git files were in vault/, moved to $QDIR, nothing committed" >> "$LOG"
  exit 3
fi

# The sweep above runs even when claude failed, timed out or was stopped, so
# a half-finished run cannot leave a planted file behind. Only now give up on
# a failed run, before git.
if [[ "$ec" -ne 0 ]]; then
  echo "$(date -Iseconds)  claude run failed (exit $ec), nothing committed" >> "$LOG"
  exit "$ec"
fi

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
    "${GIT[@]}" commit -m "Daily scan $(date +%Y-%m-%d)" -q -- vault
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
