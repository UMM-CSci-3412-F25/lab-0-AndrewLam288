#!/usr/bin/env bash
# Build and run NthPrime from NthPrime.tgz
set -euo pipefail

N="${1:-17}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$SCRIPT_DIR/NthPrime.tgz"
REPO_ARCHIVE="${GITHUB_WORKSPACE:-$SCRIPT_DIR/..}/compiling/NthPrime.tgz"
[[ -f "$ARCHIVE" ]] || ARCHIVE="$REPO_ARCHIVE"
[[ -f "$ARCHIVE" ]] || { echo "archive not found: $ARCHIVE" >&2; exit 1; }

tar -xzf "$ARCHIVE" -C "$SCRIPT_DIR"
cd "$SCRIPT_DIR/NthPrime"
gcc -O2 -Wall -Wextra -o NthPrime main.c nth_prime.c
./NthPrime "$N"
