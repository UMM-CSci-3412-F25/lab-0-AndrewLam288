#!/usr/bin/env bash
# big_clean.sh — expand <archive.tgz> in a scratch dir, delete files whose
# line is exactly "DELETE ME!", then re-tar as cleaned_<archive>.tgz
set -euo pipefail

# 0 or 1 arg; default for CI sample-run
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [archive.tgz]" >&2
  exit 1
fi

# Resolve default archive relative to this script's directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
input="${1:-little_dir.tgz}"
[[ "$input" = /* ]] || input="$script_dir/$input"

if [[ ! -f "$input" ]]; then
  echo "archive not found: $input" >&2
  exit 1
fi

here="$(pwd)"
out="cleaned_$(basename "$input")"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

# Extract quietly into scratch
tar -xzf "$input" -C "$scratch"

# Find top-level directory created by the archive
topdir="$(find "$scratch" -mindepth 1 -maxdepth 1 -type d -print -quit)"
if [[ -z "${topdir:-}" ]]; then
  echo "could not find extracted directory" >&2
  exit 1
fi

# Delete files that contain a line exactly equal to "DELETE ME!"
if mapfile -d '' victims < <(grep -rlZxF -- "DELETE ME!" "$topdir" || true); then
  ((${#victims[@]} > 0)) && printf '%s\0' "${victims[@]}" | xargs -0 rm -f
fi

# Re-tar without embedding scratch path; write to current dir ($here)
(
  cd "$scratch"
  tar -czf "$here/$out" "$(basename "$topdir")"
)

