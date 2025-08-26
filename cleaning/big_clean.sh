#!/usr/bin/env bash
set -euo pipefail

# allow 0 or 1 arg; default to little_dir.tgz when none is given (for CI sample-run)
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [archive.tgz]" >&2
  exit 1
fi
input="${1:-little_dir.tgz}"

if [[ ! -f "$input" ]]; then
  echo "archive not found: $input" >&2
  exit 1
fi

here="$(pwd)"
out="cleaned_$(basename "$input")"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

tar -xzf "$input" -C "$scratch"

topdir="$(find "$scratch" -mindepth 1 -maxdepth 1 -type d -print -quit)"
if [[ -z "${topdir:-}" ]]; then
  echo "could not find extracted directory" >&2
  exit 1
fi

if mapfile -d '' victims < <(grep -rlZxF -- "DELETE ME!" "$topdir" || true); then
  ((${#victims[@]} > 0)) && printf '%s\0' "${victims[@]}" | xargs -0 rm -f
fi

(
  cd "$scratch"
  tar -czf "$here/$out" "$(basename "$topdir")"
)

