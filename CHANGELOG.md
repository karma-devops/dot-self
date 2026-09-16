# Changelog

All notable changes to dot-self.

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
