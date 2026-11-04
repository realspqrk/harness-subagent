#!/usr/bin/env bash
# Real-CLI smokes for Auto-mode flags. Run from Git Bash: bash tests/hello_world.sh
# Parse checks always run when the binary exists. Live one-shot per backend on PATH.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# --- parse ---

if has_bin codex; then
  run_cmd codex exec --approve-for-me --help
  if [[ "$ec" -eq 0 && "$out" == *"codex exec"* ]]; then
    ok "codex exec accepts --approve-for-me"
  else
    fail_msg "codex exec --approve-for-me --help (exit=$ec out=${out//$'\n'/ | } err=${err//$'\n'/ | })"
  fi
else
  skip "codex not on PATH (parse)"
fi

if has_bin claude; then
  run_cmd claude --help
  if [[ "$out$err" == *'"auto"'* ]]; then
    ok "claude --help lists permission-mode auto"
  else
    fail_msg "claude --help missing auto (exit=$ec)"
  fi
else
  skip "claude not on PATH (parse)"
fi

if has_bin grok; then
  run_cmd grok --help
  if echo "$out$err" | grep -qE '\[possible values:.*\bauto\b'; then
    ok "grok --help lists permission-mode auto"
  else
    fail_msg "grok --help missing auto (exit=$ec)"
  fi
else
  skip "grok not on PATH (parse)"
fi

if has_bin agy; then
  run_cmd agy --help
  if echo "$out$err" | grep -q -- '--print'; then
    ok "agy --help lists --print"
  else
    fail_msg "agy --help missing --print (exit=$ec)"
  fi
  if echo "$out$err" | grep -qE -- '--mode[[:space:]].*\bauto\b' && [[ "$out$err" == *"--sandbox"* && "$out$err" == *"--settings"* ]]; then
    ok "agy --help lists auto mode, sandbox, and session settings"
  else
    fail_msg "agy --help missing auto mode, sandbox, or session settings (exit=$ec)"
  fi
else
  skip "agy not on PATH (parse)"
fi

# --- live ---

live_one() {
  local backend="$1" model="$2" run
  if ! has_bin "$backend"; then
    skip "$backend not on PATH (live)"
    return 0
  fi
  run="$(mktemp -d "${TMPDIR:-/tmp}/hs-hw.XXXXXX")"
  WORK+=("$run")
  cat >"$run/brief.md" <<'EOF'
Reply with exactly these two lines and nothing else. Do not use tools.
VERDICT — HELLO_WORLD
HELLO_WORLD
EOF
  run_cmd "$BASH_BIN" "$SPAWN" --backend "$backend" --model "$model" --project "$ROOT" --run "$run" --effort low
  if [[ "$ec" -eq 0 && -s "$run/last.md" ]] && grep -q 'HELLO_WORLD' "$run/last.md"; then
    ok "$backend $model live HELLO_WORLD"
  else
    fail_msg "$backend $model live HELLO_WORLD (exit=$ec last=$(head -c 240 "$run/last.md" 2>/dev/null || true) err=$(head -c 240 "$run/stderr.log" 2>/dev/null || true) spawnerr=${err//$'\n'/ | })"
  fi
}

# A claude model without auto mode starts in Manual and every edit is denied,
# so a text reply can still pass live_one. Prove a write with the cheapest model.
live_write() {
  local backend="$1" model="$2" run proj
  if ! has_bin "$backend"; then
    skip "$backend not on PATH (live write)"
    return 0
  fi
  run="$(mktemp -d "${TMPDIR:-/tmp}/hs-hw.XXXXXX")"
  # Separate project: muse can only write there and hands its report over.
  proj="$(mktemp -d "${TMPDIR:-/tmp}/hs-proj.XXXXXX")"
  WORK+=("$run" "$proj")
  cat >"$run/brief.md" <<'EOF'
Create sentinel.txt in the project directory containing exactly the line: WRITE_OK
Then write the report with the line `VERDICT: done`.
EOF
  run_cmd "$BASH_BIN" "$SPAWN" --backend "$backend" --model "$model" --project "$proj" --run "$run" --effort low
  if [[ "$ec" -eq 0 && "$(tr -d '\r' <"$proj/sentinel.txt" 2>/dev/null)" == "WRITE_OK" && "$(ls -A "$proj")" == sentinel.txt && "$(cat "$run/capture-status.txt" 2>/dev/null)" == "ok-report" ]]; then
    ok "$backend $model live write"
  else
    fail_msg "$backend $model live write (exit=$ec status=$(cat "$run/capture-status.txt" 2>/dev/null || true) last=$(head -c 240 "$run/last.md" 2>/dev/null || true))"
  fi
}

live_one claude claude-opus-5-5
live_one claude claude-sonnet-5-5
live_write claude claude-haiku-5-5
live_one codex gpt-6-astra
live_one codex gpt-6.1-sol
live_one codex gpt-6.1-terra
live_one grok grok-4.7
live_write agy gemini-3.8-flash
live_one muse muse-wonder-1.0
# Wonder Full needs the Muse Power Usage or Maximum Usage plan.
[[ -n "${HS_LIVE_WONDER_FULL-}" ]] && live_one muse muse-wonder-full-1.0
live_write muse muse-spark-1.3

finish
