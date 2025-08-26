#!/usr/bin/env bash
# Script: extract_and_compile.sh
# Purpose: extract NthPrime.tgz, compile, and run NthPrime with one argument

set -euo pipefail

# allow 0 or 1 arg; default to 17 when none is given (for CI sample-run)
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [number]" >&2
  exit 1
fi
arg="${1:-17}"

# extract .tgz in one step (keeps NthPrime.tgz intact)
tar -xzf NthPrime.tgz

# move into extracted directory
cd NthPrime

# compile into executable named NthPrime
gcc -Wall -Wextra -O2 -o NthPrime main.c nth_prime.c

# run the program with the argument passed to script
./NthPrime "$arg"

