# The Windows version of scripts/run-daily.sh: the same locked-down daily run.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run-daily.ps1
#
# scripts\install-task.ps1 schedules it for 07:30 with Task Scheduler. Read
# SECURITY.md first. Every guardrail matches the Mac script: no Bash, no MCP
# servers, writes only to vault\*.md, a time cap, and a sweep that pulls any
# planted instruction or git file out of vault\ before anything else runs.
param([string]$ClaudeBin = $env:CLAUDE_BIN)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
New-Item -ItemType Directory -Force -Path "$Root\logs" | Out-Null
$Log = "$Root\logs\run-$(Get-Date -Format yyyy-MM-dd).log"
function Log($msg) { Add-Content -Path $Log -Value "$(Get-Date -Format s)  $msg" }
Log 'start'

if (-not $ClaudeBin) {
    $cmd = Get-Command claude -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { $ClaudeBin = $cmd.Source }
}
if (-not $ClaudeBin -or -not (Test-Path $ClaudeBin)) {
    Log 'failed: claude CLI not found (pass -ClaudeBin or set CLAUDE_BIN)'
    exit 127
}

$TimeoutSec = 1800
if ($env:CAREERCOACHOS_TIMEOUT_SEC) {
    if ($env:CAREERCOACHOS_TIMEOUT_SEC -notmatch '^[1-9][0-9]*$') {
        Log "failed: CAREERCOACHOS_TIMEOUT_SEC must be whole seconds, got '$($env:CAREERCOACHOS_TIMEOUT_SEC)'"
        exit 2
    }
    $TimeoutSec = [int]$env:CAREERCOACHOS_TIMEOUT_SEC
}

# Job feeds first, plain code, no model. Windows often has a "python" that
# only opens the Microsoft Store, so each candidate must answer --version.
$Py = $null
foreach ($c in @(@('py', '-3'), @('python3'), @('python'))) {
    try {
        $extra = @($c | Select-Object -Skip 1)
        & $c[0] @extra --version *> $null
        if ($LASTEXITCODE -eq 0) { $Py = $c; break }
    } catch { }
}
if ($Py -and (Test-Path "$Root\config\feeds.json")) {
    $extra = @($Py | Select-Object -Skip 1)
    try {
        & $Py[0] @extra -I "$Root\scripts\fetch-feeds.py" *>> $Log
        if ($LASTEXITCODE -ne 0) { Log 'feed fetch failed, scan continues without it' }
    } catch { Log 'feed fetch failed, scan continues without it' }
} else {
    Log 'feed fetch skipped (no Python or no config\feeds.json)'
}

# Tells the session-start check this is the unattended run.
$env:CAREERCOACHOS_SCHEDULED = '1'
# Same flags as the Mac script; see the comments there for what each one does.
# Never go back to --dangerously-skip-permissions.
$ClaudeArgs = @(
    '-p', '/jobs-daily',
    '--tools', 'Agent,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch',
    '--strict-mcp-config',
    '--permission-mode', 'dontAsk',
    '--setting-sources', 'project',
    '--allowedTools', 'Agent,WebFetch,WebSearch,Read(./**),Edit(vault/**/*.md)',
    '--disallowedTools', 'Read(.git/**),Read(logs/**),Read(.claude/settings*.json),Read(**/.env*),Edit(**/CLAUDE.md),Edit(**/CLAUDE.local.md),Edit(**/.claude/**)'
)
$ArgLine = ($ClaudeArgs | ForEach-Object { '"' + $_ + '"' }) -join ' '
$Empty = "$Root\logs\.empty-stdin"
Set-Content -Path $Empty -Value '' -NoNewline
$Out = "$Root\logs\run-$(Get-Date -Format yyyy-MM-dd).claude.log"
$Err = "$Root\logs\run-$(Get-Date -Format yyyy-MM-dd).claude.err.log"
$ec = 0
try {
    $p = Start-Process -FilePath $ClaudeBin -ArgumentList $ArgLine -WorkingDirectory $Root `
        -RedirectStandardInput $Empty -RedirectStandardOutput $Out -RedirectStandardError $Err `
        -NoNewWindow -PassThru
    if (-not $p.WaitForExit($TimeoutSec * 1000)) {
        # The time cap: stop claude and everything it started.
        & taskkill.exe /PID $p.Id /T /F *> $null
        Log "time cap of $TimeoutSec s hit, run stopped"
        $ec = 142
    } else {
        $ec = $p.ExitCode
    }
} catch {
    Log "claude could not start: $($_.Exception.Message)"
    $ec = 1
}
$env:CAREERCOACHOS_SCHEDULED = $null

# Mail is never read unattended. /jobs-mail runs only in a session you are in.

# Belt and braces: pack any instruction file, .claude folder or git plumbing
# found in vault\ (any letter case) into a sealed archive, log it, and stop
# before git or any later session can load it. Runs even after a failed run.
$Bad = '^(CLAUDE.*\.md|\.claude|\.git|\.gitmodules|\.gitattributes)$'
$QDir = "$Root\logs\quarantine-$(Get-Date -Format yyyyMMdd-HHmmss)"
$Found = $false
$hits = @(Get-ChildItem -Path "$Root\vault" -Recurse -Force -ErrorAction SilentlyContinue |
          Where-Object { $_.Name -match $Bad } | Sort-Object { $_.FullName.Length })
foreach ($h in $hits) {
    if (-not (Test-Path -LiteralPath $h.FullName)) { continue }  # moved with a parent
    New-Item -ItemType Directory -Force -Path $QDir | Out-Null
    $rel = $h.FullName.Substring($Root.Length + 1)
    $zip = Join-Path $QDir (($rel -replace '[\\/ ]', '_') + '.quarantined.zip')
    Compress-Archive -LiteralPath $h.FullName -DestinationPath $zip -Force
    Remove-Item -LiteralPath $h.FullName -Recurse -Force
    Log "quarantined: $rel"
    $Found = $true
}
if ($Found) {
    Log "STOPPED: unexpected instruction or git files were in vault\, moved to $QDir, nothing committed"
    exit 3
}

if ($ec -ne 0) {
    Log "claude run failed (exit $ec), nothing committed"
    exit $ec
}

# Optional git sync, PRIVATE repositories only, off unless
# CAREERCOACHOS_GIT_SYNC=1. Hooks and fsmonitor are switched off so nothing
# written into the repo can make git run a command.
if ($env:CAREERCOACHOS_GIT_SYNC -eq '1') {
    $g = @('-c', 'core.hooksPath=NUL', '-c', 'core.fsmonitor=false')
    $changed = & git @g status --porcelain -- vault
    if ($changed) {
        & git @g add vault
        & git @g commit -q -m "Daily scan $(Get-Date -Format yyyy-MM-dd)" -- vault
        if ($env:CAREERCOACHOS_NO_PUSH -ne '1') {
            $branch = & git @g rev-parse --abbrev-ref HEAD
            & git @g push -q origin $branch
            Log 'committed and pushed'
        } else { Log 'committed (push skipped, CAREERCOACHOS_NO_PUSH=1)' }
    } else { Log 'nothing new to commit' }
} else {
    Log 'git sync off (CAREERCOACHOS_GIT_SYNC=1 enables it, private repo only)'
}
Log 'done'
