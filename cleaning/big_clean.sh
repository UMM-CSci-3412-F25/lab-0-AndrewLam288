#!/usr/bin/env bash
# Clean an archive by removing files that contain the line "DELETE ME!"
set -euo pipefail

# default for CI; allow 0 or 1 arg
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [archive.tgz]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="${1:-little_dir.tgz}"
# if INPUT is relative, look beside this script
[[ "$INPUT" = /* ]] || INPUT="$SCRIPT_DIR/$INPUT"
[[ -f "$INPUT" ]] || { echo "archive not found: $INPUT" >&2; exit 1; }

HERE="$(pwd)"
OUT="cleaned_$(basename "$INPUT")"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

# extract into scratch (quiet)
tar -xzf "$INPUT" -C "$SCRATCH"

# the archive expands to a single top-level dir
TOPDIR="$(find "$SCRATCH" -mindepth 1 -maxdepth 1 -type d -print -quit)"
[[ -n "${TOPDIR:-}" ]] || { echo "could not find extracted directory" >&2; exit 1; }

# remove any file that has a line exactly "DELETE ME!"
if mapfile -d '' victims < <(grep -rlZxF -- "DELETE ME!" "$TOPDIR" || true); then
  ((${#victims[@]})) && printf '%s\0' "${victims[@]}" | xargs -0 rm -f
fi

# re-tar from inside scratch so paths don't include SCRATCH
(
  cd "$SCRATCH"
  tar -czf "$HERE/$OUT" "$(basename "$TOPDIR")"
)
