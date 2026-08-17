#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Check the current Git change set against an optional path allow list.

Usage:
  check-change-scope.sh [options]

Options:
  --staged          Inspect only the index.
  --base REF        Compare unstaged+staged tracked files against REF
                    (default: HEAD when it exists).
  --allow GLOB      Allow a path glob. Repeat as needed. If any --allow is
                    given, every changed path must match at least one.
  -h, --help        Show this help.

The checker also fails on unresolved conflict markers and secret-like paths.
It prints each changed path with a status of ok, out-of-scope, secret, or
conflict. Exit 1 when any path fails, 2 on usage or Git errors.
EOF
}

staged_only=0
base=""
allow_globs=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --staged) staged_only=1 ;;
    --base)
      base="${2:-}"
      if [ -z "$base" ]; then
        printf 'error: --base requires a ref\n' >&2
        exit 2
      fi
      shift
      ;;
    --allow)
      glob="${2:-}"
      if [ -z "$glob" ]; then
        printf 'error: --allow requires a glob\n' >&2
        exit 2
      fi
      # Bash case glob matching treats * as matching across '/'. Treat ** the same.
      allow_globs+=("$(printf '%s\n' "$glob" | sed 's/\*\*/\*/g')")
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf 'error: unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      printf 'error: unexpected argument: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'error: not a git repository\n' >&2
  exit 2
fi

if [ -z "$base" ] && git rev-parse --verify HEAD >/dev/null 2>&1; then
  base=HEAD
fi

path_is_allowed() {
  path="$1"
  [ "${#allow_globs[@]}" -gt 0 ] || return 0
  for pattern in "${allow_globs[@]}"; do
    case "$path" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

path_looks_secret() {
  path="$1"
  base_name="${path##*/}"
  case "$base_name" in
    .env|.env.*|*.pem|*.p12|*.pfx|*.key|id_rsa|id_rsa.*|id_dsa|id_dsa.*|id_ecdsa|id_ecdsa.*|id_ed25519|id_ed25519.*)
      case "$base_name" in
        .env.example|.env.sample|.env.template|.env.*.example) return 1 ;;
      esac
      return 0
      ;;
    credentials.json|secrets.json|secrets.yaml|secrets.yml|*.keystore)
      return 0
      ;;
  esac
  return 1
}

file_has_conflict_markers() {
  path="$1"
  [ -f "$path" ] || return 1
  grep -I -E -q '^<<<<<<< |^>>>>>>> ' "$path"
}

collect_paths() {
  if [ "$staged_only" -eq 1 ]; then
    git diff --cached --name-only --diff-filter=ACDMRUXB
    return
  fi

  {
    if [ -n "$base" ]; then
      git diff --name-only --diff-filter=ACDMRUXB "$base"
    else
      git diff --name-only --diff-filter=ACDMRUXB
      git diff --cached --name-only --diff-filter=ACDMRUXB
    fi
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
}

paths=()
while IFS= read -r path; do
  [ -n "$path" ] || continue
  paths+=("$path")
done < <(collect_paths)

if [ "${#paths[@]}" -eq 0 ]; then
  printf 'no changed files\n'
  exit 0
fi

secret_count=0
conflict_count=0
out_of_scope_count=0

printf 'path\tstatus\n'
for path in "${paths[@]}"; do
  status=ok

  if path_looks_secret "$path"; then
    status=secret
    secret_count=$((secret_count + 1))
  elif file_has_conflict_markers "$path"; then
    status=conflict
    conflict_count=$((conflict_count + 1))
  elif ! path_is_allowed "$path"; then
    status=out-of-scope
    out_of_scope_count=$((out_of_scope_count + 1))
  fi

  printf '%s\t%s\n' "$path" "$status"
done

printf '\n'
printf 'files=%s out-of-scope=%s secret=%s conflict=%s\n' \
  "${#paths[@]}" "$out_of_scope_count" "$secret_count" "$conflict_count"

if [ "$secret_count" -ne 0 ] || [ "$conflict_count" -ne 0 ] || [ "$out_of_scope_count" -ne 0 ]; then
  exit 1
fi
