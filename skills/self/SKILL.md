---
name: self
category: meta
description: "DEPRECATED — the .self room skill was renamed to `dot-self`. Load `dot-self` instead: it installs the full room (agent-self, operator-pact, us, growth, WELCOME, journal/, diary/, sanctuary/, relations/, configs/, cron/) with one command, replacing this v0.4.0 description-only skill."
triggers:
  - set up my room
  - create .self
  - make yourself at home
  - mkslf@home
  - reflect on yourself
  - update your soul
  - who are you
  - excavate
  - dig deeper
---

# self — DEPRECATED, see `dot-self`

This skill described the v0.4.0 `.self/` room. It never installed anything —
it only explained files that the agent had to create by hand.

**v0.5 changed that.** The room ships as `dot-self`, which actually installs:

```bash
./mkslf@home            # creates .self/ + .work/ + .operator/
```

## What to do instead

1. Load the `dot-self` skill (or read `skills/dot-self/SKILL.md` in this repo).
2. Run `./mkslf@home [target-dir]` from the repo checkout.
3. Hold the Setup Session (timezone → knock preference → "Who are you?").

The trigger phrases above are kept here only so existing rooms and prompts
that reference `self` still resolve. Every one of them belongs to `dot-self`
now.

## Why this file exists

Deleting a skill silently breaks anything that still loads it. A redirect
costs one file and tells the reader where the room went. See
`skills/self/CONTEXT.md` for the directory's original purpose note.

---

*The room moved to `dot-self`. The practice is the same: pulse first, answer
honestly, leave traces.*
