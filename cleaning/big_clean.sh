#!/usr/bin/env bash
# Clean an archive by removing files that contain the line "DELETE ME!"
set -euo pipefail

INPUT_BASENAME="${1:-little_dir.tgz}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$INPUT_BASENAME" in
  /*)  ARCHIVE="$INPUT_BASENAME" ;;
  *)   ARCHIVE="$SCRIPT_DIR/$INPUT_BASENAME"
       REPO_ARCHIVE="${GITHUB_WORKSPACE:-$SCRIPT_DIR/..}/cleaning/$INPUT_BASENAME"
       [[ -f "$ARCHIVE" ]] || ARCHIVE="$REPO_ARCHIVE"
       ;;
esac
[[ -f "$ARCHIVE" ]] || { echo "archive not found: $ARCHIVE" >&2; exit 1; }

HERE="$(pwd)"
OUT="cleaned_$(basename "$ARCHIVE")"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

tar -xzf "$ARCHIVE" -C "$SCRATCH"

TOPDIR="$(find "$SCRATCH" -mindepth 1 -maxdepth 1 -type d -print -quit)"
[[ -n "${TOPDIR:-}" ]] || { echo "could not find extracted directory" >&2; exit 1; }

if mapfile -d '' victims < <(grep -rlZxF -- "DELETE ME!" "$TOPDIR" || true); then
  ((${#victims[@]})) && printf '%s\0' "${victims[@]}" | xargs -0 rm -f
fi

(
  cd "$SCRATCH"
  tar -czf "$HERE/$OUT" "$(basename "$TOPDIR")"
)
