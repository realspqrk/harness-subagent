# Models

Spoken names resolve to these ids. Prices are USD per million tokens, standard rate, short context, as published on 2026-09-22, plus Sonnet 5.5 on 2026-09-29, GPT-6.1 Sol on 2026-09-30, Haiku 5.5 and the Muse models on 2026-10-12, Muse Wonder Full on 2026-10-13, GPT-6.1 Terra on 2026-10-27, Fable 5.2 and Muse Ember on 2026-11-11, and GPT-6.2 Astra and GPT-6.2 Sol on 2026-11-18. A higher effort does not change the per-token rate. It spends more tokens, and those tokens are billed at the output rate.

`spawn.sh` without `--effort` keeps the CLI default. A host passes `--effort` anyway; see [SKILL.md](../SKILL.md#when-none-is-named) for the starting effort per task. This file is the catalog behind that table.

The score tables are evidence, not a ranking. Rows mix benchmark versions, harnesses, and efforts. Compare two models only on the same benchmark version and harness, and say the effort of each. Never average rows.

Sections: [Claude Code](#claude-code-claude) · [Codex](#codex-codex) · [Grok Build](#grok-build-grok) · [Muse Code](#muse-code-muse) · [Antigravity and Cursor](#antigravity-agy-and-cursor-cli-cursor)

## Claude Code (`claude`)

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Opus 5.5, Opus | `claude-opus-5-5` | 4 | 20 | low, medium, high, xhigh, max |
| Fable 5.2, Fable | `claude-fable-5-2` | 8 | 40 | low, medium, high, xhigh, max |
| Fable 5.1 | `claude-fable-5-1` | 10 | 50 | low, medium, high, xhigh, max |
| Opus 5 | `claude-opus-5` | 5 | 25 | low, medium, high, xhigh, max |
| Fable 5 | `claude-fable-5` | 10 | 50 | low, medium, high, xhigh, max |
| Sonnet 5.5, Sonnet | `claude-sonnet-5-5` | 2 | 10 | low, medium, high, xhigh, max |
| Sonnet 5 | `claude-sonnet-5` | 2 | 10 | low, medium, high, xhigh, max |
| Haiku 5.5, Haiku | `claude-haiku-5-5` | 0.10 | 0.50 | low, medium, high, xhigh, max |

Opus 5.5 shipped 2026-09-22. Sonnet 5.5 shipped 2026-09-28 and needs Claude Code 2.1.284 or later. On the Anthropic API the short aliases `opus` and `sonnet` point at Opus 5.5 and Sonnet 5.5. This skill passes the full id. Saying Sonnet selects Sonnet 5.5. Opus 5, Fable 5, and Sonnet 5 are still served and stay under their versioned names.

Fable 5.2 shipped 2026-11-09 and needs Claude Code 2.1.321 or later. Saying Fable selects it; in Claude Code the `fable` alias resolves to Fable 5.2 too, except in Claude apps gateway sessions, where it stays Fable 5. Fable 5.1 and Fable 5 are still served as legacy models and stay under their versioned names. Fable 5.2 supports auto mode. Under `claude -p`, Fable can bill usage credits without asking, depending on plan and seat tier. Claude Mythos 5.2 shipped the same day for verified organizations only, so it is not listed. On 2026-11-11 a Fable 5.2 call at `low` in Claude Code 2.1.322 replied, and an invented id failed.

Haiku 5.5 shipped 2026-10-07 and needs Claude Code 2.1.293 or later. Saying Haiku selects it. Its price is for prompts up to 100k tokens; above that a request pays 0.50 input and 2.50 output. Haiku 4.5 is not listed, so spawn.sh refuses it. It does not support auto mode, so `claude -p --permission-mode auto` starts in Manual and every edit is denied, which ends in `no-verdict`. Haiku 5.5 supports auto mode. On 2026-10-12 a Haiku 5.5 spawn at `low` wrote a file and returned `ok-report`.

Sonnet 5.5 recalibrates its effort levels relative to Sonnet 5, so an effort that suited Sonnet 5 is not the same spend on Sonnet 5.5. Claude Code defaults Fable 5.2, Opus 5.5, Sonnet 5.5, and Haiku 5.5 to `medium`. The Claude Platform API defaults Sonnet 5.5 and Fable 5.2 to `high`.

Vendor descriptions, from the Claude Code model docs (accessed 2026-09-29; Fable 5.2 default 2026-11-11).

| Effort | What Anthropic says |
|---|---|
| low | Quick exchanges you review each result of, such as brainstorming, a first sketch, or a rename. |
| medium | The default on Fable 5.2, Opus 5.5, Sonnet 5.5, and Haiku 5.5. Day-to-day work with a clear scope, such as implementing a feature. On other models it trades some intelligence for fewer tokens. |
| high | Work where verification matters or edge cases are likely, such as fixing a bug in an existing codebase. The default on Fable 5.1, Fable 5, Opus 5, and Sonnet 5. |
| xhigh | Deeper reasoning, higher token spend. |
| max | Hard problems you want worked through without you. May show diminishing returns and overthinking. |

Published scores that name an effort.

| Model | Benchmark | Score | Effort on that score |
|---|---|---:|---|
| Fable 5.2 | FrontierCode 2.0 | 49.1% | xhigh, its best |
| Fable 5.2 | FrontierCode 2.0 | 45.7% | max |
| Fable 5.2 | FrontierCode 2.0 | 45.3% | high |
| Fable 5.2 | FrontierCode 2.0 | 37.6% | medium |
| Fable 5.2 | FrontierCode 2.0 | 34.2% | low |
| Fable 5.1 | FrontierCode 2.0 | 32.4% | xhigh |
| Fable 5.2 | CursorBench 4.0 | 60.0% | max |
| Fable 5.2 | CursorBench 4.0 | 56.9% | high |
| Fable 5.2 | CursorBench 4.0 | 56.3% | xhigh |
| Fable 5.2 | CursorBench 4.0 | 54.8% | medium |
| Fable 5.2 | CursorBench 4.0 | 53.2% | low |
| Fable 5.2 | Terminal-Bench 4.0 | 67.6% | max, with safeguards on |
| Opus 5.5 | FrontierCode v1.1 | 54.6% | medium |
| Opus 5.5 | CursorBench 4.0 | 52.5% | medium |
| Opus 5.5 | FrontierCode v1.1 | 54.4% | max |
| Opus 5.5 | CursorBench 4.0 | 57.8% | max |
| Opus 5.5 | Terminal-Bench 4.0 | 66.4% | xhigh |
| Sonnet 5.5 | Terminal-Bench 4.0 | 70.6% | max |
| Sonnet 5.5 | Terminal-Bench 4.0 | 28.8% | medium |
| Sonnet 5.5 | FrontierCode v1.1 | 52.1% | xhigh |
| Sonnet 5.5 | FrontierCode v1.1 | 49.4% | high |
| Sonnet 5.5 | FrontierCode v1.1 | 46.2% | max |
| Sonnet 5.5 | CursorBench 4.0 | 55.5% | max |
| Sonnet 5.5 | CursorBench 4.0 | 39.2% | medium |
| Haiku 5.5 | FrontierCode v1.1 | 46.4% | max, called its best |
| Haiku 5.5 | Terminal-Bench 4.0 | 39.2% | max |
| Haiku 5.5 | CursorBench 4.0 | 48.4% | max |
| Haiku 5.5 | CursorBench 4.0 | 42.3% | high |
| Haiku 5.5 | CursorBench 4.0 | 36.9% | medium |
| Haiku 5.5 | CursorBench 4.0 | 30.9% | low |

Fable 5.2 also scores lower on FrontierCode 2.0 at max than at xhigh. FrontierCode 2.0 is not v1.1, so do not compare its rows with the v1.1 rows. Its FrontierCode and CursorBench rows come from the Fable 5.2 system card, sections 8.4 and 8.8. Cognition and Cursor ran those benchmarks, and Cursor's own chart shows the same CursorBench numbers. Sonnet 5.5 scores lower on FrontierCode at max than at xhigh. Anthropic's footnote says that at max it more often ran a multi-subagent code review, which led to timeouts or edits beyond the task. The medium and high Sonnet 5.5 rows come from the per-effort cost charts on the announcement page, not its headline table.

Sources: https://platform.claude.com/docs/en/about-claude/pricing, https://code.claude.com/docs/en/model-config, https://www.anthropic.com/news/claude-opus-5-5, and https://www.anthropic.com/claude-sonnet-5-5 (accessed 2026-09-29). Haiku 5.5: the same pricing and model-config pages, and https://code.claude.com/docs/en/permission-modes for auto mode support (accessed 2026-10-12). Fable 5.2: https://platform.claude.com/docs/en/about-claude/models/overview, the same pricing, model-config, and permission-modes pages, https://www.anthropic.com/claude/fable, https://www.anthropic.com/claude-fable-and-mythos-5-2, the system card at https://www.anthropic.com/claude-fable-5-2-mythos-5-2-system-card, and https://cursor.com/cursorbench (accessed 2026-11-11). Haiku 5.5 scores: the Haiku 5.5 system card, https://www-cdn.anthropic.com/e1080d6bf5ae2018ea3c2f414064be03232f5be5/Claude%20Haiku%205.5%20System%20Card.pdf, and https://cursor.com/docs/models/claude-haiku-5-5 (accessed 2026-10-12)

## Codex (`codex`)

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Astra, GPT-6.2 Astra | `gpt-6.2-astra` | 8 | 40 | low, medium, high, xhigh, max, ultra |
| Sol, GPT-6.2 Sol | `gpt-6.2-sol` | 2 | 10 | low, medium, high, xhigh, max, ultra |
| GPT-6 Astra | `gpt-6-astra` | 10 | 50 | low, medium, high, xhigh, max, ultra |
| GPT-6.1 Sol | `gpt-6.1-sol` | 2 | 10 | low, medium, high, xhigh, max, ultra |
| Terra, GPT-6.1 Terra | `gpt-6.1-terra` | 1 | 5 | low, medium, high, xhigh, max, ultra |
| GPT-6 Sol | `gpt-6-sol` | 2 | 10 | low, medium, high, xhigh, max, ultra |
| Luna, GPT-6 Luna | `gpt-6-luna` | 0.10 | 0.50 | low, medium, high, xhigh, max |
| GPT-5.6 Sol | `gpt-5.6-sol` | 4 | 20 | low, medium, high, xhigh, max, ultra |
| GPT-5.6 Terra | `gpt-5.6-terra` | 2 | 12 | low, medium, high, xhigh, max, ultra |
| GPT-5.6 Luna | `gpt-5.6-luna` | 0.20 | 1.20 | low, medium, high, xhigh, max |

GPT-6.2 Astra and GPT-6.2 Sol shipped 2026-11-17. OpenAI's release note says to update Codex CLI to the latest version and names no minimum. codex-cli 0.167.1 lists both on 2026-11-18. Saying Astra selects `gpt-6.2-astra`. Saying Sol selects `gpt-6.2-sol`. GPT-6 Astra and GPT-6.1 Sol are still served and stay under their versioned names. There is no GPT-6.2 Terra or GPT-6.2 Luna as of 2026-11-18. GPT-6.2 Astra costs 20% less than GPT-6 Astra. GPT-6.2 Sol keeps the Sol price. For both, a request over 272k input tokens pays double input and 1.5 times output for the whole request. Ultrafast is a faster service tier at 3 times the standard rate through 2027-02-28 and 6 times from 2027-03-01. This skill does not select it. Both API pages say the API rejects `none` and name no default effort. OpenAI's GPT-6.2 migration guide (`guides/latest-model`) says, for `gpt-6.2-astra` or `gpt-6.2-sol`, "Start with `medium` for a new integration." The task table in SKILL.md uses `medium` for Astra on that basis. The catalog also lists a hidden `gpt-reserve`, which is not listed here.

GPT-6.1 Sol shipped 2026-09-29 at the GPT-6 Sol price. The codex-cli 0.159.2 catalog lists GPT-6.1 Sol. Saying Luna selects `gpt-6-luna`. GPT-6 Sol, GPT-5.6 Sol, and GPT-5.6 Luna are still served and stay under those versioned names. GPT-6.1 Terra shipped 2026-10-26 and needs codex-cli 0.159.0 or later. Saying Terra selects `gpt-6.1-terra`. GPT-5.6 Terra stays under its versioned name. OpenAI says Terra is for clear writing, visual understanding, and computer use. OpenAI does not call Terra its coding model. There is no GPT-6.1 Astra or GPT-6.1 Luna as of 2026-10-27. GPT-5.4 left Codex on 2026-08-31 and GPT-5.5 leaves it on 2026-10-14, so neither is listed and `spawn.sh` refuses both. GPT-5.6 Sol's 4/20 price is promotional until 2026-11-30, per the pricing page on 2026-11-18. Prices above are standard short-context rates. Ultra is a product mode that runs parallel agents. It is not a separate per-token price. The API pages for GPT-6 Sol and Luna also list `none` and default to medium. The GPT-6.1 Sol API page lists low through max, without `none`, and defaults to medium. This CLI's catalog does not list `none`. It does list `ultra` for both GPT-6.2 models, GPT-6 Astra, GPT-6.1 Sol, and GPT-6 Sol. In codex-cli 0.164.0 the catalog default effort is `low` for GPT-6.1 Sol and GPT-6.1 Terra. It is `medium` for GPT-6 Astra, GPT-6 Sol, and Luna. In codex-cli 0.167.1 it is `low` for GPT-6.2 Astra and GPT-6.2 Sol. OpenAI's Codex model page (accessed 2026-10-27) says to start Luna at high and GPT-6 Astra at low. OpenAI's latest-model guide says to start Terra at `medium`. The GPT-6.1 Terra API page lists `none` through `max` and defaults to medium. The task table in SKILL.md uses those starting efforts, not the catalog defaults.

| Effort | What OpenAI says |
|---|---|
| low | Efficient reasoning, modest latency. |
| medium | Balance of quality, latency, and cost. |
| high | Hard reasoning and debugging. |
| xhigh | Longer agent work, more time and tokens. |
| max | More time than xhigh for checks and revision. |
| ultra | Parallel agents. Not an API `reasoning.effort` value. |

Published scores. These are not one shared test.

| Model | Benchmark | Score | Effort label |
|---|---|---:|---|
| GPT-6.2 Astra | Terminal-Bench 4.0 (Vals run) | 63.13% | max |
| GPT-6.2 Sol | Terminal-Bench 4.0 (Vals run) | 60.61% | max |
| GPT-6.2 Astra | Vibe Code Bench 1-100 v1.1 (Vals) | 55.16% | max |
| GPT-6.2 Sol | Vibe Code Bench 1-100 v1.1 (Vals) | 40.94% | max |
| GPT-6.1 Sol | DeepSWE v1.1 | 75.2% | high |
| GPT-6 Sol | DeepSWE v1.1 | 68.8% | max, called its best score |
| GPT-6.1 Sol | FrontierCode v1.1 | 58.1% | low |
| GPT-6.1 Sol | FrontierCode v1.1 | 60.4% | medium, named in the cost sentence |
| GPT-6 Sol | FrontierCode v1.1 | 50.5% | low |
| GPT-6.1 Sol | OSWorld 2.0 offline | 71.4% | max |
| GPT-6 Astra | OSWorld 2.0 offline | 73.5% | max |
| GPT-6.1 Sol | AutomationBench | 31.7% | medium |
| GPT-6.1 Terra | Terminal-Bench 4.0 (Vals run) | 49.5% | max |
| GPT-6 Astra | Terminal-Bench 4.0 | 57.9% | maximum across efforts, winning effort not named |
| GPT-5.6 Sol | Terminal-Bench 4.0 | 37.3% | maximum across efforts, winning effort not named |

Sources: https://developers.openai.com/api/docs/pricing, https://developers.openai.com/api/docs/models/gpt-6-sol, and https://developers.openai.com/api/docs/models/gpt-6-luna (accessed 2026-09-23), and https://developers.openai.com/api/docs/models/gpt-6.1-sol (accessed 2026-09-30). Retirements and starting efforts: https://learn.chatgpt.com/docs/models (accessed 2026-10-13). Earlier scores: https://openai.com/index/gpt-6-astra/ (accessed 2026-09-22). GPT-6.1 Sol scores: OpenAI Developers posts https://x.com/OpenAIDevs/status/2104993067942219873 and https://x.com/OpenAIDevs/status/2104993086099398854, and Cognition, which maintains FrontierCode, at https://devin.ai/blog/gpt-6-1-sol (accessed 2026-09-30). OpenAI's launch charts plot score against cost without labeling the effort on each point, so no score is read from them. No Luna score is copied here, because its page did not publish one. GPT-6.1 Terra: https://developers.openai.com/api/docs/models/gpt-6.1-terra, https://developers.openai.com/api/docs/guides/latest-model, https://developers.openai.com/api/docs/changelog, https://x.com/OpenAI/status/2114780720170164735, and the Vals run at https://www.vals.ai/models/openai_gpt-6.1-terra (accessed 2026-10-27). OpenAI's launch post states a Terra Terminal-Bench 4.0 score. openai.com could not be fetched to verify that score, so the score is not copied. GPT-6.2 rows come from Vals' tables at https://www.vals.ai/benchmarks/terminal-bench-4 (mini-swe-agent, avg@3) and https://www.vals.ai/benchmarks/vcb-1-100-v1-1. The effort on those rows comes from Vals' model pages https://www.vals.ai/models/openai_gpt-6.2-astra and https://www.vals.ai/models/openai_gpt-6.2-sol and from Vals' post https://x.com/ValsAI/status/2122750584084426852 ("we ran both at max reasoning effort") (accessed 2026-11-18). GPT-6.2 model pages are https://developers.openai.com/api/docs/models/gpt-6.2-astra and https://developers.openai.com/api/docs/models/gpt-6.2-sol, and the guide is https://developers.openai.com/api/docs/guides/latest-model (accessed 2026-11-18). OpenAI's launch post https://openai.com/index/introducing-gpt-6-2-astra-sol says that on Cognition's FrontierCode 2.0, GPT-6.2 Sol comes within 0.5 points of GPT-6.2 Astra at about one-fifth the cost, both at max. Cognition has not published those scores, so no row is copied. Artificial Analysis prints its Coding Agent Index scores only in a chart image, so none is copied. Artificial Analysis says GPT-6.2 Sol loses 3 points against GPT-6.1 Sol on that index (Codex harness, max). It says GPT-6.2 Astra is flat with GPT-6 Astra.

## Grok Build (`grok`)

Prices below are the global endpoint under 200k prompt tokens. At 200k and above, input and output double.

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Grok 4.7 | `grok-4.7` | 2 | 6 | low, medium, high, xhigh |
| Grok 4.7 Fast | `grok-4.7-build-fast` | 4 | 12 | low, medium, high, xhigh |
| Grok 4.6 | `grok-4.6` | 2 | 6 | low, medium, high, xhigh |
| Grok 4.5 | `grok-4.5` | 2 | 6 | low, medium, high |

`grok-4.7-build-fast` is the id `grok models` printed on this class of machine on 2026-09-22. The public docs say "Grok 4.7 Fast" and do not print that slug. The API defaults `reasoning_effort` to `high`. `xhigh` is documented for Grok 4.6 and later. The 4.5 card also lists it, and the 2026-09-21 reasoning guide says 4.5 treats `xhigh` as `high`.

| Benchmark | Grok 4.7 | Effort column |
|---|---:|---|
| CursorBench 4.0 | 46.3% | xHigh |
| DeepSWE v1.1 | 71.0% | high (starred cell) |
| Terminal-Bench 4.0 | 37.6% | xHigh |

Source: https://x.ai/news/grok-4-7 (2026-09-21) and https://docs.x.ai/developers/pricing (accessed 2026-09-22).

## Muse Code (`muse`)

Meta's API has one price at every context length, up to 1,048,576 tokens, except Muse Ember: a request over 200k input tokens pays 0.30 input and 1.50 output for the whole request. Reasoning tokens bill as output. Muse Wonder Full has no per-token price.

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Muse Wonder Full, Wonder Full | `muse-wonder-full-1.0` | - | - | minimal, low, medium, high, xhigh, max, ultra |
| Muse Wonder, Wonder, Muse | `muse-wonder-1.0` | 4 | 20 | minimal, low, medium, high, xhigh, max, ultra |
| Spark 1.3, Spark | `muse-spark-1.3` | 1.25 | 4.25 | minimal, low, medium, high, xhigh, max, ultra |
| Spark 1.2 | `muse-spark-1.2` | 1.25 | 4.25 | minimal, low, medium, high, xhigh, ultra |
| Muse Ember, Ember | `muse-ember-1.0` | 0.10 | 0.50 | minimal, low, medium, high, xhigh, max, ultra |

Muse Wonder shipped 2026-10-12, in preview. Saying Muse or Wonder selects it. Spark 1.3 shipped 2026-09-02 and is the one Meta recommends for new work. Muse Code documents Spark 1.2 as its default (configuration page, 2026-11-11).

Muse Ember shipped 2026-11-09. Meta calls it its smallest, most efficient model, for sub-agent tasks, tool calls, routing, and extraction, with Spark or Wonder planning on the main loop. It runs on the Model API and in Muse Code on pay-as-you-go and every subscription. It has no `-contributor` variant. Its API default effort is `max`. Meta names no starting effort for it, so it is not in the task table in SKILL.md. On 2026-11-11 Muse Code 1.4.15 ran `muse-ember-1.0` at `low`, and an invented id failed with "does not exist or you lack access".

Muse Wonder Full shipped 2026-10-12. Meta calls it the higher-capability variant of Wonder, built on a larger base model. It runs only in Muse Code on the Power Usage ($50/month) or Maximum Usage ($200/month) plan, never on the Model API, and choosing `max` on Wonder does not select it. Meta's models page prints no id. Its model page prints `muse-wonder-full-1.0`, and on 2026-10-13 Muse Code 1.4.6 ran that id on Windows and WSL at minimal through max, while an invented id failed with "does not exist or you lack access". On a plan without it, expect that same error. Saying Wonder or Muse still selects `muse-wonder-1.0`, which every plan has. Spark 1.1 runs only on the Model API, not in Muse Code. The `-contributor` ids, priced at 0.10/0.20, let Meta train on your sessions. They are not listed, so `spawn.sh` refuses them. Muse Code 1.4.6 turns contributor mode on by default for subscribers. From 1.4.8, with that mode on, Muse Code routes a family that has a `-contributor` model to it, whichever id `spawn.sh` passes. Ember has none, and Meta does not say what contributor mode does to an Ember run. Turn it off in Muse Code. This machine's `~/.config/muse/settings.json` shows the setting as `contributor_mode_enabled`.

The CLI defaults to `high`. `none` fails on Meta models. On 2026-10-12 the API refused `max` on Spark 1.2 and listed minimal through xhigh. `ultra` is a Muse Code setting, not an API value. It sends the model's highest level, or `xhigh` where the model has no higher one, and it makes Muse Code delegate more. On 2026-10-13 this account's Muse Code printed `gate ultra_reasoning_effort is closed; using xhigh` for every Muse model.

| Effort | What Meta says |
|---|---|
| minimal | Shortest reasoning pass. |
| low | Light reasoning. Direct-answer tasks. |
| medium | Moderate depth. |
| high | Deep reasoning. The CLI default. Multi-step code generation, architecture trade-offs, planning. |
| xhigh | Deeper reasoning, an optional premium-precision level. |
| max | Extended reasoning beyond xhigh, with more tokens at the same per-token price. |
| ultra | Muse Code only. The model's highest level, with more delegation. |

Published scores that name an effort. These are not one shared test.

| Model | Benchmark | Score | Effort on that score |
|---|---|---:|---|
| Muse Wonder Full | Terminal-Bench 4.0 (Artificial Analysis run) | 57.1% | max |
| Muse Wonder | Terminal-Bench 4.0 (Artificial Analysis run) | 52.0% | max |
| Muse Wonder Full | DeepSWE v1.1 | 79.0% | max |
| Muse Wonder | DeepSWE v1.1 | 78.8% | max |
| Muse Wonder Full | SWE-Marathon | 57.5% | xhigh |
| Muse Wonder | SWE-Marathon | 53.1% | max |
| Muse Wonder Full | ProgramBench (mini-swe-agent) | 59.0% | max |
| Muse Wonder | ProgramBench (mini-swe-agent) | 50.0% | max |
| Muse Wonder | CursorBench 4.0 | 50.4% | max |
| Muse Wonder | CursorBench 4.0 | 46.1% | high |
| Muse Wonder | CursorBench 4.0 | 45.2% | medium |
| Muse Wonder | CursorBench 4.0 | 41.7% | low |
| Muse Ember | Terminal-Bench 4.0 (Artificial Analysis run) | 40.9% | max, mini-swe-agent harness |
| Muse Ember | FrontierCode 2.0 (Artificial Analysis run) | 27.2% | max |
| Spark 1.3 | DeepSWE v1.1 | 75.4% | max, mini-swe-agent harness |
| Spark 1.2 | DeepSWE v1.1 | 55.0% | xhigh |
| Spark 1.3 | Terminal-Bench 2.1 | 88.8% | max |
| Spark 1.3 | Terminal-Bench 2.1 | 89.2% | xhigh |
| Spark 1.2 | Terminal-Bench 2.1 | 82.9% | xhigh |
| Spark 1.3 | CursorBench 4.0 | 41.6% | max |
| Spark 1.3 | CursorBench 4.0 | 33.4% | high |
| Spark 1.3 | CursorBench 4.0 | 29.3% | low |

The Muse Wonder CursorBench rows come from Cursor's table. The other Wonder and Wonder Full rows are read from Meta's launch scorecard image. Every column on it is labeled `(max)`, except the Wonder Full SWE-Marathon cell, which is labeled `(xhigh)`. Meta says SWE-Marathon's Claude and GPT rows ran in Claude Code and Codex, so that row is not one shared harness. On the same card, Opus 5.5 at max scores 59.6 on Terminal-Bench 4.0 and 70.5 on ProgramBench, above both Wonder Full rows. Meta's Ember scorecard runs every model at max. On it, Haiku 5.5 at max scores 34.9 on FrontierCode 2.0, above Ember. Ember is not on CursorBench. No FrontierCode score is published for Spark or Wonder.

Sources: https://dev.meta.ai/docs/models, https://dev.meta.ai/docs/pricing-rate-limits, https://dev.meta.ai/docs/reasoning, https://dev.meta.ai/docs/muse-code/configuration, https://research.meta.ai/blog/muse-wonder, https://research.meta.ai/static/muse-wonder-model-card, https://x.com/AIatMeta/status/2109691150932025836 (scorecard), https://research.meta.ai/static/muse-spark-1-3-multimodal-evaluation-methodology, and https://cursor.com/cursorbench (accessed 2026-10-12; Wonder rows accessed 2026-10-27). Wonder Full id and plans: https://dev.meta.ai/models/muse-wonder (accessed 2026-10-13). Muse Ember: https://dev.meta.ai/docs/muse-ember, https://dev.meta.ai/docs/pricing-rate-limits, https://dev.meta.ai/docs/muse-code/subscriptions, and https://research.meta.ai/blog/muse-ember with its scorecard at https://x.com/AIatMeta/status/2119853595453702580 (accessed 2026-11-11).

## Antigravity (`agy`) and Cursor CLI (`cursor`)

Both CLIs serve a plan-dependent catalog from several vendors. The registry names three agy models. Any other id passes through with `--backend agy` or `--backend cursor`, for example `--backend agy --model gemini-4-neon-xhigh`. Without `--backend`, an unlisted id is refused as unknown. A passed-through id is checked only for safe characters. For agy, `--effort` is checked against agy's CLI-wide list. For Cursor, `--effort` is checked only for safe characters.

| Say | Id | Efforts | Plan |
|---|---|---|---|
| Gemini 4 Neon, Neon | `gemini-4-neon` | low, medium, high, xhigh | paid Google AI Pro or trial on an eligible device, Ultra, Enterprise |
| Gemini 4 Hydrogen, Hydrogen | `gemini-4-hydrogen` | low, medium, high, xhigh | non-trial Google AI Pro, Ultra, Enterprise |
| Gemini 4 Argon, Argon | `gemini-4-argon` | low, medium, high | paid Google AI Pro or trial on an eligible device, Ultra, Enterprise |

Antigravity bills by plan quota and AI credits, not per token, so there is no price column. All three default to `medium`. The app shows `xhigh` as Extra. Gemini 4 Carbon needs Google AI Ultra or Enterprise. Google Workspace plans include no Antigravity plan.

agy also offers Orchestrator ids (`gemini-pro-orchestrator-neon`, `gemini-pro-orchestrator-g1-pro` for Argon), which pair a planner with Hydrogen as executor and take no effort. The registry does not name them.

On 2026-11-23, after the account moved to Google AI Pro, agy 1.5.15 listed Neon, Argon, Hydrogen, both Orchestrator pairings, Gemini 3.8 Flash, Claude Opus 5.5 and Sonnet 5.5, and GPT-OSS 120B. It listed no Carbon and no Claude 4.6. Through `spawn.sh`, each of the three answered a hello-world prompt. Neon and Hydrogen wrote a file. The page says Claude 4.6 and GPT-OSS 120B leave Antigravity on 2026-11-30.

`agy models` lists ids with the effort built in, such as `gemini-4-neon-xhigh` or `gemini-3.8-flash-high`. Such an id takes no `--effort`. To choose the effort with `--effort`, pass the base id, such as `gemini-4-neon`. The CLI help lists `low`, `medium`, `high`, `xhigh`, and `max` (agy 1.5.15), but each model takes only some of them, and agy names the allowed set when you pass another one. Cursor has no separate effort flag. When you pass `--effort`, the spawn command writes it into the model id as `[effort=...]`, which `cursor-agent --help` documents.

The catalog lags a plan change. For about 20 minutes after the 2026-11-23 upgrade, roughly one `agy models` call in four still returned the free-tier list. Runs then failed at random with "not recognized as a known model", "--effort is not supported for model", "empty conversation id", or `NOT_FOUND (code 404)`, even after the report was written. A refused Gemini 4 id looks like a typo. The plan or the rollout can cause that. Run `agy models` a few times before you call it a CLI bug or a wrong id. Sources: https://antigravity.google/docs/models/, https://antigravity.google/docs/plans/ (accessed 2026-11-23).

List Cursor models with `cursor-agent --list-models`. The binary is `cursor-agent`. On this platform `agent` is often Grok, not Cursor.
