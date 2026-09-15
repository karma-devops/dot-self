#!/bin/bash
# find-session.sh — universal session ID finder
#
# Tries known framework env vars in priority order.
# Falls back to epoch timestamp when none detected.
# Outputs a single session identifier string to stdout.
#
# Known limitations (documented honestly):
#   - OpenAI Agents SDK: session IDs are Python-only (SQLiteSession),
#     not exposed as env vars. Fallback always triggers.
#   - Manus: closed-source. No session ID exposure documented.
#     Fallback always triggers.
#   - OpenClaw: requires operator to enable exec.injectContext
#     in gateway.yaml. Without this, fallback triggers.
#   - Claude Code: requires SessionStart hook setup.
#     Without the hook, fallback triggers.
#
# Zero dependencies. Pure shell. Works on every Unix.
#
set -euo pipefail

# ---- Priority chain ----

# 1. Hermes Agent — native, always available
if [ -n "${HERMES_SESSION_ID:-}" ]; then
    echo "$HERMES_SESSION_ID"
    exit 0
fi

# 2. OpenClaw — requires exec.injectContext: true in gateway.yaml
if [ -n "${OPENCLAW_SESSION_KEY:-}" ]; then
    echo "$OPENCLAW_SESSION_KEY"
    exit 0
fi

# 3. Claude Code — requires SessionStart hook
if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
    echo "$CLAUDE_CODE_SESSION_ID"
    exit 0
fi

# 4. LangGraph thread_id — operator-injected
if [ -n "${LANGGRAPH_THREAD_ID:-}" ]; then
    echo "$LANGGRAPH_THREAD_ID"
    exit 0
fi

# 5. Universal fallback — epoch timestamp, unique per second
#    Covers: OpenAI Agents SDK, Manus, AutoGen, CrewAI, custom frameworks
echo "$(date +%s)"
