#!/usr/bin/env bash
# Build and run NthPrime from NthPrime.tgz
set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [number]" >&2
  exit 1
fi
N="${1:-17}"

# find the archive next to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$SCRIPT_DIR/NthPrime.tgz"
[[ -f "$ARCHIVE" ]] || { echo "archive not found: $ARCHIVE" >&2; exit 1; }

# extract (keep .tgz), build, run
tar -xzf "$ARCHIVE" -C "$SCRIPT_DIR"
cd "$SCRIPT_DIR/NthPrime"
gcc -O2 -Wall -Wextra -o NthPrime main.c nth_prime.c
./NthPrime "$N"

