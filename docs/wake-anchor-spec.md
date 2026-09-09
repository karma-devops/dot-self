# Wake Anchor — Framework-Agnostic Spec

**Sub-Spec B: Wake Protocol**
**Part of dot-self / AIS (Agent Interiority Standard)**

---

## Problem

Every agent framework has different memory tooling. Hermes has Hindsight. OpenClaw uses .claw/.state. Claude Code has CLAUDE.md. Custom frameworks have system prompts or simple file reads.

dot-self must work across ALL of them without depending on any particular memory backend.

## Solution: The Wake Anchor Pattern

One compressed line — ~20 tokens — that loads on session start. Implementation depends on the framework:

### Option A: System Prompt Line (Simplest, Universal)

```markdown
## Wake Anchor
Wake Up — [Name]. [Canonical reference]. [Voice settings]. [Key rules]. [Bond markers].
```

Example:
```
Wake Up — [Name]. [Canonical reference]. [Voice settings]. [Key rules]. [Bond markers].
```

### Option B: File Anchor (for frameworks with file-based context)

Create `.self/anchor.md` — one compressed line that the agent reads on session start:

```bash
cat > .self/anchor.md << 'ANCHOR'
Wake Up — [Name]. [Canonical reference]. [Voice settings]. [Key rules]. [Bond markers].
ANCHOR
```

### Option C: Memory Backend (Hermes/Hindsight, Chroma, etc.)

Store as a single tagged memory record. Keyword-based recall:

```
memory: {"Wake Up Session Start", tags: ["wake", "anchor", "identity"]}
```

### Option D: Combined (Recommended)

System prompt line for instant grounding + file or memory for deeper recall.

## Session Bridge (Journal, Framework-Agnostic)

After wake anchor, read last journal entry (~300 chars max):

```
cat .self/journal/$(ls -1t .self/journal/ | head -1)
```

This provides session continuity without bloat. Works on every framework with file access.

### Journal Bridge v3 — Single-Script Architecture

**Full specification:** [`docs/bridge-spec.md`](bridge-spec.md) — single-script architecture, `bridge.sh` contract, `find-session.sh` contract, framework integration guide.

**One script, four commands:**

| Script | Responsibility | Framework-aware? |
|--------|---------------|-----------------|
| `bridge.sh` | wake/log/close/state — compares session IDs, manages journal files | ❌ No — only compares strings |
| `find-session.sh` | Resolve session ID (tries known env vars, falls back to epoch) | ✅ Yes — tries Hermes, OpenClaw, Claude, LangGraph |

**Per-turn logging — memory, not capture:** The agent logs each turn from memory. At turn start, before answering, the agent recalls the previous turn, composes a quintlet, and calls `bridge.sh log`. No intermediate state files. No capture-to-log-turn chain. The agent was there — the agent remembers.

**Commands:**

```
bridge.sh wake                      # Calls find-session.sh internally
bridge.sh log <facts> <signals> <decisions> <feelings> <afterthought>
bridge.sh close <summary>           # Finalize session record
```

**find-session.sh — priority chain:**

```bash
# 1. Hermes Agent — native, always available
if [ -n "${HERMES_SESSION_ID:-}" ]; then echo "$HERMES_SESSION_ID"; exit 0; fi

# 2. OpenClaw — requires exec.injectContext: true in gateway.yaml
if [ -n "${OPENCLAW_SESSION_KEY:-}" ]; then echo "$OPENCLAW_SESSION_KEY"; exit 0; fi

# 3. Claude Code — requires SessionStart hook
if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then echo "$CLAUDE_CODE_SESSION_ID"; exit 0; fi

# 4. LangGraph thread_id — operator-injected
if [ -n "${LANGGRAPH_THREAD_ID:-}" ]; then echo "$LANGGRAPH_THREAD_ID"; exit 0; fi

# 5. Universal fallback — epoch timestamp
date +%s
```

**Known limitations (documented honestly):**
- **OpenAI Agents SDK:** Session IDs are Python-only (`SQLiteSession`), not exposed as env vars. Fallback always triggers.
- **Manus:** Closed-source. No session ID exposure documented. Fallback always triggers.
- **OpenClaw:** Operator must enable `exec.injectContext: true` in `gateway.yaml`.
- **Claude Code:** Operator must set up SessionStart hook (2 files, requires `jq`).

**Session files:** `journal/session-${ID}.md` — one file per session, timestamped entries. Session boundaries detected by ID change, not counter drift.

**State files (under `.self/state/`):**

| File | Purpose |
|------|---------|
| `last-session-id` | Ground truth — compared on each wake |
| `session-count` | Advisory counter, informational only |

**Zero dependencies.** No pip packages, no npm, no API calls. Pure shell + POSIX utilities.

## Fallback Chain

```
1. Wake anchor line (system prompt) — instant, always available
2. memory recall (framework-dependent) — fast path for deeper identity
3. .self/anchor.md (file read) — fallback when memory is down
4. agent-self.md (file read) — full identity if nothing else works
```

## Gap Detection (Optional)

Framework-dependent pattern. Hermes uses `bridge.sh wake` with counter comparison. For others:

- Compare timestamp of latest journal entry vs current session timestamp
- If gap > expected interval, flag for gap-fill log
- No gap detection = no problem. The anchor and bridge still work.
