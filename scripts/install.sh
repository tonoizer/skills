#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install or update this repo's agent workflow skills for the current user.

Usage:
  scripts/install.sh [options]

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
EOF
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_skills="$repo_root/.agents/skills"
source_commands="$repo_root/.claude/commands"

agent_skills_home="${AGENT_SKILLS_HOME:-$HOME/.agents/skills}"
claude_skills_home="${CLAUDE_SKILLS_HOME:-$HOME/.claude/skills}"
claude_commands_home="${CLAUDE_COMMANDS_HOME:-$HOME/.claude/commands}"

dry_run=0
install_skills=1
install_commands=1
install_agent=1
install_claude=1
prune=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1 ;;
    --skills-only) install_commands=0 ;;
    --commands-only) install_skills=0 ;;
    --codex-only) install_claude=0; install_commands=0 ;;
    --claude-only) install_agent=0 ;;
    --no-prune) prune=0 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ ! -d "$source_skills" ]; then
  printf 'Missing source skills directory: %s\n' "$source_skills" >&2
  exit 1
fi

run() {
  if [ "$dry_run" -eq 1 ]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

skill_names() {
  find "$source_skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

legacy_removed_skill_names() {
  cat <<'EOF'
agent-loop
agent-workflow
bug-repro
git-iteration-hygiene
github-deep-review
github-project-triage
issue-triage-loop
monitor-ci-and-fix
project-triage
skill-cleaner
small-fix
subagent-review
subagent-review-loop
triage-issue
worktree-parallel-agents
EOF
}

write_manifest() {
  target="$1"
  manifest="$target/.agent-workflow-pack.manifest"
  if [ "$dry_run" -eq 1 ]; then
    printf '+ write %s\n' "$manifest"
  else
    skill_names > "$manifest"
  fi
}

prune_removed_skills() {
  target="$1"
  manifest="$target/.agent-workflow-pack.manifest"

  [ "$prune" -eq 1 ] || return 0

  {
    [ -f "$manifest" ] && cat "$manifest"
    legacy_removed_skill_names
  } | sort -u | while IFS= read -r old_name; do
    [ -n "$old_name" ] || continue
    [ -d "$source_skills/$old_name" ] && continue
    run rm -rf "$target/$old_name"
  done
}

install_skills_to() {
  target="$1"
  printf 'Installing skills to %s\n' "$target"
  run mkdir -p "$target"
  prune_removed_skills "$target"

  while IFS= read -r name; do
    run mkdir -p "$target/$name"
    run rsync -a --delete "$source_skills/$name/" "$target/$name/"
  done < <(skill_names)

  write_manifest "$target"
}

install_claude_commands_to() {
  target="$1"
  [ -d "$source_commands" ] || return 0

  printf 'Installing Claude slash commands to %s\n' "$target"
  run mkdir -p "$target"

  find "$source_commands" -mindepth 1 -maxdepth 1 -type f -name '*.md' | sort |
    while IFS= read -r command_file; do
      run rsync -a "$command_file" "$target/"
    done
}

if [ "$install_skills" -eq 1 ]; then
  [ "$install_agent" -eq 1 ] && install_skills_to "$agent_skills_home"
  [ "$install_claude" -eq 1 ] && install_skills_to "$claude_skills_home"
fi

if [ "$install_commands" -eq 1 ]; then
  install_claude_commands_to "$claude_commands_home"
fi

printf 'Done.\n'
