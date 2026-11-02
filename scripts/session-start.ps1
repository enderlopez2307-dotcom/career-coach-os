# Windows version of scripts/session-start.sh: tells Claude where this person
# is in their setup, so every session opens with the next step.
#
# Plain file checks only. It never prints file contents, only fixed text, so
# nothing written into the vault by a fetched page can reach Claude this way.
# It exits quietly on any error and adds nothing to the unattended daily run.
$ErrorActionPreference = 'SilentlyContinue'
if ($env:CAREERCOACHOS_SCHEDULED -eq '1') { exit 0 }
$Root = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { Split-Path -Parent $PSScriptRoot }
if (-not (Set-Location -LiteralPath $Root -PassThru)) { exit 0 }

if (-not (Test-Path 'config\profile.md')) {
    Write-Output 'CareerCoachOS: this person has not run /onboard yet.'
    Write-Output 'Before anything else, greet them in two or three short lines: what CareerCoachOS does'
    Write-Output '(a private job search run by three agents: Coach, Scout and Signal), that nothing is ever'
    Write-Output 'sent without their own click, and that setup is one conversation of about 20 minutes.'
    Write-Output 'Then ask if they are ready to start, and on yes run /onboard. If they asked something'
    Write-Output 'else first, answer it, then offer /onboard.'
    exit 0
}

$Setup = 'vault\Automation\Setup.md'
function StepOpen($label) {
    if (-not (Test-Path $Setup)) { return $true }
    return -not (Select-String -Path $Setup -Pattern "^- ${label}: (done|skipped|not on a mac)" -Quiet)
}
$Open = @()
if (StepOpen 'Dashboard') { $Open += 'the Search Desk dashboard (/dashboard)' }
$task = Get-ScheduledTask -TaskName 'CareerCoachOS daily' -ErrorAction SilentlyContinue
if (-not $task -and (StepOpen 'Daily schedule')) {
    $Open += 'the daily morning scan (powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-task.ps1)'
}
if (StepOpen 'Gmail') { $Open += 'connecting Gmail so /jobs-mail can spot replies' }
if (StepOpen 'Tour') { $Open += 'the two-minute command tour (ask: give me the tour)' }

# Days since anything in the vault changed: a long gap means they drifted off.
$Idle = $null
$profileTime = (Get-Item 'config\profile.md').LastWriteTime
$notes = @(Get-ChildItem -Path 'vault' -Recurse -File -Filter '*.md')
if ($notes | Where-Object { $_.LastWriteTime -gt $profileTime } | Select-Object -First 1) {
    $last = ($notes | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime
    $Idle = [int][math]::Floor(((Get-Date) - $last).TotalDays)
}

Write-Output 'CareerCoachOS session start. Open your first reply with a short orientation, before or'
Write-Output 'alongside answering whatever they asked:'
if ($Open.Count -gt 0) {
    Write-Output ("- Setup is not finished. Still open: " + ($Open -join '; ') + '.')
    Write-Output '  Offer the first one in one line and do it on a yes. Record each step as done or skipped'
    Write-Output "  in $Setup (create it from the /onboard template if missing) so this list shrinks."
}
if ($null -ne $Idle -and $Idle -ge 4) {
    Write-Output "- Nothing in the vault has changed for $Idle days. Welcome them back warmly, no guilt,"
    Write-Output '  and offer /checkin (what happened while you were away?) then /whats-next.'
} else {
    Write-Output '- If they have no specific request, offer /whats-next: the ranked menu of best next moves.'
}
if (Test-Path 'config\dashboard.json') {
    Write-Output '- They have a Search Desk (URL in config\dashboard.json). Before ending a turn in which'
    Write-Output '  the pipeline changed, run the /dashboard sync so the page stays current.'
}
exit 0
