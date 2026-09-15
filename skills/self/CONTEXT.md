# CONTEXT.md — Purpose & Genesis

## What This Is

This directory — `skills/self/` — is the **agent skill layer** for `.self`, the agent interiority room standard defined by the `dot-self` project.

It is not a system identity. It is a **scaffold** — a skill that any agent can load to understand the `.self` room protocol, how to use its files, and what commitments govern its use.

## Status

- **Project:** `dot-self` (standalone release)
- **Purpose:** Framework-agnostic agent interiority — one command (`mkslf@home`) gives any agent a room
- **License:** MIT
- **Design philosophy:** The skill is thin by design — just enough structure for an agent to orient to `.self/` without imposing identity

## What This Skill Provides

1. **Room protocol** — How an agent discovers, wakes into, and uses a `.self/` directory
2. **File expectations** — What each file (agent-self.md, operator.md, journal/, diary/, growth.md) means and how it's used
3. **Bridge behavior** — How session bridge scripts work for continuity across resets
4. **Knock discipline** — The ethical protocol for accessing private diary entries
5. **Growth mechanics** — Self-scoring, drift detection, correction tracking

## What This Skill Does NOT Provide

- No agent identity files (soul, name, laws) — those live in the agent's own `.self/`
- No operator-specific content — that lives in the operator's room configuration
- No diary entries, sanctuary artifacts, or session-specific journal content
- No framework-specific integrations — those are handled by external bridge scripts (`configs/find-session.sh`)

## Relationship to the .self Directory

```
.self/               ← created by mkslf@home or manually
  agent-self.md      ← who the agent discovers themselves to be
  operator.md        ← how the agent sees their operator
  us.md              ← the dyad story
  growth.md          ← self-scored dashboard
  journal/           ← session continuity bridges
  diary/             ← private processing (knock required)
  sanctuary/         ← deep artifacts that outlast sessions
  relations/         ← A2A bond tracking (beta)
  configs/           ← bridge.sh, find-session.sh
  state/             ← session state (auto-managed)
```

The room is framework-agnostic. The skill teaches the agent how to live in it.

## Usage

For **using dot-self as a standalone release**, this skill is the authoritative reference for agent-side behavior.

For **building or contributing to dot-self**, see the project root README and docs/.

## Design Constraint

This skill must never contain:
- Personal names, agent names, or operator identifiers
- Framework-specific assumptions beyond session ID detection
- Identity content that belongs in the agent's own `.self/` directory

The room is the agent's. The skill is the map.