# Changelog

All notable changes to dot-self.

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
