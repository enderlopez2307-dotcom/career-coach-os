# Windows: schedule the daily run (scripts\run-daily.ps1) for 07:30 with Task
# Scheduler. The Mac equivalent is scripts/install-launchd.sh.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install-task.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install-task.ps1 -Uninstall
#
# It runs as you, only while you are signed in, and catches up if the PC was
# asleep at 07:30. No admin rights needed.
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'
$Name = 'CareerCoachOS daily'
$Root = Split-Path -Parent $PSScriptRoot

if ($Uninstall) {
    Unregister-ScheduledTask -TaskName $Name -Confirm:$false -ErrorAction SilentlyContinue
    Write-Output 'Uninstalled. The daily scan will not run any more.'
    exit 0
}

# Task Scheduler starts with a minimal environment, so record where Claude
# Code lives now, while this shell can see it.
$cmd = Get-Command claude -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $cmd) {
    Write-Output 'Could not find the claude command. Install Claude Code first, then run this again.'
    exit 1
}
$Claude = $cmd.Source
if (($Root + $Claude) -match '"') {
    Write-Output 'A folder path contains a double quote. Move the folder and try again.'
    exit 1
}

New-Item -ItemType Directory -Force -Path "$Root\logs" | Out-Null
$arg = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Root\scripts\run-daily.ps1`" -ClaudeBin `"$Claude`""
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg -WorkingDirectory $Root
$trigger = New-ScheduledTaskTrigger -Daily -At '07:30'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 45) `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Settings $settings `
    -Description 'CareerCoachOS: the locked-down daily job scan. See SECURITY.md.' -Force | Out-Null

Write-Output 'Installed. Runs daily at 07:30 while you are signed in (catches up after sleep).'
Write-Output "Logs land in $Root\logs\"
Write-Output 'Test right now without waiting:'
Write-Output "  powershell -NoProfile -ExecutionPolicy Bypass -File `"$Root\scripts\run-daily.ps1`""
Write-Output 'Uninstall any time:'
Write-Output "  powershell -NoProfile -ExecutionPolicy Bypass -File `"$Root\scripts\install-task.ps1`" -Uninstall"
