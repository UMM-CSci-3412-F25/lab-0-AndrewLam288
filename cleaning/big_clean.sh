#!/usr/bin/env bash
# Script: big_clean.sh
# Purpose: expand archive in scratch dir, delete files with a line "DELETE ME!",
#          then re-tar as cleaned_<archive>.tgz

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <archive.tgz>" >&2
  exit 1
fi

input="$1"
if [[ ! -f "$input" ]]; then
  echo "archive not found: $input" >&2
  exit 1
fi

here="$(pwd)"
out="cleaned_$(basename "$input")"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

# extract into scratch (quiet; keep original .tgz intact)
tar -xzf "$input" -C "$scratch"

# find top-level directory created by the archive
topdir="$(find "$scratch" -mindepth 1 -maxdepth 1 -type d -print -quit)"
if [[ -z "${topdir:-}" ]]; then
  echo "could not find extracted directory" >&2
  exit 1
fi

# delete files that contain a line exactly equal to "DELETE ME!"
if mapfile -d '' victims < <(grep -rlZxF -- "DELETE ME!" "$topdir" || true); then
  if ((${#victims[@]} > 0)); then
    printf '%s\0' "${victims[@]}" | xargs -0 rm -f
  fi
fi

# re-tar without embedding scratch path
(
  cd "$scratch"
  tar -czf "$here/$out" "$(basename "$topdir")"
)

