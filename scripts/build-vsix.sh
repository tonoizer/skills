#!/usr/bin/env bash
set -euo pipefail

# Build the tonoizer-agent-skills VS Code extension (.vsix).
# Copies skills from .agents/skills into vscode-extension/skills,
# then runs vsce package to produce a .vsix file.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_skills="$repo_root/.agents/skills"
extension_dir="$repo_root/vscode-extension"
target_skills="$extension_dir/skills"

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

if [ ! -d "$source_skills" ]; then
  printf 'Missing source skills: %s\n' "$source_skills" >&2
  exit 1
fi

printf 'Syncing skills into vscode-extension/skills...\n'

if [ "$dry_run" -eq 1 ]; then
  [ -d "$target_skills" ] && printf '+ rm -rf %s\n' "$target_skills"
else
  rm -rf "$target_skills"
fi

count=0
for skill_dir in "$source_skills"/*/; do
  name="$(basename "$skill_dir")"
  dest="$target_skills/$name"
  if [ "$dry_run" -eq 1 ]; then
    printf '+ cp -r %s -> %s\n' "$skill_dir" "$dest"
  else
    mkdir -p "$dest"
    rsync -a --delete "$skill_dir" "$dest/"
  fi
  count=$((count + 1))
done

printf '%d skills synced.\n' "$count"

if [ "$dry_run" -eq 1 ]; then
  printf '+ npx @vscode/vsce package (in vscode-extension/)\n'
  printf 'Dry run complete.\n'
  exit 0
fi

printf 'Packaging .vsix...\n'
cd "$extension_dir"
npx @vscode/vsce package --allow-missing-repository

vsix="$(ls -t ./*.vsix 2>/dev/null | head -1)"
if [ -n "$vsix" ]; then
  printf 'Built: %s\n' "$(realpath "$vsix")"
  printf '\nInstall with:\n  code --install-extension "%s"\n' "$(realpath "$vsix")"
else
  printf 'Warning: no .vsix file found after packaging.\n'
fi
