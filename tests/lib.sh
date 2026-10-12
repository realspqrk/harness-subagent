#!/usr/bin/env bash
# Shared helpers for tests/*.sh. Source it; do not run it.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPAWN="$ROOT/scripts/spawn.sh"
REG="$ROOT/scripts/harness_registry.py"
BASH_BIN="$(command -v bash)"

PYTHON=""
for candidate in python python3; do
  if command -v "$candidate" >/dev/null && "$candidate" -c 'import sys; assert sys.version_info.major == 3' 2>/dev/null; then
    PYTHON="$candidate"
    break
  fi
done
[[ -n "$PYTHON" ]] || { echo "Python 3 required" >&2; exit 2; }

pass=0
fail=0
WORK=()
cleanup() {
  local d
  for d in "${WORK[@]+"${WORK[@]}"}"; do
    rm -rf "$d"
  done
}
trap cleanup EXIT

ok() { echo "ok - $*"; pass=$((pass + 1)); }
fail_msg() { echo "FAIL: $*" >&2; fail=$((fail + 1)); }
skip() { echo "ok - skip $*"; pass=$((pass + 1)); }
has_bin() { command -v "$1" >/dev/null 2>&1; }

# Run a command; sets $ec, $out, $err.
run_cmd() {
  local outf errf
  outf="$(mktemp "${TMPDIR:-/tmp}/hs-out.XXXXXX")"
  errf="$(mktemp "${TMPDIR:-/tmp}/hs-err.XXXXXX")"
  WORK+=("$outf" "$errf")
  set +e
  "$@" >"$outf" 2>"$errf"
  ec=$?
  set -e
  out="$(cat "$outf")"
  err="$(cat "$errf")"
}

# New run dir with a non-empty brief.md in $run. Call directly, not in $(...),
# so the cleanup list lives in this shell.
new_run() {
  run="$(mktemp -d "${TMPDIR:-/tmp}/hs-run.XXXXXX")"
  WORK+=("$run")
  printf '%s\n' "${1:-Task}" >"$run/brief.md"
}

finish() {
  echo
  echo "passed=$pass failed=$fail"
  [[ "$fail" -eq 0 ]]
}
