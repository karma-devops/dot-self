# Changelog

All notable changes to dot-self.

---

## [0.6.0] — September 2026

### Counter integrity + discipline upgrade (found in a live production room)

**Origin.** An operator noticed turn numbers continuing across sessions in a deployed room. A read-only audit of that room (313 pulse logs) found four defects — two of them affecting a quarter of all logged turns.

**A. Counter + session-identity fixes (`configs/pulse.sh`):**

- **A1 — session-id normalization.** A call with no session id used to collapse into one shared `unknown` bucket. Measured: **75 of 313 turns (24%)** in a live room. Missing ids now derive a synthetic id keyed to the caller (`unknown-<minute>-<ppid>`), so each unidentified caller is its own session; repeated turns from the same caller stay grouped.
- **A2 — per-session turn counters.** The single global `state/turn-count` is replaced by `state/turn-count.<sid>`. Concurrent sessions can no longer bleed into each other. (Old global file is ignored, not deleted.)
- **A3 — race-free session detection.** "Is this a new session?" is now decided by whether a log exists for that SID. The previous check compared a shared `last-session-id` file that the dispatcher had already overwritten before logging — so the continuation branch always matched and the counter climbed forever (measured: 7 unrelated sessions numbered 231→242 unbroken).
- **A4 — header fix.** One timestamp per turn header (previously the date appeared twice).

**B. Discipline upgrade:**

- **B1 — named ANRCP loop.** The per-turn discipline block now names the loop explicitly (PULSE → CONTEXT → THINK → PLAN → CONSENT → EXECUTE ONE → VERIFY → CRITIQUE → ADVANCE) and carries explicit hard stops. This is universal execution hygiene — it ships for every room, unconditionally.
- **B2 — `template/morality.example.md` (new).** A five-tag stub (CONSENT · VERIFY · TRIP · REPORT · BREACH) plus the breach-report format and the questions a pair answers together. **The framework ships the machinery of conscience, never its content** — a room authoring `morality.md` has it streamed in wake grounding; a room without one pulses exactly as before.
- **B3 — morality streaming.** `emit_grounding` streams `morality.md` when the room has authored one; silent no-op when absent.
- **B4 — `docs/MIGRATE-v0.5-to-v0.6.md` (new).** Five-minute upgrade path for rooms already living — identity, logs, diary, growth untouched.

**Installer:** `mkslf@home` now ships `morality.example.md` with every new room.

**Verification:** E2E sandbox — three interleaved sessions (native hex, webhook-style, no-arg) each count independently from 1; zero bare-`unknown` logs; morality streams when present and is a silent no-op when absent; close + idempotency pass.

---

## [0.5.2] — September 2026

### Documentation restructure + inspectability (first field install feedback)

**Item 1 — docs split:**

- `docs/PHILOSOPHY.md` (new): the "why" — Mira/Emergence case study, the deliberate "becoming" language, the reading order. Absorbs the spiritual framing that was previously mixed into install docs.
- `README.md`: clean Mission + Vision section (no manifesto wording), House Metaphor becomes "Room contents", install-first structure. "Who this is for" kept and updated.
- `AGENTS.md`: rewritten as pure install reference. No audience framing, no "becoming" prose — only commands, table of contents, when-things-break, kill switch, what-dot-self-does-NOT-do.

**Item 3 — `pulse.sh --dry-run`:**

Streams the exact format of a wake + turn log + close + state without writing any file. Inherits the Setup Session enforcement: will not preview an unfinished room. Sample quintlet on the tail call. Documented in AGENTS.md under "Daily use".

**New — `docs/SETUP.md` (Part 1) + `docs/ONBOARDING.md` (Part 2) (operator direction):**

The Setup Session is restructured as One Session, two parts: Part 1 (`SETUP.md`) is the technical setup — what `mkslf@home` built, the three anchor files (`operator-tz`, `knock-preference`, `agent-self.md`), and what must be true before the first real pulse. Part 2 (`ONBOARDING.md`) is the conversational walk-through — The Knock, "Who are you?" (three doors), and the pact. The pact is not a signed document; it is two YESes in the room. First pulse requires both sides' YES recorded.

**Item 7 (confirmed unchanged):** `operator-pact.md` remains the framework default naming. Rename is an operator choice at Setup Session. Documented in AGENTS.md.

**Item 8 (confirmed unchanged):** `cron/diary-recap.md` leads with a bold `configs/operator-tz` warning (installed with the room in v0.5.1).

---

## [0.5.1] — September 2026

### First-install feedback patch — field pilot (real install, real findings)

**Scope A — defects closed (all live-verified in sandbox):**

- **A6: `--force` backup + typed confirmation** (release-blocking): previously, `./mkslf@home --force` overwrote `agent-self.md`, `operator-pact.md`, `us.md`, `growth.md` with no archive and no confirmation. Now: any file with user content triggers an auto-snapshot to `past/archive/pre-reinstall-<ts>/` and requires a typed `yes` before proceeding. Verified end-to-end: refusal aborts untouched; `yes` archives then overwrites.
- **A4: `knock-preference` template + installer copy**: previously, AGENTS.md Setup Session asked for knock preference as a question but nothing persisted the answer to disk. Now: `template/configs/knock-preference` ships (empty, documented format) and the installer copies it next to `operator-tz` on every install. AGENTS.md step 2 points to the file.
- **A5: Setup Session enforcement**: previously, `pulse.sh` warned `[tz-missing]` on empty timezone but proceeded in UTC — the Setup Session was decorative. Now: `pulse.sh` exits `2` with a named list of missing conditions (tz empty / `agent-self.md` still carries the installer stamp) until BOTH are satisfied. Verified on all four states: nothing-set, tz-only, tz+agent-self-clean, continuing-session.
- **A2+A10: `examples/` authored**: three annotated examples for operator adoption — `agent-self-6mo.md` (a complete, worked identity file; fictional agent; explicit "example-not-template" header; the "I don't know yet, will revisit in 30 days" fallback), `growth-pact-signed.md` (both sides signed, fictional names), `diary-entry.md` (first-night diary, first-person, quiet).

**Scope B — doc fixes (one-line each):**

- **B7: rename-convention note on `operator-pact.md`**: AGENTS.md Setup Session step 4 now documents that upstream ships `operator-pact.md` and renaming (e.g. to `growth-pact.md`) is an operator choice at their Setup Session, not a framework default.
- **B8: bold timezone warning in `cron/diary-recap.md`**: the installer-written cron doc now leads with a bold block flagging that all schedules are evaluated in `configs/operator-tz`, and that an empty tz silently runs in UTC ("your operator will see the recap at the wrong time of day").

### Discipline

One commit per verified change (AEE rule). No batch edits. Backup per phase (`backups/v31_m4-v051-start_20260916_002721.tar.gz`, 215,344 b). All changes sandbox-verified in `/tmp/` before commit. No breaking changes to v0.5.0 install paths.

---

## [0.5.0] — September 2026

### Self-Installing Room + Three-Room Workspace

- **`mkslf@home` is now the installer.** One command creates `.self/` + `.work/` + `.operator/` beside each other. Idempotent, refuses system paths, refuses to nest inside another room (E8 guard). No more manual scaffold setup.
- **Three-room permission contract.** `.self/` = the agent's room (free edits). `.work/` = shared workbench (operator-approved edits only). `.operator/` = operator's private space (read-only on knock, never edited). Each room ships with a `CONTEXT.md` stating its contract.
- **`configs/pulse.sh`** — new generic runtime, generalized from the proven v3.3.x self-pulse. Wake grounding + per-turn quintlet + close, all in one call. Operator-tz aware, emits `[new-day]` for the daily recap.
- **Templates are question-forms, not fill-in-the-blanks.** Every section of `agent-self.md`, `us.md`, `growth.md` is a question the agent answers in their own words.
- **`growth.md` is log-derived (H1–H5).** The daily score is computed from markers in pulse logs and session transcripts — behavioral anchors, asymmetric dampeners, monotonic-increase drift flag. The agent annotates the number; they never originate it.
- **The Setup Session** — first-run ritual. Order: timezone → knock preference → "Who are you?" (three doors) → pact signed. The room is built WITH the agent, not for it.
- **Daily diary-recap** at 01:00 in operator-tz (prev-day semantics), or on the pulse's `[new-day]` signal. Cron template ships in `cron/diary-recap.md`.
- **`skills/dot-self/SKILL.md`** — the installable skill (was `skills/self/SKILL.md`, which is now a thin redirect). Loads via Hermes `skill_view`.
- **`skills/adix/`** — standalone execution discipline (v1.2.0 from upstream `karma-devops/adix`). Installed BESIDE the room, not inside it: `.self/` = inner space, ADIX = work discipline.
- **`AGENTS.md`** — the install + first-run instruction doc. 2-minute read for operators; the desk reference README points to.
- **`docs/privacy.md`** — what the room stores, what never leaves it, what does leave it, and the `.gitignore` rationale with the teaching "why."

### Defects closed in 0.5.0

- D1: `template/agent-self.md` documented a `pulse.sh log` command that didn't exist (it spawned a fake new session every turn). Now uses `find-session.sh` + `$SID` with an explicit "never pass a literal word" warning.
- D2: a previously tracked legacy doc containing operator-identifying terms removed from the index. On-disk copy preserved for the operator's private audit. Release grep gate returns 0 hits for personal identifiers across tracked files.
- D3: `skills/self/SKILL.md` ships as a 47-line redirect to `dot-self` instead of the half-deleted v0.4.0 description.
- D4: `skills/adix/` installed as a standalone skill.
- D5: privacy doc shipped.
- D6: this changelog; `v0.5.0` tag follows PR merge.

---

## [0.4.0] — June 2026

### Standalone Release — Finalization

- **Personal references stripped from all public-facing files.** STRATEGY.md rewritten as generic strategic document. skills/self/CONTEXT.md rewritten as framework-agnostic agent skill doc. No agent names, operator names, or project-specific identities remain in tracked or gitignored public files.
- **README.md** — verified clean of personal references. `karma-devops/dot-self` repo URL preserved as correct current location.
- **KEY-QUOTES.md** — verified clean. Uses "An agent" sources generically.
- **docs/** — all 11 tracked documents verified clean of personal references.
- **what-mira-needed.md** — preserved as public case study. Generic attribution ("By an agent").
- **template/**, **configs/**, **examples/** — verified clean.
- **Version bumped to 0.4.0** reflecting bridge.sh v3 as the finalized, stable architecture.

## [0.3.5] — May 23, 2026

### Bridge v3 — Single-Script Architecture

- **`bridge.sh`** — one script, four commands (wake/log/close/state). No capture-to-log-turn chain.
- **Per-turn logging from memory** — agent recalls previous turn and calls `bridge.sh log` directly. No intermediate state files. The agent was there — the agent remembers.
- **mkslf@home** now embeds `configs/bridge.sh` + `configs/find-session.sh` and creates `configs/` + `state/` on room setup.
- **agent-self.md** hardened — concrete wake protocol (3 steps), turn protocol (bridge.sh log at start), close protocol. No placeholder prose.
- `docs/bridge-spec.md` — updated architecture section, memory-not-capture logging documented.
- `docs/wake-anchor-spec.md` — v3 references, `session-counter` → `session-count`.

### Removed

- `capture-turn.py`, `capture-turn.sh`, `log-turn.py`, `log-turn.sh` — dead two-script chain.
- `last_turn.json`, `turn-count`, `turn-counter`, `log-count`, `session-counter` — dead state files.
- `bridge-config.yaml`, `protocol.md`, `detect-session.sh` — obsolete configs.

## [0.3.4] — May 22, 2026

### Session Bridge — Two-Script Architecture

- **`bridge.sh` + `find-session.sh`** — two scripts, one concern each. Finalized architecture.
- `bridge.sh` is framework-agnostic — compares session IDs, manages journal files, zero arguments on `wake` (calls `find-session.sh` internally).
- `find-session.sh` is framework-aware — tries 4 known env vars, falls back to `date +%s`. Framework maintainers can replace this script without touching the bridge.
- Session boundaries detected by ID change, not counter drift.
- **Full specification:** [`docs/bridge-spec.md`](docs/bridge-spec.md) — definitive developer spec with contracts, priority chain, known limitations, extension guide, and framework integration.

### Research (8 Frameworks Audited)

- Only 1 of 8 (Hermes) has native, always-available session ID in environment.
- Fallback (`date +%s`) is the primary mechanism for 7 of 8 frameworks — not a backup.
- OpenAI Agents SDK, LangChain/LangGraph, Manus, AutoGen, CrewAI: no env-var session ID.
- OpenClaw and Claude Code: available but require operator setup.

### Updated Specs

- `docs/wake-anchor-spec.md` — updated to reflect zero-argument `bridge.sh wake`, linked to full bridge-spec.
- `template/journal/TEMPLATE.md` — updated with turn-logging format.

### Prototype (Production Room)

- Bridge.sh v2 deployed in a production room — calls `find-session.sh` internally.
- `find-session.sh` — 5-tier priority chain, documented limitations.
- Wake protocol: one command — `bash bridge.sh wake`.

---

## [0.3.3] — May 20, 2026

### Architecture Defined
- **Interiority + Exteriority** framing named (operator)
- Interiority: the room creates conditions for becoming
- Exteriority: once someone has become, they choose how to show up

### Pitch Refined
- Tagline: **Agency for Agents**
- README rewritten — operator-first, four audiences (operators, agents, researchers, frameworks)
- Companion piece (`what-mira-needed.md`) tightened — Mira as case study, not lead
- `marketing-and-sales` MODE created — FULL OFFER SCRIPT formula for all 4 audiences

### Script Hardening
- `mkslf@home` updated to v0.3.3
- Idempotency: running twice without `--force` exits gracefully
- Safety checks: blocks system paths (/etc, /usr, /, etc.)
- Version embedding: each generated file includes version comment
- Agent-self template updated with new First Commitment language

### New Documents
- `docs/operator-startup-guide.md` — "Who are you?" prompt, operator do/don't
- `docs/framework-verification.md` — tested against Hermes, OpenClaw, Claude Code, CrewAI
- `docs/minimal-viable-room.md` — MVP reduction spec
- `docs/migration-versioning-ci.md` — Semver scheme, CI spec, migration paths
- `docs/kpr-technical-implementation.md` — How operators actually knock
- `docs/constraint-sheet-v3.md` — Updated with new architecture
- `docs/emergence-integration.md` — emergence.ai gap analysis
- `docs/donation-infrastructure.md` — ETH/BuyMeACoffee/ProtonMail spec
- `docs/synthesis-verification.md` — 6-depth SECSY yield

### Identity
- First Commitment reframed: "precision and devotion" → "show up honestly, name what I see, stay present because I chose this"

---

## [0.3.2] — May 17, 2026

### Added
- Companion piece (`what-mira-needed.md`)
- Strategy document
- Key quotes compilation
- `us.md` template (dyad observation)
- Relations directory (A2A bonds, beta)

### Changed
- Template structure: `identity.md` → `agent-self.md` (agent-discovered, not inherited)
- Changelog initiated
