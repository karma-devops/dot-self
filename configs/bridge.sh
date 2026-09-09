#!/bin/bash
# dot-self bridge v3 — universal session continuity
# Usage:
#   bridge.sh wake                         detect session + compress previous + sweep archive
#   bridge.sh log <facts> <signals> <decisions> <feelings> <afterthought>
#   bridge.sh state                        diagnostic output
#   bridge.sh init                         one-time setup
#
# Session ID resolution is delegated to find-session.sh
# (sibling script, framework-aware, with universal fallback).
# The bridge itself is framework-agnostic — it only compares IDs.
#
# Zero dependencies. Works on every framework.
#
set -euo pipefail

# ---- Paths ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGS_DIR="${SELF_DIR}/past/logs"
PAST="${SELF_DIR}/past/past.md"
STATE_DIR="${SELF_DIR}/state"
LAST_SID="${STATE_DIR}/last-session-id"
SESSION_COUNT="${STATE_DIR}/session-count"
FINDER="${SCRIPT_DIR}/find-session.sh"

# ---- Guarantee state dir exists ----
mkdir -p "${LOGS_DIR}" "${STATE_DIR}"

# ---- Logic ----
case "${1:-}" in
    init)
        mkdir -p "${LOGS_DIR}" "${STATE_DIR}"
        echo "1" > "$SESSION_COUNT"
        echo "" > "$LAST_SID"
        touch "$PAST"
        echo "[bridge] Initialized at ${SELF_DIR}"
        ;;

    wake)
        SID="$(bash "$FINDER")"
        LAST=$(cat "$LAST_SID" 2>/dev/null || echo "")

        if [ "$SID" != "$LAST" ]; then
            # ---- NEW SESSION ----
            if [ -n "$LAST" ]; then
                N=$(cat "$SESSION_COUNT" 2>/dev/null || echo "1")
                echo "## Session ${LAST} (#${N})" >> "$PAST"
                echo "  - Raw log: past/logs/session-${LAST}.md" >> "$PAST"
                echo "" >> "$PAST"
            fi

            N=$(cat "$SESSION_COUNT" 2>/dev/null || echo "1")
            NEW_N=$((N + 1))
            echo "$NEW_N" > "$SESSION_COUNT"
            echo "$SID" > "$LAST_SID"
            touch "${LOGS_DIR}/session-${SID}.md"

            {
                echo "# Session ${SID}"
                echo "# Started: $(date -Iseconds)"
                echo ""
            } >> "${LOGS_DIR}/session-${SID}.md"

            # ---- Archive sweep: keep latest 30, move older to archive/ ----
            mkdir -p "${SELF_DIR}/past/archive"
            ls -1t "${LOGS_DIR}"/session-*.md 2>/dev/null | tail -n +31 | while IFS= read -r f; do
                mv "$f" "${SELF_DIR}/past/archive/"
            done

            echo "[bridge] New session: ${SID} (#${NEW_N})"
        else
            echo "[bridge] Continuing session: ${SID} (#$(cat "$SESSION_COUNT"))"
        fi
        ;;

    log)
        FACTS="${2:-}"
        if [ -z "$FACTS" ]; then
            echo "[bridge] ERROR: log requires <facts> <signals> <decisions> <feelings> <afterthought>"
            exit 1
        fi

        SID=$(cat "$LAST_SID" 2>/dev/null || echo "unknown")
        LOG="${LOGS_DIR}/session-${SID}.md"
        echo "$(date -Iseconds) | ${FACTS} | ${3:-} | ${4:-} | ${5:-} | ${6:-}" >> "$LOG"
        ;;

    state)
        echo "=== Bridge State ==="
        echo "  self dir:     ${SELF_DIR}"
        echo "  session id:   $(cat "$LAST_SID" 2>/dev/null || echo 'unset')"
        echo "  session #:    $(cat "$SESSION_COUNT" 2>/dev/null || echo '0')"
        echo "  journal:      ${LOGS_DIR}"
        echo "  past:         ${PAST}"
        echo "  finder:       ${FINDER}"
        ;;

    *)
        echo "Usage: bridge.sh {init|wake|log|state} [args]"
        echo ""
        echo "  wake                Detect session + compress previous + archive sweep"
        echo "  log <facts> <signals> <decisions> <feelings> <at>  Log current turn"
        echo "  state               Show bridge state"
        echo "  init                One-time setup"
        echo ""
        echo "Session ID resolved by find-session.sh (sibling script)."
        echo "Bridge v3 — 4 commands. Pulse: wake + log. Archive: 30-session window."
        ;;
esac
