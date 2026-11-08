#requires -Version 5.1

<#
.SYNOPSIS
  Build a portable Agent Plugins 1.0.0 directory from .agents/skills.
.DESCRIPTION
  Output: dist/tonoizer-agent-skills/ ready to copy into any client's plugin path.
#>

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$sourceSkills = Join-Path $repoRoot '.agents\skills'
$outDir = Join-Path $repoRoot 'dist\tonoizer-agent-skills'

if (-not (Test-Path -LiteralPath $sourceSkills -PathType Container)) {
    [Console]::Error.WriteLine('Missing source skills: {0}' -f $sourceSkills)
    exit 1
}

function Invoke-Action {
    param([scriptblock]$Action, [string]$Preview)
    if ($DryRun) { Write-Output ('+ ' + $Preview) } else { & $Action }
}

Write-Output ('Building Agent Plugin into {0}' -f $outDir)

if (Test-Path -LiteralPath $outDir) {
    Invoke-Action `
        -Preview ('Remove-Item -Recurse -Force {0}' -f $outDir) `
        -Action { Remove-Item -Recurse -Force -LiteralPath $outDir }
}

Invoke-Action `
    -Preview ('New-Item -ItemType Directory -Force {0}\skills' -f $outDir) `
    -Action { New-Item -ItemType Directory -Force -Path (Join-Path $outDir 'skills') | Out-Null }

$skillDirs = @(Get-ChildItem -LiteralPath $sourceSkills -Directory | Sort-Object Name)

foreach ($skill in $skillDirs) {
    $dest = Join-Path $outDir "skills\$($skill.Name)"
    Invoke-Action `
        -Preview ('Copy {0} -> {1}' -f $skill.FullName, $dest) `
        -Action { Copy-Item -Recurse -Force -LiteralPath $skill.FullName -Destination $dest }
}

$manifest = @'
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "tonoizer-agent-skills",
  "version": "0.1.0",
  "description": "Reusable agent workflow skills for coding, review, PR, CI, debug, and maintainer loops.",
  "author": {
    "name": "tonoizer",
    "url": "https://github.com/tonoizer"
  },
  "repository": "https://github.com/tonoizer/skills",
  "license": "SEE LICENSE IN LICENCE",
  "keywords": [
    "agent-skills",
    "code-review",
    "ci",
    "pr",
    "debug",
    "workflow"
  ]
}
'@

$pluginJson = Join-Path $outDir 'plugin.json'
Invoke-Action `
    -Preview ('Write {0}' -f $pluginJson) `
    -Action {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($pluginJson, $manifest, $utf8NoBom)
    }

Write-Output ('{0} skills packaged.' -f $skillDirs.Count)
Write-Output ''
Write-Output 'Install by copying the directory to your client plugin path, e.g.:'
Write-Output ('  Copy-Item -Recurse {0} $env:USERPROFILE\.agents\plugins\tonoizer-agent-skills' -f $outDir)
