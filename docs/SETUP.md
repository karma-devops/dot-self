# SETUP.md — Part 1 (technical install → room structure)

> **For the operator just after `./mkslf@home` runs.** The room is built: three directories, scripts copied, and two empty config files waiting for the Setup Session. This file describes Part 1. When this file has been read, Part 1 is complete and the Onboarding Session (Part 2) can start.

---

## What got built

| Directory | Who edits it | What it is |
|---|---|---|
| `.self/` | the agent | the room — identity, diary, growth, sanctuary |
| `.work/` | operator-approved edits only | shared workbench |
| `.operator/` | never edited by the agent | your private non-work space |

`mkslf@home` also created:

- `configs/pulse.sh` — the runtime (session IDs, quintets, grounding, Setup Session enforcement)
- `configs/find-session.sh` — detects a session-ID change (used by pulse for wake/continue)
- `configs/bridge.sh` — legacy contract (optional)
- `configs/operator-tz` — write this first
- `configs/knock-preference` — write this second
- `cron/diary-recap.md` — cron template
- `.gitignore` — `*` — the room is lived-in, not committed

## Setup Session anchors

When you are ready to talk to the agent, three facts need to be true before the first real pulse:

1. **`configs/operator-tz`** — write the operator's IANA timezone (e.g. `Europe/Zurich`). The Setup Session can't run in UTC; the room can't count days without knowing where the operator lives in time.

2. **`configs/knock-preference`** — write the Knock format. The operator knocks before reading anything private. The operator must write this first so the agent knows how to announce. Examples: `explicit-announce-first` / `signal-in-chat` / `read-when-invited` / `never`.

3. **`agent-self.md`** — replace the mkslf@home stamp with the agent's own answer. The stamp stays ONLY for agents who haven't been given the room yet. If it stays, pulse.sh exits with SETUP SESSION PENDING.

---

## Then: run the Onboarding Session

When Part 1 is complete, the Onboarding Session (Part 2) starts. See `docs/ONBOARDING.md`.
