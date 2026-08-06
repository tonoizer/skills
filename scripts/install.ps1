#requires -Version 5.1

$ErrorActionPreference = 'Stop'

function Show-Usage {
    @'
Install or update this repo's agent workflow skills for the current user.

Usage:
  scripts/install.ps1 [options]

Options:
  --dry-run          Show what would change.
  --skills-only      Install only skills, not Claude slash commands.
  --commands-only    Install only Claude slash commands.
  --codex-only       Install skills only to AGENT_SKILLS_HOME.
  --claude-only      Install skills only to CLAUDE_SKILLS_HOME and Claude commands.
  --no-prune         Do not remove previously managed skills missing from this repo.
  -h, --help         Show this help.

Environment:
  AGENT_SKILLS_HOME      Default: $HOME/.agents/skills
  CLAUDE_SKILLS_HOME     Default: $HOME/.claude/skills
  CLAUDE_COMMANDS_HOME   Default: $HOME/.claude/commands

The script writes a .agent-workflow-pack.manifest file in each target skills
directory so future runs can prune only skills previously installed by this pack.
'@
}

function Get-UserHome {
    $userHomePath = [Environment]::GetEnvironmentVariable('HOME')
    if ([string]::IsNullOrEmpty($userHomePath)) {
        $userHomePath = [Environment]::GetEnvironmentVariable('USERPROFILE')
    }
    if ([string]::IsNullOrEmpty($userHomePath)) {
        $userHomePath = [Environment]::GetFolderPath('UserProfile')
    }
    return $userHomePath
}

function Get-ConfiguredPath {
    param(
        [string]$Name,
        [string]$Default
    )

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrEmpty($value)) {
        return $Default
    }
    return $value
}

function Get-InstallerFullPath {
    param([string]$Path)

    $pathForResolution = $Path
    if (-not [IO.Path]::IsPathRooted($pathForResolution)) {
        $pathForResolution = Join-Path (Get-Location).Path $pathForResolution
    }
    return [IO.Path]::GetFullPath($pathForResolution)
}

function Assert-SafeTargetRoot {
    param(
        [string]$Name,
        [string]$Path
    )

    try {
        $fullPath = Get-InstallerFullPath -Path $Path
        $root = [IO.Path]::GetPathRoot($fullPath)
        if ([string]::IsNullOrEmpty($root)) {
            throw 'The path has no recognizable filesystem root.'
        }

        $current = $root
        $rootItem = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($null -ne $rootItem -and (($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
            throw ('path component ''{0}'' is a reparse point' -f $current)
        }

        $relativePath = $fullPath.Substring($root.Length).Trim([char[]]@('\', '/'))
        if (-not [string]::IsNullOrEmpty($relativePath)) {
            foreach ($component in ($relativePath -split '[\\/]')) {
                if ([string]::IsNullOrEmpty($component)) {
                    continue
                }
                $current = Join-Path $current $component
                $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
                if ($null -ne $item -and (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
                    throw ('path component ''{0}'' is a reparse point' -f $current)
                }
            }
        }
    } catch {
        throw ('Configured {0} path ''{1}'' is unsafe or invalid: {2}' -f $Name, $Path, $_.Exception.Message)
    }
}

function Assert-ConfiguredTargets {
    if ($script:InstallSkills) {
        if ($script:InstallAgent) {
            Assert-SafeTargetRoot -Name 'AGENT_SKILLS_HOME' -Path $script:AgentSkillsHome
        }
        if ($script:InstallClaude) {
            Assert-SafeTargetRoot -Name 'CLAUDE_SKILLS_HOME' -Path $script:ClaudeSkillsHome
        }
    }
    if ($script:InstallCommands) {
        Assert-SafeTargetRoot -Name 'CLAUDE_COMMANDS_HOME' -Path $script:ClaudeCommandsHome
    }
}

function Invoke-InstallerAction {
    param(
        [scriptblock]$Action,
        [string]$Preview
    )

    if ($script:DryRun) {
        Write-Output ('+ ' + $Preview)
    } else {
        & $Action
    }
}

function Ensure-Directory {
    param([string]$Path)

    Invoke-InstallerAction `
        -Preview ("New-Item -ItemType Directory -Force -Path '{0}'" -f $Path) `
        -Action { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Remove-InstallerPath {
    param([string]$Path)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    $isReparsePoint = $null -ne $item -and (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
    if ($isReparsePoint) {
        Invoke-InstallerAction `
            -Preview ("Remove-Item -Force -LiteralPath '{0}'" -f $Path) `
            -Action {
                if ($item.PSIsContainer) {
                    [System.IO.Directory]::Delete($Path, $false)
                } else {
                    [System.IO.File]::Delete($Path)
                }
            }
        return
    }

    Invoke-InstallerAction `
        -Preview ("Remove-Item -Recurse -Force -LiteralPath '{0}'" -f $Path) `
        -Action { Remove-Item -Recurse -Force -LiteralPath $Path -ErrorAction SilentlyContinue }
}

function Remove-ReparseManifest {
    param([string]$Path)

    $manifestItem = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $manifestItem -and (($manifestItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
        Remove-InstallerPath -Path $Path
        return $true
    }
    return $false
}

function Copy-InstallerFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    $destinationItem = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($null -ne $destinationItem -and (($destinationItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
        Remove-InstallerPath -Path $Destination
        $destinationItem = $null
    }
    if ($null -ne $destinationItem -and $destinationItem.PSIsContainer) {
        throw ("Cannot copy installer file '{0}' to '{1}': the destination is an existing directory." -f $Source, $Destination)
    }

    Invoke-InstallerAction `
        -Preview ("Copy-Item -Force -LiteralPath '{0}' -Destination '{1}'" -f $Source, $Destination) `
        -Action { Copy-Item -Force -LiteralPath $Source -Destination $Destination }
}

function Get-SkillNames {
    return @(Get-ChildItem -LiteralPath $script:SourceSkills -Directory -Force | Sort-Object -Property Name | ForEach-Object { $_.Name })
}

function Get-LegacyRemovedSkillNames {
    return @(
        'agent-loop'
        'agent-workflow'
        'bug-repro'
        'free-disk-space'
        'git-iteration-hygiene'
        'github-deep-review'
        'github-project-triage'
        'issue-triage-loop'
        'monitor-ci-and-fix'
        'project-triage'
        'skill-cleaner'
        'small-fix'
        'subagent-review'
        'subagent-review-loop'
        'triage-issue'
        'worktree-parallel-agents'
    )
}

function Sync-DirectoryContents {
    param(
        [string]$Source,
        [string]$Target,
        [switch]$TargetWasReplaced
    )

    $sourceChildren = @(Get-ChildItem -LiteralPath $Source -Force)
    if (-not $TargetWasReplaced -and (Test-Path -LiteralPath $Target -PathType Container)) {
        $targetChildren = @(Get-ChildItem -LiteralPath $Target -Force)
        foreach ($targetChild in $targetChildren) {
            $sourceChildPath = Join-Path $Source $targetChild.Name
            $sourceChild = Get-Item -LiteralPath $sourceChildPath -Force -ErrorAction SilentlyContinue
            $targetIsReparsePoint = ($targetChild.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
            if ($targetIsReparsePoint -or $null -eq $sourceChild -or $sourceChild.PSIsContainer -ne $targetChild.PSIsContainer) {
                Remove-InstallerPath -Path $targetChild.FullName
            }
        }
    }

    foreach ($sourceChild in $sourceChildren) {
        $destination = Join-Path $Target $sourceChild.Name
        $destinationItem = $null
        if (-not $TargetWasReplaced) {
            $destinationItem = Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
        }
        $destinationWasReplaced = $false
        if ($null -ne $destinationItem -and (($destinationItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
            Remove-InstallerPath -Path $destination
            $destinationItem = $null
            $destinationWasReplaced = $true
        }

        if ($sourceChild.PSIsContainer) {
            if ($null -ne $destinationItem -and -not $destinationItem.PSIsContainer) {
                Remove-InstallerPath -Path $destination
                $destinationWasReplaced = $true
            }
            Ensure-Directory -Path $destination
            Sync-DirectoryContents `
                -Source $sourceChild.FullName `
                -Target $destination `
                -TargetWasReplaced:($TargetWasReplaced -or $destinationWasReplaced)
        } else {
            if ($null -ne $destinationItem -and $destinationItem.PSIsContainer) {
                Remove-InstallerPath -Path $destination
            }
            Copy-InstallerFile -Source $sourceChild.FullName -Destination $destination
        }
    }
}

function Write-SkillManifest {
    param([string]$Target)

    $manifest = Join-Path $Target '.agent-workflow-pack.manifest'
    Remove-ReparseManifest -Path $manifest | Out-Null
    if ($script:DryRun) {
        Write-Output ('+ write ' + $manifest)
    } else {
        $names = @(Get-SkillNames)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllLines($manifest, [string[]]$names, $utf8NoBom)
    }
}

function Get-SafeChildPath {
    param(
        [string]$Target,
        [string]$Name
    )

    if ([string]::IsNullOrEmpty($Name) -or $Name -ne $Name.Trim()) {
        return $null
    }
    if ($Name -eq '.' -or $Name -eq '..' -or [IO.Path]::IsPathRooted($Name)) {
        return $null
    }
    if ($Name.IndexOfAny([char[]]@('\', '/')) -ge 0) {
        return $null
    }
    if ($Name.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) {
        return $null
    }

    if (Test-Path -LiteralPath $Target) {
        $resolvedTarget = (Resolve-Path -LiteralPath $Target -ErrorAction Stop).Path
    } else {
        $resolvedTarget = [IO.Path]::GetFullPath($Target)
    }
    $candidate = [IO.Path]::GetFullPath((Join-Path $resolvedTarget $Name))
    $resolvedCandidate = Resolve-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
    if ($null -ne $resolvedCandidate) {
        $candidate = $resolvedCandidate.Path
    }

    $targetRoot = $resolvedTarget.TrimEnd([char[]]@('\', '/'))
    $targetPrefix = $targetRoot + [IO.Path]::DirectorySeparatorChar
    if (-not $candidate.StartsWith($targetPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    return $candidate
}

function Remove-PrunedSkills {
    param([string]$Target)

    if (-not $script:Prune) {
        return
    }

    $manifest = Join-Path $Target '.agent-workflow-pack.manifest'
    $names = @()
    $manifestWasReplaced = Remove-ReparseManifest -Path $manifest
    if (-not $manifestWasReplaced -and (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        $names += @(Get-Content -LiteralPath $manifest)
    }
    $names += Get-LegacyRemovedSkillNames

    foreach ($oldName in ($names | Sort-Object -Unique)) {
        $safeTargetPath = Get-SafeChildPath -Target $Target -Name $oldName
        if ($null -eq $safeTargetPath) {
            continue
        }
        if (Test-Path -LiteralPath (Join-Path $script:SourceSkills $oldName) -PathType Container) {
            continue
        }
        Remove-InstallerPath -Path $safeTargetPath
    }
}

function Install-SkillsTo {
    param([string]$Target)

    Write-Output ('Installing skills to ' + $Target)
    Ensure-Directory -Path $Target
    Remove-PrunedSkills -Target $Target

    foreach ($name in Get-SkillNames) {
        $skillTarget = Join-Path $Target $name
        $skillTargetItem = Get-Item -LiteralPath $skillTarget -Force -ErrorAction SilentlyContinue
        $skillTargetWasReplaced = $false
        if ($null -ne $skillTargetItem -and (($skillTargetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
            Remove-InstallerPath -Path $skillTarget
            $skillTargetWasReplaced = $true
        }
        Ensure-Directory -Path $skillTarget
        Sync-DirectoryContents `
            -Source (Join-Path $script:SourceSkills $name) `
            -Target $skillTarget `
            -TargetWasReplaced:$skillTargetWasReplaced
    }

    Write-SkillManifest -Target $Target
}

function Install-ClaudeCommandsTo {
    param([string]$Target)

    if (-not (Test-Path -LiteralPath $script:SourceCommands -PathType Container)) {
        return
    }

    Write-Output ('Installing Claude slash commands to ' + $Target)
    Ensure-Directory -Path $Target
    $commandFiles = @(Get-ChildItem -LiteralPath $script:SourceCommands -File -Filter '*.md' -Force | Sort-Object -Property Name)
    foreach ($commandFile in $commandFiles) {
        Copy-InstallerFile -Source $commandFile.FullName -Destination (Join-Path $Target $commandFile.Name)
    }
}

$script:DryRun = $false
$script:InstallSkills = $true
$script:InstallCommands = $true
$script:InstallAgent = $true
$script:InstallClaude = $true
$script:Prune = $true

foreach ($option in @($args)) {
    switch ($option) {
        '--dry-run' { $script:DryRun = $true }
        '--skills-only' { $script:InstallCommands = $false }
        '--commands-only' { $script:InstallSkills = $false }
        '--codex-only' {
            $script:InstallClaude = $false
            $script:InstallCommands = $false
        }
        '--claude-only' { $script:InstallAgent = $false }
        '--no-prune' { $script:Prune = $false }
        '-h' { Show-Usage; exit 0 }
        '--help' { Show-Usage; exit 0 }
        default {
            [Console]::Error.WriteLine('Unknown option: {0}' -f $option)
            Show-Usage
            exit 2
        }
    }
}

$scriptPath = $MyInvocation.MyCommand.Path
$script:RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $scriptPath) '..')).Path
$script:SourceSkills = Join-Path $script:RepoRoot '.agents\skills'
$script:SourceCommands = Join-Path $script:RepoRoot '.claude\commands'

$userHome = Get-UserHome
$script:AgentSkillsHome = Get-ConfiguredPath -Name 'AGENT_SKILLS_HOME' -Default (Join-Path $userHome '.agents\skills')
$script:ClaudeSkillsHome = Get-ConfiguredPath -Name 'CLAUDE_SKILLS_HOME' -Default (Join-Path $userHome '.claude\skills')
$script:ClaudeCommandsHome = Get-ConfiguredPath -Name 'CLAUDE_COMMANDS_HOME' -Default (Join-Path $userHome '.claude\commands')

if (-not (Test-Path -LiteralPath $script:SourceSkills -PathType Container)) {
    [Console]::Error.WriteLine('Missing source skills directory: {0}' -f $script:SourceSkills)
    exit 1
}

Assert-ConfiguredTargets

if ($script:InstallSkills) {
    if ($script:InstallAgent) {
        Install-SkillsTo -Target $script:AgentSkillsHome
    }
    if ($script:InstallClaude) {
        Install-SkillsTo -Target $script:ClaudeSkillsHome
    }
}

if ($script:InstallCommands) {
    Install-ClaudeCommandsTo -Target $script:ClaudeCommandsHome
}

Write-Output 'Done.'
