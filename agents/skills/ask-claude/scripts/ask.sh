#!/usr/bin/env bash
# Ask one packet-mode question and print only the verified answer on stdout.
set -eu

command -v node >/dev/null || { echo "NOT RETRIEVED: node not found on PATH" >&2; exit 1; }
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec node "$script_dir/ask.mjs" "$@"
