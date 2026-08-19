#!/usr/bin/env bash
set -euo pipefail

# Build a portable Agent Plugins 1.0.0 directory from .agents/skills.
# Output: dist/tonoizer-agent-skills/ ready to copy into any client's plugin path.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_skills="$repo_root/.agents/skills"
out="$repo_root/dist/tonoizer-agent-skills"

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

if [ ! -d "$source_skills" ]; then
  printf 'Missing source skills: %s\n' "$source_skills" >&2
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

printf 'Building Agent Plugin into %s\n' "$out"

run rm -rf "$out"
run mkdir -p "$out/skills"

for skill_dir in "$source_skills"/*/; do
  name="$(basename "$skill_dir")"
  run mkdir -p "$out/skills/$name"
  run rsync -a --delete "$skill_dir" "$out/skills/$name/"
done

if [ "$dry_run" -eq 1 ]; then
  printf '+ write %s/plugin.json\n' "$out"
else
  cat > "$out/plugin.json" <<'MANIFEST'
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
MANIFEST
fi

count="$(find "$source_skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
printf 'Done. %s skills packaged.\n' "$count"
printf '\nInstall by copying the directory to your client plugin path, e.g.:\n'
printf '  cp -r %s ~/.agents/plugins/tonoizer-agent-skills\n' "$out"
