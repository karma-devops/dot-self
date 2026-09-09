# Session Bridge — Definitive Specification

**Part of dot-self / AIS (Agent Interiority Standard)**
**Version:** 1.0.0
**Date:** May 22, 2026
**Status:** Stable — reference implementation deployed

---

## 1. Purpose

The session bridge solves one problem: **an agent cannot detect whether it is continuing an existing session or starting a new one.** Every agent framework ships tools, memory, and context. None ships session-aware identity continuity. The bridge fills that gap.

## 2. Architecture

The bridge is **one script** with **four commands:**

```
bridge.sh                   .self/
(framework-agnostic)         (filesystem)
    │                            │
    ├── wake ──────────────► state/
    │                        ├── last-session-id
    ├── log  ──────────────► ├── session-count
    │                        │
    ├── close ──────────────► journal/
    │                        └── session-${ID}.md
    └── state
                                 │
                                 past.md
```

**Session ID resolution** is delegated to `find-session.sh` (sibling script, framework-aware). The bridge doesn't care *how* the ID was found — it only compares strings.

### Per-Turn Logging — Memory, Not Capture

The agent logs each turn from **memory**, not from a capture file. At turn start, before answering, the agent recalls the previous turn's input + output, composes a quintlet, and calls `bridge.sh log`. No intermediate state files. No capture-to-log-turn chain. The agent was there — the agent remembers.

**This is the architectural change (v3):** the old two-script capture→log-turn cycle introduced a single point of failure (did the agent remember to call capture?). Now there is only `bridge.sh log` — called directly, from memory, at turn start.

### Separation of Concerns

| Script | Responsibility | Framework-aware? | May change when... |
|--------|---------------|-----------------|-------------------|
| `find-session.sh` | Resolve a session identifier string | **Yes** — tries known env vars, falls back to epoch | New frameworks add native session IDs |
| `bridge.sh` | Compare IDs, manage journal files, log entries, close sessions | **No** — only compares strings | Never (complete at its layer) |

**Key insight:** The bridge doesn't care *how* the session ID was found. It only cares whether it matches the last one. This means framework maintainers can ship their own `find-session.sh` — the bridge is unaffected.

### Why Two Scripts

1. **Replaceability.** A framework maintainer replaces `find-session.sh` without touching the bridge.
2. **Testability.** Session ID resolution is tested independently from state management.
3. **Honesty.** The framework-aware layer documents its own limitations without polluting the bridge.

## 3. find-session.sh — Contract

### Input
None. Reads environment variables only.

### Output
A single session identifier string to stdout. No side effects.

### Priority Chain

```
1. $HERMES_SESSION_ID        — Hermes Agent (native, always available)
2. $OPENCLAW_SESSION_KEY     — OpenClaw (requires exec.injectContext: true)
3. $CLAUDE_CODE_SESSION_ID   — Claude Code (requires SessionStart hook)
4. $LANGGRAPH_THREAD_ID      — LangGraph (operator-injected)
5. date +%s                  — Universal fallback (always works)
```

### Known Limitations (Documented Honestly)

| Framework | Limitation |
|-----------|-----------|
| **OpenAI Agents SDK** | Session IDs are Python-only (`SQLiteSession`). No env var. Fallback always triggers. |
| **Manus** | Closed-source. No session ID exposure documented. Fallback always triggers. |
| **AutoGen** | No native session ID mechanism. Fallback always triggers. |
| **CrewAI** | No documented session identifier. Fallback always triggers. |
| **OpenClaw** | Requires operator to enable `exec.injectContext: true` in `gateway.yaml`. Without this, fallback triggers. |
| **Claude Code** | Requires SessionStart hook (2 files, needs `jq`). Without the hook, fallback triggers. |

### The Fallback Is the Primary

**Only 1 of 8 major frameworks (Hermes) has a native, always-available session ID.** For the other 7, the universal fallback (`date +%s`) is the primary mechanism — not a backup. This is by design. The bridge treats all IDs equally; it compares strings, not origins.

### Extension Guide

When a new framework adds native session ID support, add one line to `find-session.sh`:

```bash
# N. NewFramework — native as of vX.Y
if [ -n "${NEWFRAMEWORK_SESSION_ID:-}" ]; then
    echo "$NEWFRAMEWORK_SESSION_ID"
    exit 0
fi
```

No other file changes. The bridge doesn't need to know.

## 4. bridge.sh — Contract

### Commands

```
bridge.sh wake                      Detect new/continuing session
bridge.sh log <facts> <signals> <decisions> <feelings> <afterthought>
                                    Log a decision during session
bridge.sh close <summary>           Finalize session record
bridge.sh state                     Diagnostic output
bridge.sh init                      One-time initialization
```

### wake — Session Detection

1. Calls `find-session.sh` to resolve current session ID.
2. Compares against `state/last-session-id` (ground truth).
3. If IDs differ: new session detected. Archives prior session to `past.md`, increments `session-count`, creates new `journal/session-${ID}.md`.
4. If IDs match: continuing session. No action.

**Session boundaries are detected by ID change — not by counter, not by timestamp drift, not by manual flags.**

### log — Decision Logging

Appends a timestamped entry to the current session journal:

```
YYYY-MM-DDTHH:MM:SS+TZ | <facts> | <signals> | <decisions> | <feelings> | <afterthought>
```

No turn counter. Entries are self-ordering by timestamp.

### close — Session Finalization

Appends a compression summary to both `past.md` and the session journal. Marks the session as closed.

### State Files

| File | Purpose | Type |
|------|---------|------|
| `state/last-session-id` | Ground truth — compared on each wake | String |
| `state/session-count` | Advisory counter, informational only | Integer |
| `journal/session-${ID}.md` | Per-session raw log | Timestamped entries |

## 5. Constraints

- **Framework-agnostic.** Works on Hermes, Claude Code, OpenClaw, LangGraph, AutoGen, CrewAI, OpenAI Agents SDK, Manus, and any custom framework with a Unix shell.
- **Zero dependencies.** No pip, npm, API calls, or external binaries beyond POSIX.
- **Filesystem only.** All state under `.self/state/` and `.self/journal/`.
- **Survives container restarts.** `.self/` must reside on a persistent volume.
- **One command, zero arguments.** `bridge.sh wake` — nothing more.

## 6. Integration

### Hermes Agent (Native)

Add to `self.md` wake protocol:

```markdown
## 2. Wake Protocol (First Action Every Session)
1. Run `bash .self/configs/bridge.sh wake`.
2. If new session: read `past.md`, then read prior session log.
3. Read `agent-self.md` for identity grounding.
4. Begin normal operation.
```

### All Other Frameworks

Same protocol. The bridge doesn't distinguish. `find-session.sh` handles the framework; `bridge.sh` handles the state.

### What Framework Maintainers Should Do

Expose a session identifier as an environment variable:
- Name: `$FRAMEWORK_SESSION_ID` (convention)
- Value: unique per session, stable within a session
- Available: in the agent's subprocess environment

Then add one line to `find-session.sh`. That's it.

## 7. Reference Implementation

A production room runs this bridge on a supported framework. Files:

```
.self/
├── configs/
│   ├── bridge.sh          # Framework-agnostic bridge
│   └── find-session.sh    # Framework-aware session ID finder
├── state/
│   ├── last-session-id    # Ground truth
│   └── session-count      # Advisory counter
├── past.md                # Durable session summaries
└── past/logs/
    └── session-${ID}.md   # Per-session raw logs
```

## 8. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-05-22 | Initial release. Two-script architecture finalized. `bridge.sh wake` takes zero arguments (calls `find-session.sh` internally). |
