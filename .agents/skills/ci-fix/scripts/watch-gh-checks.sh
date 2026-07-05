#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: watch-gh-checks.sh [--interval seconds] [--timeout seconds] <owner/repo> <pr|branch|sha>

Examples:
  watch-gh-checks.sh owner/repo 123
  watch-gh-checks.sh owner/repo feature/my-branch
  watch-gh-checks.sh owner/repo 9ab5d657a8dfeb0a5dd77c61d0b2d4a6f1d41ba0

Prints newly completed check-run results for one resolved commit SHA.
Exits 0 when all checks complete successfully, 1 on failed checks, 2 on timeout
or setup errors.
USAGE
}

interval=60
timeout=3600

while [ "$#" -gt 0 ]; do
  case "$1" in
    --interval)
      interval="${2:-}"
      shift 2
      ;;
    --timeout)
      timeout="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

repo="${1:-}"
target="${2:-}"

if [ -z "$repo" ] || [ -z "$target" ]; then
  usage >&2
  exit 2
fi

case "$interval" in
  ''|*[!0-9]*)
    echo "--interval must be a positive integer" >&2
    exit 2
    ;;
esac

case "$timeout" in
  ''|*[!0-9]*)
    echo "--timeout must be a positive integer" >&2
    exit 2
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 2
fi

resolve_sha() {
  local repo="$1"
  local target="$2"
  local encoded_target

  if printf '%s' "$target" | grep -Eq '^[0-9a-fA-F]{40}$'; then
    printf '%s\n' "$target"
    return 0
  fi

  if printf '%s' "$target" | grep -Eq '^[0-9]+$'; then
    gh pr view "$target" --repo "$repo" --json headRefOid --jq .headRefOid
    return 0
  fi

  encoded_target="$(jq -rn --arg value "$target" '$value | @uri')"
  gh api "repos/$repo/commits/$encoded_target" --jq .sha
}

sha="$(resolve_sha "$repo" "$target" 2>/dev/null || true)"
if [ -z "$sha" ] || [ "$sha" = "null" ]; then
  echo "could not resolve target '$target' in $repo" >&2
  exit 2
fi

echo "watching $repo@$sha"

start_epoch="$(date +%s)"
prev_file="${TMPDIR:-/tmp}/ci_prev_${$}"
cur_file="${TMPDIR:-/tmp}/ci_cur_${$}"
trap 'rm -f "$prev_file" "$cur_file"' EXIT
: > "$prev_file"

while true; do
  now_epoch="$(date +%s)"
  elapsed=$((now_epoch - start_epoch))
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "timed out after ${timeout}s waiting for checks"
    exit 2
  fi

  checks="$(gh api "repos/$repo/commits/$sha/check-runs" \
    --jq '[.check_runs[] | {name, status, conclusion, url: .html_url}]' 2>/dev/null || true)"

  if [ -z "$checks" ]; then
    sleep "$interval"
    continue
  fi

  printf '%s\n' "$checks" |
    jq -r '.[] | select(.status=="completed") | "\(.name): \(.conclusion // "unknown")"' |
    sort > "$cur_file"

  comm -13 "$prev_file" "$cur_file" || true
  cp "$cur_file" "$prev_file"

  total="$(printf '%s\n' "$checks" | jq 'length')"
  completed="$(printf '%s\n' "$checks" | jq '[.[] | select(.status=="completed")] | length')"
  failed="$(printf '%s\n' "$checks" | jq '[.[] | select(.status=="completed" and ((.conclusion // "") | IN("success","neutral","skipped") | not))] | length')"

  if [ "$total" -gt 0 ] && [ "$completed" -eq "$total" ]; then
    if [ "$failed" -eq 0 ]; then
      echo "ALL CHECKS PASSED"
      exit 0
    fi

    echo "CHECKS FAILED"
    printf '%s\n' "$checks" |
      jq -r '.[] | select(.status=="completed" and ((.conclusion // "") | IN("success","neutral","skipped") | not)) | "- \(.name): \(.conclusion // "unknown") \(.url // "")"'
    exit 1
  fi

  sleep "$interval"
done
