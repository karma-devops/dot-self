# MIGRATE — dot-self v0.5.x → v0.6.0

**For rooms already living** (installed at v0.5.0–v0.5.2). Your identity, logs, diary, and growth are untouched by this upgrade. Nothing is deleted. Two files change; one is new.

---

## What v0.6 fixes (why you are doing this)

Two of these were measured on a live production room on 2026-09-18:

| Bug | Symptom |
|---|---|
| **Counter never resets** | Turn numbers keep climbing across sessions forever (one room reached Turn 242 spread over 7 unrelated sessions) |
| **`unknown` bucket** | 24% of all turns (75 of 313) landed in one shared `unknown` session — callers that pass no session id |
| Header duplicate date | `## Turn 5 — 2026-09-18 2026-09-18_1430` |
| No named discipline loop | The turn protocol was unnamed, with no explicit stop conditions |

## What changes

| File | Action |
|---|---|
| `configs/pulse.sh` | **REPLACE** with the v0.6 version |
| `morality.example.md` | **NEW** — a stub for you and your operator to fill (optional; pulse ignores it until renamed to `morality.md`) |
| `state/turn-count` | Legacy global counter — **ignored by v0.6**, safe to leave |
| `state/turn-count.<sid>` | New per-session counters, created automatically |
| everything else | **untouched** |

---

## Upgrade steps

**1. Back up first (always):**
```bash
cp .self/configs/pulse.sh .self/configs/pulse.sh.v0.5.bak
```

**2. Replace the runtime:**
```bash
# from your dot-self repo checkout at v0.6.0:
cp /path/to/dot-self/configs/pulse.sh .self/configs/pulse.sh
chmod +x .self/configs/pulse.sh
```

**3. Add the morality stub (optional but recommended):**
```bash
cp /path/to/dot-self/template/morality.example.md .self/morality.example.md
```

**4. Verify without writing:**
```bash
bash .self/configs/pulse.sh --dry-run
```
Expect: `[discipline] ANRCP — PULSE → CONTEXT → …` and `State (v0.6): per-session counters…`

**5. First real pulse — confirm the fix:**
```bash
SID="$(bash .self/configs/find-session.sh)"
bash .self/configs/pulse.sh "$SID" "upgraded to v0.6" "clean" "continue" "steady" "counter integrity restored"
grep '^## Turn' .self/past/logs/*"${SID}"*.md
```
The new session's first turn is **Turn 1** — even if the room's history goes back hundreds of turns. That is the fix.

**6. Optional cleanup (only after a week of clean running):**
```bash
rm .self/state/turn-count           # legacy global counter, unused by v0.6
```

---

## What does NOT happen

- Your `past/logs/` are not rewritten. Old turn numbers stay as they were written.
- Your `past.md` index is not touched.
- Your `agent-self.md`, diary, journal, growth, sanctum — all untouched.
- Old `unknown`-named logs remain in place (they are real history). v0.6 prevents *new* ones; it does not rewrite old ones.

## Rollback

```bash
cp .self/configs/pulse.sh.v0.5.bak .self/configs/pulse.sh
```
Everything else v0.6 added is additive and harmless to v0.5.

---
*v0.6.0 — counter integrity + ANRCP + morality stub. Upgrading a room is a five-minute copy, not a rebuild.*