#requires -Version 5.1

<#
.SYNOPSIS
  Build the tonoizer-agent-skills VS Code extension (.vsix).

.DESCRIPTION
  Copies skills from .agents/skills into vscode-extension/skills,
  then runs vsce package to produce a .vsix file.

.PARAMETER DryRun
  Show what would happen without writing files.
#>

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$sourceSkills = Join-Path $repoRoot '.agents\skills'
$extensionDir = Join-Path $repoRoot 'vscode-extension'
$targetSkills = Join-Path $extensionDir 'skills'

if (-not (Test-Path -LiteralPath $sourceSkills -PathType Container)) {
    [Console]::Error.WriteLine('Missing source skills: {0}' -f $sourceSkills)
    exit 1
}

Write-Output 'Syncing skills into vscode-extension/skills...'

if (Test-Path -LiteralPath $targetSkills) {
    if ($DryRun) {
        Write-Output ('+ Remove-Item -Recurse -Force {0}' -f $targetSkills)
    } else {
        Remove-Item -Recurse -Force -LiteralPath $targetSkills
    }
}

$skillDirs = Get-ChildItem -LiteralPath $sourceSkills -Directory | Sort-Object Name

foreach ($skill in $skillDirs) {
    $dest = Join-Path $targetSkills $skill.Name
    if ($DryRun) {
        Write-Output ('+ Copy {0} -> {1}' -f $skill.FullName, $dest)
    } else {
        Copy-Item -Recurse -Force -LiteralPath $skill.FullName -Destination $dest
    }
}

Write-Output ('{0} skills synced.' -f $skillDirs.Count)

if ($DryRun) {
    Write-Output '+ npx @vscode/vsce package (in vscode-extension/)'
    Write-Output 'Dry run complete.'
    exit 0
}

Write-Output 'Packaging .vsix...'
Push-Location $extensionDir
try {
    npx @vscode/vsce package --allow-missing-repository
    if ($LASTEXITCODE -ne 0) { throw 'vsce package failed' }
} finally {
    Pop-Location
}

$vsix = Get-ChildItem -LiteralPath $extensionDir -Filter '*.vsix' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($vsix) {
    Write-Output ('Built: {0}' -f $vsix.FullName)
    Write-Output ''
    Write-Output 'Install with:'
    Write-Output ('  code --install-extension "{0}"' -f $vsix.FullName)
} else {
    Write-Output 'Warning: no .vsix file found after packaging.'
}
