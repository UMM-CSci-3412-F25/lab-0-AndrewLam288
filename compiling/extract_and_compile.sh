#!/usr/bin/env bash
# extract_and_compile.sh — extract NthPrime.tgz, build, and run NthPrime <N>
set -euo pipefail

# 0 or 1 arg; default to 17 for CI sample-run
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [number]" >&2
  exit 1
fi
arg="${1:-17}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
archive="$script_dir/NthPrime.tgz"

tar -xzf "$archive" -C "$script_dir"

cd "$script_dir/NthPrime"
gcc -Wall -Wextra -O2 -o NthPrime main.c nth_prime.c
./NthPrime "$arg"


