# Models

Spoken names resolve to these ids. Prices are USD per million tokens, standard rate, short context, as published on 2026-09-22, plus Sonnet 5.5 on 2026-09-29 and GPT-6.1 Sol on 2026-09-30. A higher effort does not change the per-token rate. It spends more tokens, and those tokens are billed at the output rate.

Pass `--effort` yourself. If you omit it, the CLI uses its own default.

## Claude Code (`claude`)

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Opus 5.5, Opus | `claude-opus-5-5` | 4 | 20 | low, medium, high, xhigh, max |
| Fable 5.1, Fable | `claude-fable-5-1` | 10 | 50 | low, medium, high, xhigh, max |
| Opus 5 | `claude-opus-5` | 5 | 25 | low, medium, high, xhigh, max |
| Fable 5 | `claude-fable-5` | 10 | 50 | low, medium, high, xhigh, max |
| Sonnet 5.5, Sonnet | `claude-sonnet-5-5` | 2 | 10 | low, medium, high, xhigh, max |
| Sonnet 5 | `claude-sonnet-5` | 2 | 10 | low, medium, high, xhigh, max |
| Haiku 4.5, Haiku | `claude-haiku-4-5-20251001` | 1 | 5 | none |

Opus 5.5 shipped 2026-09-22. Sonnet 5.5 shipped 2026-09-28 and needs Claude Code 2.1.284 or later. On the Anthropic API the short aliases `opus` and `sonnet` point at Opus 5.5 and Sonnet 5.5. This skill passes the full id. Saying Sonnet selects Sonnet 5.5. Opus 5, Fable 5, and Sonnet 5 are still served and stay under their versioned names.

Sonnet 5.5 recalibrates its effort levels relative to Sonnet 5, so an effort that suited Sonnet 5 is not the same spend on Sonnet 5.5. Claude Code defaults Opus 5.5 and Sonnet 5.5 to `medium`. The Claude Platform API defaults Sonnet 5.5 to `high`.

Vendor descriptions, from the Claude Code model docs (accessed 2026-09-29).

| Effort | What Anthropic says |
|---|---|
| low | Quick exchanges you review each result of, such as brainstorming, a first sketch, or a rename. |
| medium | The default on Opus 5.5 and Sonnet 5.5. Day-to-day work with a clear scope, such as implementing a feature. On other models it trades some intelligence for fewer tokens. |
| high | Work where verification matters or edge cases are likely, such as fixing a bug in an existing codebase. The default on Fable 5.1, Fable 5, Opus 5, and Sonnet 5. |
| xhigh | Deeper reasoning, higher token spend. |
| max | Hard problems you want worked through without you. May show diminishing returns and overthinking. |

Published scores that name an effort.

| Model | Benchmark | Score | Effort on that score |
|---|---|---:|---|
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

Sonnet 5.5 scores lower on FrontierCode at max than at xhigh. Anthropic's footnote says that at max it more often ran a multi-subagent code review, which led to timeouts or edits beyond the task. The medium and high Sonnet 5.5 rows come from the per-effort cost charts on the announcement page, not its headline table.

Sources: https://platform.claude.com/docs/en/about-claude/pricing, https://code.claude.com/docs/en/model-config, https://www.anthropic.com/news/claude-opus-5-5, and https://www.anthropic.com/claude-sonnet-5-5 (accessed 2026-09-29)

## Codex (`codex`)

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Astra | `gpt-6-astra` | 10 | 50 | low, medium, high, xhigh, max, ultra |
| Sol, GPT-6.1 Sol | `gpt-6.1-sol` | 2 | 10 | low, medium, high, xhigh, max, ultra |
| GPT-6 Sol | `gpt-6-sol` | 2 | 10 | low, medium, high, xhigh, max, ultra |
| Luna, GPT-6 Luna | `gpt-6-luna` | 0.10 | 0.50 | low, medium, high, xhigh, max |
| GPT-5.6 Sol | `gpt-5.6-sol` | 4 | 20 | low, medium, high, xhigh, max, ultra |
| Terra, GPT-5.6 Terra | `gpt-5.6-terra` | 2 | 12 | low, medium, high, xhigh, max, ultra |
| GPT-5.6 Luna | `gpt-5.6-luna` | 0.20 | 1.20 | low, medium, high, xhigh, max |
| GPT-5.5 | `gpt-5.5` | 5 | 30 | low, medium, high, xhigh |
| GPT-5.4 | `gpt-5.4` | 2.50 | 15 | low, medium, high, xhigh |

GPT-6.1 Sol shipped 2026-09-29 at the GPT-6 Sol price. The codex-cli 0.159.2 catalog lists it. Saying Sol selects `gpt-6.1-sol`. Saying Luna selects `gpt-6-luna`. GPT-6 Sol, GPT-5.6 Sol, and GPT-5.6 Luna are still served and stay under those versioned names. There is no GPT-6.1 Astra, GPT-6.1 Luna, or GPT-6 Terra as of 2026-09-30, so Terra still selects `gpt-5.6-terra`. GPT-5.4 is retired for ChatGPT sign-in as of 2026-08-31. GPT-5.6 Sol's 4/20 price is promotional at least through 2026-11-21. Prices above are standard short-context rates. Ultra is a product mode that runs parallel agents. It is not a separate per-token price. The API pages for GPT-6 Sol and Luna also list `none` and default to medium. The GPT-6.1 Sol API page lists low through max, without `none`, and defaults to medium. This CLI's catalog does not list `none`. It does list `ultra` for Astra, GPT-6.1 Sol, and GPT-6 Sol. In codex-cli 0.159.2 the catalog default effort is `low` for GPT-6.1 Sol and `medium` for Astra and GPT-6 Sol.

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
| GPT-6.1 Sol | DeepSWE v1.1 | 75.2% | high |
| GPT-6 Sol | DeepSWE v1.1 | 68.8% | max, called its best score |
| GPT-6.1 Sol | FrontierCode v1.1 | 58.1% | low |
| GPT-6.1 Sol | FrontierCode v1.1 | 60.4% | medium, named in the cost sentence |
| GPT-6 Sol | FrontierCode v1.1 | 50.5% | low |
| GPT-6.1 Sol | OSWorld 2.0 offline | 71.4% | max |
| Astra | OSWorld 2.0 offline | 73.5% | max |
| GPT-6.1 Sol | AutomationBench | 31.7% | medium |
| Astra | Terminal-Bench 4.0 | 57.9% | maximum across efforts, winning effort not named |
| GPT-5.6 Sol | Terminal-Bench 4.0 | 37.3% | maximum across efforts, winning effort not named |
| GPT-5.5 | Terminal-Bench 2.0 | 82.7% | xhigh |
| GPT-5.4 | Terminal-Bench 2.0 | 75.1% | xhigh |

Sources: https://developers.openai.com/api/docs/pricing, https://developers.openai.com/api/docs/models/gpt-6-sol, and https://developers.openai.com/api/docs/models/gpt-6-luna (accessed 2026-09-23), and https://developers.openai.com/api/docs/models/gpt-6.1-sol (accessed 2026-09-30). Earlier scores: https://openai.com/index/gpt-6-astra/ and https://openai.com/index/introducing-gpt-5-5/ (accessed 2026-09-22). GPT-6.1 Sol scores: OpenAI Developers posts https://x.com/OpenAIDevs/status/2104993067942219873 and https://x.com/OpenAIDevs/status/2104993086099398854, and Cognition, which maintains FrontierCode, at https://devin.ai/blog/gpt-6-1-sol (accessed 2026-09-30). OpenAI's launch charts plot score against cost without labeling the effort on each point, so no score is read from them. No Luna score is copied here, because its page did not publish one.

## Grok Build (`grok`)

Prices below are the global endpoint under 200k prompt tokens. At 200k and above, input and output double.

| Say | Id | Input | Output | Efforts |
|---|---|---:|---:|---|
| Grok 4.7 | `grok-4.7` | 2 | 6 | low, medium, high, xhigh |
| Grok 4.7 Fast | `grok-4.7-build-fast` | 4 | 12 | low, medium, high, xhigh |
| Grok 4.6 | `grok-4.6` | 2 | 6 | low, medium, high, xhigh |
| Grok 4.5 | `grok-4.5` | 2 | 6 | low, medium, high |

`grok-4.7-build-fast` is the id `grok models` printed on this class of machine on 2026-09-22. The public docs say "Grok 4.7 Fast" and do not print that slug. `xhigh` is documented for Grok 4.6 and later. The 4.5 card also lists it, and the 2026-09-21 reasoning guide says 4.5 treats `xhigh` as `high`.

| Benchmark | Grok 4.7 | Effort column |
|---|---:|---|
| CursorBench 4.0 | 46.3% | xHigh |
| DeepSWE v1.1 | 71.0% | high (starred cell) |
| Terminal-Bench 4.0 | 37.6% | xHigh |

Source: https://x.ai/news/grok-4-7 (2026-09-21) and https://docs.x.ai/developers/pricing (accessed 2026-09-22).

## Antigravity (`agy`) and Cursor CLI (`cursor`)

No fixed model list lives here. Pass the id the CLI accepts.

`agy models` lists ids with the effort built in, such as `gemini-3.8-flash-high`. Such an id takes no `--effort`. agy 1.2.13 rejects the pair as a conflict. To choose the effort with `--effort`, pass the base id, such as `gemini-3.8-flash`. The CLI help lists `low`, `medium`, `high`, and `max`, but each model takes only some of them. On 2026-09-29 `gemini-3.8-flash` took `low`, `medium`, and `high`, and `gemini-3.1-pro` took `low` and `high`. agy names the allowed set when you pass another one. Cursor has no separate effort flag. When you pass `--effort`, the spawn command writes it into the model id as `[effort=...]`, which `cursor-agent --help` documents.

List Cursor models with `cursor-agent --list-models`. The binary is `cursor-agent`. On this platform `agent` is often Grok, not Cursor.
