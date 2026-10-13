---
name: harness-subagent
description: >
  Delegate a bounded task to another coding-agent CLI the way a parent agent
  delegates to a subagent. CLIs are Claude Code, Codex, Grok Build, Antigravity
  (agy), the Cursor CLI (cursor-agent), and Muse Code (muse). Use when the user says
  harness-subagent, asks for another vendor's model or second opinion, or names a
  CLI or a model such as Astra, Sol, Opus, Opus 5.5, Fable, Sonnet, Sonnet 5.5,
  Haiku, Grok 4.7, Muse, Wonder, Wonder Full, or Spark. Do not use to install those
  CLIs. Do not use if this session was launched by this skill (the prompt starts
  with YOU ARE THE WORKER, or HARNESS_SUBAGENT_RUN is set). Do that job. Do not
  delegate again.
license: MIT
compatibility: Requires claude, codex, grok, agy, cursor-agent, and/or muse on PATH. Windows needs Git Bash. Python 3.
metadata:
  author: realspqrk
  version: "0.6.0"
---

# Harness subagent

You are the parent. A child CLI does one bounded task and returns a report. You judge the report. The child is not an oracle.

A CLI, model, or effort the user named wins. [When none is named](#when-none-is-named) fills only what is missing. No personas.

## Delegate

1. Take the CLI, model, and effort the user named. Spoken names are in [references/models.md](references/models.md). Fill the rest from [When none is named](#when-none-is-named). Do not ask. Cursor, cursor-agent, and Grok Bot are the `cursor` family. Grok Build is `grok`. Claude Code is `claude`. Codex is `codex`. Antigravity is `agy`. Muse Code is `muse`.
2. Always pass `--effort`. CLI defaults differ from API defaults and change between releases. Prices are per token. Higher effort spends more tokens at the same rate.
3. Write `brief.md` in a new temp run directory. Use the shape below.
4. Run `scripts/spawn.sh` in the background. On Windows, invoke Git Bash with the script path as an argument. Do not put the brief inside a PowerShell double-quoted string. Write `brief.md` as UTF-8.
5. Wait until that process exits. Read `report.md` or `last.md`, plus `capture-status.txt`, plus the exit code.
6. Say what you agree with, what you do not, and what you will do. Do not paste the report as your whole answer.

```powershell
& "$env:ProgramFiles\Git\bin\bash.exe" -- "<skill-dir>\scripts\spawn.sh" --backend codex --model Astra --effort high --project "D:/Code/app" --run "C:/Users/<you>/AppData/Local/Temp/harness-subagent/<id>"
```

`--backend` may be omitted when the model name belongs to one CLI. `--resume-id` continues that same child. Do not use `--continue` or `--last`.

A child must not delegate. `spawn.sh` sets `HARNESS_SUBAGENT_RUN` and refuses a second launch.

## When none is named

1. Put the task in one row below.
2. Take the first column whose model vendor is not yours. For a review, a refutation, or a second opinion, also skip the vendor that wrote the work. The same vendor through another CLI is not a second opinion. Antigravity and Cursor serve several vendors, so they are not in the table.
3. Skip a CLI that is missing or logged out. Run `scripts/health.sh` once per session if you do not know.
4. A named model fixes its CLI. A named CLI takes that CLI's column.
5. Say one line before you spawn: task row, CLI, model, effort. Do not wait for an answer.

| Task | `codex` | `claude` | `grok` or `muse` |
|---|---|---|---|
| Lookup, extraction, summary, triage | Luna, high | Haiku, medium | Grok 4.7, low |
| Implementation from a clear brief | Sol, medium | Sonnet, medium | Grok 4.7, medium |
| Debugging, root cause | Sol, high | Sonnet, high | Grok 4.7, high |
| Code review, refuting a plan, second opinion | Sol, high | Sonnet, high | Grok 4.7, high |
| Architecture, ambiguous design | Astra, low | Opus, high | Wonder, high |
| UI build | Sol, medium | Sonnet, medium | Grok 4.7, medium |
| Long autonomous run with clear acceptance | Sol, high | Sonnet, high | Spark, high |
| Writing, docs, copy | Sol, low | Sonnet, medium | Grok 4.7, medium |

The table starts at each vendor's starting effort for that kind of work, from the vendor guidance cited in [references/models.md](references/models.md). Effort names are calibrated per model, so `high` on one model is not `high` on another. Benchmark rows there are evidence, not a ranking.

Do not choose these unless the user names them: `max`, `ultra`, Fable (under `claude -p` it bills usage credits without asking), Wonder Full (Power or Maximum Muse plan only), Grok 4.7 Fast (twice the price for speed), and any id the registry does not list.

### When the result falls short

Exit 0 is not success. Judge the report against "Done when". Then find the cause before you change anything.

- Missing context, tools, or permission. Fix the brief. Keep the model and effort.
- The child skipped files, tests, or checks. Raise effort one step, at most to `xhigh`.
- The child had the context and tried, and the reasoning was still wrong. Move one model up within the vendor: Luna to Sol to Astra, Haiku to Sonnet to Opus, Spark to Wonder.

Change one setting per retry. Stop after two retries and tell the user what failed. A usage limit is not a quality failure; follow [When the child hits a limit](#when-the-child-hits-a-limit).

## Brief

```
# YOU ARE THE WORKER. DO NOT SPAWN.
Do not load harness-subagent. Do not run scripts/spawn.sh.

## Task
One sentence.

## Where to look
Paths, commands, and exclusions.

## Already tried

## Done when
```

Name paths. Do not paste the repo. `spawn.sh` appends the `report.md` path. The child writes that file before it exits. The first line is `VERDICT` followed by the result.

Grok cannot be relied on to read the temp run directory. `spawn.sh` copies the prompt into the project for that launch and deletes the copy on exit. Muse's sandbox cannot write outside the project, so it writes its report to a per-run `.harness-subagent-report-<uuid>.md` in the project and `spawn.sh` copies it to `report.md` in the run directory, then deletes it.

## When the child hits a limit

`spawn.sh` reads the CLI text for a reset time.

- The reset is known and within 24 hours. The script waits, then resumes that same session once. Claude Code's own auto-continue refuses waits longer than 24 hours (docs accessed 2026-09-22). This skill uses that cutoff for every CLI.
- There is no reset time, the reset is further away, the message is a credit or spend block, or a second limit arrives. The script stops. Stop with it. Tell the user the evidence and the time, if any. Wait for instructions. Do not switch CLI or model. Do not invent a reset time.

## Health

`scripts/health.sh` prints one row per CLI. Columns are name, version, login, update. `--update` runs each vendor update command. Exit 0 when every installed CLI with a login check is logged in. A missing CLI is a failed row. `broken` means the binary is on PATH but its version check fails. A failed login check is retried once, because grok reports logged-out on the first call after token expiry while it refreshes silently.

| CLI | Login check | Update |
|---|---|---|
| claude | `claude auth status` | `claude update` |
| codex | `codex login status` | `codex update` |
| grok | `grok models` must say logged in | `grok update` |
| agy | no login command | `agy update` |
| cursor-agent | `cursor-agent status` | `cursor-agent update` |
| muse | no login command | none; the launcher updates itself |

## Capture

`spawn.sh` writes `last.md`, `capture-status.txt` (`ok`, `ok-report`, `usage-limit`, or `no-verdict`), and `session.json`. A report containing `VERDICT` wins over the final stdout, because Claude's last message is only the last turn. `ok` means text was captured. It does not mean the task succeeded. Exit 0 with `no-verdict` is not success. On Windows the run directory is handed to the child as `C:/...` (`cygpath -m`), never Git Bash's `/tmp/...`, which a native CLI reads as `<drive>:\tmp`.

Resume needs the session id from that run. Copy `session-id` and `session.json` into a new run directory, write a short continuation `brief.md`, and pass `--resume-id`. The auto-wait path does this itself once.
