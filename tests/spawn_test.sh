#!/usr/bin/env bash
# Behavior checks for spawn.sh and the model registry. No live CLIs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
# The nested-spawn guard would refuse every dry-run inside a spawned child.
unset HARNESS_SUBAGENT_RUN

# --- registry ---

# Spoken name -> backend and id. Bare family names select the newest model.
while IFS='|' read -r say want; do
  got="$("$PYTHON" "$REG" resolve --model "$say" 2>&1 | tr -d '\r' | paste -sd' ' -)" || true
  if [[ "$got" == "$want" ]]; then ok "'$say' -> $want"; else fail_msg "'$say' -> '$got', want '$want'"; fi
done <<'EOF'
Astra|codex gpt-6-astra
Sol|codex gpt-6.1-sol
GPT-6 Sol|codex gpt-6-sol
GPT-5.6 Sol|codex gpt-5.6-sol
Luna|codex gpt-6-luna
Terra|codex gpt-5.6-terra
Opus|claude claude-opus-5-5
Opus 5|claude claude-opus-5
Fable|claude claude-fable-5-1
Fable 5|claude claude-fable-5
Sonnet|claude claude-sonnet-5-5
Sonnet 5|claude claude-sonnet-5
Haiku|claude claude-haiku-5-5
Grok 4.7|grok grok-4.7
Muse|muse muse-wonder-1.0
Wonder|muse muse-wonder-1.0
Wonder Full|muse muse-wonder-full-1.0
Spark|muse muse-spark-1.3
Spark 1.2|muse muse-spark-1.2
EOF

# No spoken name or id may point at two models.
dupes="$("$PYTHON" - "$ROOT/scripts/registry.json" <<'PY'
import json, re, sys
seen, dupes = {}, []
for backend, spec in json.load(open(sys.argv[1], encoding="utf-8"))["harnesses"].items():
    for rec in spec["models"]:
        for name in {re.sub(r"\s+", " ", n.strip().casefold()) for n in [rec["id"], *rec.get("say", [])]}:
            if name in seen:
                dupes.append(name)
            seen[name] = rec["id"]
print(" ".join(dupes))
PY
)"
if [[ -z "$dupes" ]]; then ok "registry names are unique"; else fail_msg "duplicate registry names: $dupes"; fi

# --- command shape per CLI (dry-run) ---

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model "Opus 5.5" --effort high --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"--model claude-opus-5-5"* && "$out" == *"--effort high"* && "$out" == *"--session-id"* && "$out" == *"Edit"* && "$out" == *"Write"* ]]; then
  ok "claude: id, effort, session id, write tools"
else
  fail_msg "claude dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model Astra --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"codex exec"* && "$out" == *"-m gpt-6-astra"* && "$out" != *"model_reasoning_effort"* ]]; then
  ok "codex: no effort flag unless asked"
else
  fail_msg "codex dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model "Grok 4.7" --effort high --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"-m grok-4.7"* && "$out" == *"--prompt-file"* && "$out" == *"--effort high"* && "$out" == *"--session-id"* ]]; then
  ok "grok: prompt file, effort, session id"
else
  fail_msg "grok dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --backend agy --model gemini-test --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"--dangerously-skip-permissions"* && "$out" != *"--add-dir"* ]]; then
  ok "agy: writes in the project, not the run dir"
else
  fail_msg "agy dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --backend cursor --model composer-2 --effort high --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"cursor-agent"* && "$out" == *"effort=high"* ]]; then
  ok "cursor: effort is written into the model id"
else
  fail_msg "cursor dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model Spark --effort max --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 0 && "$out" == *"exec --disable-approval"* && "$out" == *"--model muse-spark-1.3"* && "$out" == *"--effort max"* && "$out" == *"--session-id"* && "$out" == *"--prompt-file"* && "$out" != *"--yolo"* && "$out" != *"--trust-workspace"* ]]; then
  ok "muse: headless exec, sandbox kept, effort, session id"
else
  fail_msg "muse dry-run (exit=$ec out=$out err=$err)"
fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model "Spark 1.2" --effort max --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"effort must be one of"* ]]; then ok "muse: Spark 1.2 refuses max"; else fail_msg "Spark 1.2 max (exit=$ec err=$err)"; fi

# --- refusals ---

new_run
run_cmd "$BASH_BIN" "$SPAWN" --backend claude --model Astra --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"not a claude model"* ]]; then ok "a model from another CLI is rejected"; else fail_msg "Astra on claude (exit=$ec err=$err)"; fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model "Grok 4.5" --effort xhigh --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"effort must be one of"* ]]; then ok "an effort the model lacks is rejected"; else fail_msg "Grok 4.5 xhigh (exit=$ec err=$err)"; fi

# Haiku 4.5 has no auto mode: claude -p starts in Manual and denies every edit.
new_run
run_cmd "$BASH_BIN" "$SPAWN" --model "Haiku 4.5" --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"unknown model"* ]]; then ok "Haiku 4.5 is refused"; else fail_msg "Haiku 4.5 (exit=$ec err=$err)"; fi

new_run
run_cmd "$BASH_BIN" "$SPAWN" --model Sonnet --image "$ROOT/LICENSE" --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"only supported for codex"* ]]; then ok "--image is refused outside codex"; else fail_msg "--image on claude (exit=$ec err=$err)"; fi

new_run
run_cmd env HARNESS_SUBAGENT_RUN="$run" "$BASH_BIN" "$SPAWN" --model Astra --project "$ROOT" --run "$run" --dry-run
if [[ "$ec" -eq 2 && "$err" == *"nested spawn refused"* ]]; then ok "nested spawn is refused"; else fail_msg "nested (exit=$ec err=$err)"; fi

# --- capture (stub CLIs on PATH) ---

STUBS="$(mktemp -d "${TMPDIR:-/tmp}/hs-stubs.XXXXXX")"
WORK+=("$STUBS")
# claude stub: prints $STUB_OUT; writes $STUB_REPORT to report.md in the --add-dir run dir.
cat >"$STUBS/claude" <<'SH'
#!/usr/bin/env bash
run=""
while [[ $# -gt 0 ]]; do [[ "$1" == --add-dir ]] && run="$2"; shift; done
cat >/dev/null
[[ -n "${STUB_REPORT-}" ]] && printf '%s\n' "$STUB_REPORT" >"$run/report.md"
printf '%s\n' "$STUB_OUT"
SH
# codex stub: emits JSONL with a thread id; writes the answer to the -o file.
# STUB_NATIVE_REPORT=1 acts like a native Windows CLI instead: it reads the
# report path from the prompt text (stdin, so MSYS never translates it), resolves
# it with $STUB_PYTHON, writes report.md only into an existing directory, and
# answers with no VERDICT. Codex in PowerShell resolved /tmp/... to D:\tmp\...
cat >"$STUBS/codex" <<'SH'
#!/usr/bin/env bash
o=""
while [[ $# -gt 0 ]]; do [[ "$1" == -o ]] && o="$2"; shift; done
prompt="$(cat)"
printf '%s\n' '{"type":"thread.started","thread_id":"0b7e7c6e-1f2a-4c3d-9e8f-123456789abc"}' '{"type":"turn.completed"}'
if [[ -n "${STUB_NATIVE_REPORT-}" ]]; then
  sed -n 's/^Write report\.md to \(.*\) before you exit\..*/\1/p' <<<"$prompt" | tail -n 1 |
    "$STUB_PYTHON" -c 'import os, sys
p = os.path.abspath(sys.stdin.read().strip())
if os.path.isdir(os.path.dirname(p)):
    open(p, "w").write("VERDICT NATIVE_REPORT\n")'
  printf 'Report written.\n' >"$o"
else
  printf 'VERDICT — CODEX_OK\n' >"$o"
fi
SH
# muse stub: its sandbox only lets it write inside the project (cwd). It writes
# report.md where the prompt file names it and refuses any path outside cwd.
cat >"$STUBS/muse" <<'SH'
#!/usr/bin/env bash
pf=""
while [[ $# -gt 0 ]]; do [[ "$1" == --prompt-file ]] && pf="$2"; shift; done
dest="$(sed -n 's/^Write report\.md to \(.*\) before you exit\..*/\1/p' "$pf" | tail -n 1)"
case "$dest" in
  "$(pwd -P)"/*|"$(cygpath -m "$(pwd -P)" 2>/dev/null)"/*) printf 'VERDICT — MUSE_OK\n' >"$dest" ;;
  *) echo "sandbox: write outside workspace denied: $dest" >&2 ;;
esac
echo "Done."
SH
chmod +x "$STUBS/claude" "$STUBS/codex" "$STUBS/muse"

capture() {  # capture <stdout> <report or empty> <model>; sets $run
  new_run
  run_cmd env PATH="$STUBS:$PATH" STUB_OUT="$1" STUB_REPORT="$2" "$BASH_BIN" "$SPAWN" --model "$3" --project "$ROOT" --run "$run"
}

capture $'Preamble line\n**VERDICT — STUB_OK**\nbody' '' Sonnet
if [[ "$ec" -eq 0 && "$(cat "$run/capture-status.txt")" == ok && "$(head -n 1 "$run/last.md")" == "VERDICT — STUB_OK" ]]; then
  ok "capture: preamble dropped, bold VERDICT unwrapped"
else
  fail_msg "capture stdout (exit=$ec status=$(cat "$run/capture-status.txt" 2>/dev/null) last=$(head -c 200 "$run/last.md" 2>/dev/null) err=$err)"
fi

capture 'Cleanup done.' $'VERDICT — FROM_REPORT\ndetails' Sonnet
if [[ "$(cat "$run/capture-status.txt")" == ok-report && "$(head -n 1 "$run/last.md")" == "VERDICT — FROM_REPORT" ]]; then
  ok "capture: report.md beats the last turn"
else
  fail_msg "capture report (status=$(cat "$run/capture-status.txt" 2>/dev/null) last=$(head -c 200 "$run/last.md" 2>/dev/null))"
fi

capture "You've hit your usage limit. Try again later." '' Sonnet
if [[ "$(cat "$run/capture-status.txt")" == usage-limit && "$(head -n 1 "$run/last.md")" == *"BLOCKED: usage/rate limit"* ]]; then
  ok "capture: limit text becomes a BLOCKED verdict and stops"
else
  fail_msg "capture limit (status=$(cat "$run/capture-status.txt" 2>/dev/null) last=$(head -c 200 "$run/last.md" 2>/dev/null))"
fi

capture '' '' Astra
if [[ "$ec" -eq 0 && "$(cat "$run/capture-status.txt")" == ok && "$(tr -d '\r\n' <"$run/session-id")" == 0b7e7c6e-1f2a-4c3d-9e8f-123456789abc ]] \
   && grep -q '"thread_id": "0b7e7c6e' "$run/session.json"; then
  ok "capture: codex thread id persisted from JSONL"
else
  fail_msg "capture codex (exit=$ec status=$(cat "$run/capture-status.txt" 2>/dev/null) err=$err diag=$(cat "$run/capture-errors.log" 2>/dev/null))"
fi

# A stale report from an earlier or concurrent muse run must not be collected,
# and a dry run must not delete it.
proj="$(mktemp -d "${TMPDIR:-/tmp}/hs-proj.XXXXXX")"
WORK+=("$proj")
printf 'VERDICT — STALE\n' >"$proj/.harness-subagent-report-0b7e7c6e-1f2a-4c3d-9e8f-123456789abc.md"
new_run
run_cmd "$BASH_BIN" "$SPAWN" --model Wonder --project "$proj" --run "$run" --dry-run
new_run
run_cmd env PATH="$STUBS:$PATH" "$BASH_BIN" "$SPAWN" --model Wonder --project "$proj" --run "$run"
left="$(ls -A "$proj" | tr '\n' ' ')"
if [[ "$ec" -eq 0 && "$(cat "$run/capture-status.txt")" == ok-report && "$(head -n 1 "$run/last.md")" == "VERDICT — MUSE_OK" && "$left" == ".harness-subagent-report-0b7e7c6e-1f2a-4c3d-9e8f-123456789abc.md " && -s "$run/session-id" ]]; then
  ok "capture: muse collects only its own in-project report"
else
  fail_msg "capture muse (exit=$ec status=$(cat "$run/capture-status.txt" 2>/dev/null) last=$(head -c 200 "$run/last.md" 2>/dev/null) err=$err stderr=$(cat "$run/stderr.log" 2>/dev/null) left=$left)"
fi

# The worker and capture must agree on one run dir. Git Bash shows %TEMP% as
# /tmp; a native Windows CLI reads /tmp/... in the prompt as <drive>:\tmp\...
new_run
run_cmd "$BASH_BIN" "$SPAWN" --model Sonnet --project "$ROOT" --run "$run" --dry-run
named="$(sed -n 's/^Write report\.md to \(.*\)\/report\.md before you exit\..*/\1/p' "$run/prompt.md" | tail -n 1)"
want="$(cd "$run" && pwd -P)"
if has_bin cygpath; then want="$(cygpath -m "$want")"; fi
if [[ "$ec" -eq 0 && -n "$named" && "$named" == "$want" && "$out" == *"--add-dir $named "* && "$out" == *"$named"'\ before'* ]]; then
  ok "prompt, claude hint and --add-dir name one native run dir"
else
  fail_msg "run dir in prompt (named=$named want=$want out=$out err=$err)"
fi

new_run
run_cmd env PATH="$STUBS:$PATH" STUB_NATIVE_REPORT=1 STUB_PYTHON="$PYTHON" "$BASH_BIN" "$SPAWN" --model Astra --project "$ROOT" --run "$run"
if [[ "$ec" -eq 0 && "$(cat "$run/capture-status.txt")" == ok-report && "$(head -n 1 "$run/last.md" | tr -d '\r')" == "VERDICT NATIVE_REPORT" ]]; then
  ok "capture: a native CLI writes report.md where capture reads it"
else
  fail_msg "native report path (exit=$ec status=$(cat "$run/capture-status.txt" 2>/dev/null) last=$(head -c 200 "$run/last.md" 2>/dev/null) prompt=$(tail -n 1 "$run/prompt.md" 2>/dev/null))"
fi

# --- health (stub CLIs; POSIX Python only, Windows Python cannot exec bash stubs) ---

if [[ "$("$PYTHON" -c 'import os; print(os.name)')" == nt ]]; then
  skip "health stubs need POSIX Python"
else
  HSTUBS="$(mktemp -d "${TMPDIR:-/tmp}/hs-health.XXXXXX")"
  WORK+=("$HSTUBS")
  # grok stub: the first `models` after token expiry reports logged out, then refreshes (seen with grok 1.0.4x).
  cat >"$HSTUBS/grok" <<'SH'
#!/usr/bin/env bash
case "$1" in
  --version) echo "grok stub" ;;
  models) if [[ -f "$STUB_STATE" ]]; then echo "You are logged in with grok.com."; else : >"$STUB_STATE"; echo "You are not authenticated."; fi ;;
esac
SH
  # codex stub: a binary that cannot start (e.g. the Windows npm shim reached from WSL).
  printf '#!/usr/bin/env bash\necho "Error: Missing optional dependency" >&2\nexit 1\n' >"$HSTUBS/codex"
  chmod +x "$HSTUBS/grok" "$HSTUBS/codex"
  run_cmd env PATH="$HSTUBS:/usr/bin:/bin" STUB_STATE="$HSTUBS/refreshed" "$(command -v "$PYTHON")" "$REG" health
  if [[ "$out" == *$'grok\tgrok stub\tlogged-in'* ]]; then ok "health: login check retried after a silent token refresh"; else fail_msg "health grok (out=$out)"; fi
  if [[ "$out" == *$'codex\tbroken\t-'* ]]; then ok "health: a CLI that cannot start is broken, not logged out"; else fail_msg "health codex (out=$out)"; fi
fi

# --- usage-limit wait decision ---

while IFS='|' read -r text now want name; do
  got="$(printf '%s' "$text" | "$PYTHON" "$REG" limit --now "$now")"
  if [[ "$got" == "$want" ]]; then ok "limit: $name"; else fail_msg "limit: $name got '$got', want '$want'"; fi
done <<'EOF'
You have hit your session limit · resets 3:45pm|2026-09-22T15:00:00|wait 2715|clock reset within 24h waits
You have hit your weekly limit · resets Mon 12:00am|2026-09-22T12:00:00|stop|weekday reset beyond 24h stops
Try again at 2026-09-22T14:00:00|2026-09-22T12:00:00|wait 7215|absolute reset within 24h waits
Try again at 2026-09-25T12:00:00|2026-09-22T12:00:00|stop|absolute reset beyond 24h stops
You've hit your usage limit. Try again later.|2026-09-22T12:00:00|stop|no reset time stops
Retry-After: 30|2026-09-22T12:00:00|wait 45|Retry-After waits with the buffer
EOF

finish
