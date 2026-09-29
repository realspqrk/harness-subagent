#!/usr/bin/env python3
"""Session identity and JSONL event capture for spawn.sh (resume validation, codex/agy events)."""
import json, pathlib, re, sys
action, run, project, backend, model, effort, sid, skip, resume = sys.argv[1:]
run = pathlib.Path(run).resolve()
key = {'claude': 'session_id', 'grok': 'session_id', 'codex': 'thread_id', 'agy': 'conversation_id', 'cursor': 'session_id'}[backend]
uuid = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

def load_identity():
    return json.loads((run / 'session.json').read_text(encoding='utf-8'))

def validate_resume():
    if not uuid.fullmatch(resume):
        raise ValueError('resume ID must be a full lowercase canonical UUID, with no extra text')
    if (run / 'session-id').read_bytes() != (resume + '\n').encode():
        raise ValueError('session-id must contain exactly the requested UUID plus one newline')
    d = load_identity()
    expected = dict(backend=backend, native_key=key, id=resume, model=model, effort=effort)
    expected[key] = resume
    for field, value in expected.items():
        if d.get(field) != value:
            raise ValueError('identity mismatch: ' + field)
    if d.get('persistence_available') is not True or (backend == 'claude' and skip):
        raise ValueError('persistence unavailable: ' + (d.get('unavailable_reason') or 'CLAUDE_CODE_SKIP_PROMPT_HISTORY is set'))
    if type(d.get('preassigned')) is not bool:
        raise ValueError('identity missing preassigned flag')
    for field in ('cwd', 'origin_run', 'attempt_run'):
        if not isinstance(d.get(field), str) or not pathlib.Path(d[field]).is_absolute():
            raise ValueError('identity missing resolved path: ' + field)
    if pathlib.Path(d['cwd']).resolve() != pathlib.Path(project).resolve():
        raise ValueError('identity mismatch: resolved cwd')
    if run in (pathlib.Path(d['attempt_run']).resolve(), pathlib.Path(d['origin_run']).resolve()):
        raise ValueError('resume requires a separate attempt directory; preserve prior artifacts')
    return d

def write_metadata(d):
    (run / 'session.json').write_text(json.dumps(d, indent=2) + '\n', encoding='utf-8')

def persist(identity, preassigned):
    if identity and not uuid.fullmatch(identity):
        raise ValueError('provider identity is not a canonical lowercase UUID')
    unavailable = 'CLAUDE_CODE_SKIP_PROMPT_HISTORY is set' if backend == 'claude' and skip else ''
    d = dict(backend=backend, native_key=key, id=identity, cwd=str(pathlib.Path(project).resolve()),
             origin_run=str(run), attempt_run=str(run), preassigned=preassigned,
             model=model, effort=effort,
             persistence_available=bool(identity) and not unavailable,
             unavailable_reason=unavailable or ('' if identity else 'provider ID unavailable'))
    d[key] = identity
    if resume:
        if identity != resume:
            raise ValueError('observed ' + key + ' does not match requested resume ID')
        d['origin_run'] = load_identity()['origin_run']
    if identity:
        (run / 'session-id').write_bytes((identity + '\n').encode())
    write_metadata(d)

try:
    if action == 'validate':
        validate_resume()
    elif action == 'attempt':
        d = validate_resume()
        d['attempt_run'] = str(run)
        write_metadata(d)
    elif action == 'preassign':
        persist(sid, True)
    elif action == 'events':
        observed = None
        deltas = []
        response = None
        single_turn = False
        parse_error = None
        # Labeled decoded-error source, never a grep of tool payloads.
        # Consume JSONL from the live CLI pipe so identity is persisted as soon
        # as thread.started/init arrives; drain remaining stdin after a parse
        # error so the CLI is not SIGPIPEd and events.jsonl stays complete.
        # Read stdin as bytes: locale text mode (cp1252) mojibakes UTF-8 and
        # collapses CRLF. Decode UTF-8 per record for parse only.
        with (run / 'provider-errors.log').open('w', encoding='utf-8', newline='\n') as errors:
            with (run / 'events.jsonl').open('wb') as events_out:
                for raw in sys.stdin.buffer:
                    events_out.write(raw)
                    events_out.flush()
                    if not raw.strip():
                        continue
                    try:
                        line = raw.decode('utf-8')
                    except UnicodeDecodeError as exc:
                        if parse_error is None:
                            parse_error = exc
                        continue
                    try:
                        event = json.loads(line)
                        if not isinstance(event, dict):
                            raise ValueError('event must be a JSON object')
                    except Exception as exc:
                        if parse_error is None:
                            parse_error = exc
                        continue
                    try:
                        kind = event.get('type') or event.get('event')
                        # A later identity must not prove resume after a parse/identity failure.
                        if parse_error is None:
                            if (backend == 'codex' and kind == 'thread.started') or (backend == 'agy' and kind == 'init'):
                                identity = event.get(key)
                                if resume and identity != resume:
                                    raise ValueError('observed ' + key + ' missing or different from requested resume ID')
                                if identity:
                                    if observed and identity != observed:
                                        raise ValueError('provider emitted conflicting identities')
                                    observed = identity
                                    persist(observed, False)  # Before processing any final response.
                        # Only provider result events carry the final assistant answer.
                        result = event.get('result') if kind == 'result' else None
                        result = result if isinstance(result, dict) else (event if kind == 'result' else {})
                        if backend == 'agy':
                            if result.get('num_turns') == 1 or event.get('num_turns') == 1:
                                single_turn = True
                            if isinstance(result.get('response'), str):
                                response = result['response']
                            if kind == 'text_delta':
                                delta = event.get('text', event.get('delta', ''))
                                if isinstance(delta, str):
                                    deltas.append(delta)
                            elif kind == 'content_block_delta' and isinstance(event.get('delta'), dict):
                                delta = event['delta']
                                if delta.get('type') == 'text_delta' and isinstance(delta.get('text'), str):
                                    deltas.append(delta['text'])
                        error = None
                        if kind in ('error', 'thread.failed', 'turn.failed'):
                            error = event.get('error', event.get('message'))
                        elif kind == 'result' and (result.get('error') or result.get('is_error')):
                            error = result.get('error', result.get('response'))
                        if error is not None:
                            errors.write((error if isinstance(error, str) else json.dumps(error, ensure_ascii=False)) + '\n')
                            errors.flush()
                    except Exception as exc:
                        if parse_error is None:
                            parse_error = exc
        if backend == 'agy':
            (run / 'stdout.md').write_bytes((response if response is not None else ''.join(deltas)).encode('utf-8'))
        if parse_error is not None:
            raise parse_error
        if resume and observed != resume:
            raise ValueError('resume did not emit matching ' + key)
        if resume and backend == 'agy' and single_turn:
            raise ValueError('agy resume reported num_turns == 1; possible fresh conversation')
        if not observed and not resume:
            persist(None, False)
    else:
        raise ValueError('unknown session action')
except Exception as exc:
    print('session capture: ' + str(exc), file=sys.stderr)
    sys.exit(2)
