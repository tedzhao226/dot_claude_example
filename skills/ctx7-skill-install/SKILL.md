---
name: ctx7-skill-install
description: Install or reinstall third-party skills through the local dot_skills workflow. Use when the user asks to add a skill, reinstall a third-party skill, sync skill exposure across Codex/OpenCode/OpenClaw/Claude, or verify where third-party skills install in this setup.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# ctx7-skill-install

Use this skill for the local third-party skill-management workflow in `dot_skills`.

## Current Install Location

In this setup, third-party skills are physically installed into:

`~/.agents/skills`

`~/workspace/p/dot_skills/.agents/skills` is the repo-facing symlinked view of that directory.

## Install One Skill

1. Confirm the skill exists in `skills.toml`.
2. Confirm `kind = "third_party"`.
3. Install from `skills.toml`:

- If `install_url` is set, fetch that raw `SKILL.md`
- Otherwise run raw `ctx7` with the declared source and skill name

```bash
cd ~/workspace/p/dot_skills
make install-skill SKILL=<skill-name>
```

4. This should:
- install into `~/.agents/skills/<skill-name>`
- surface at `dot_skills/.agents/skills/<skill-name>` through the repo symlink
- then run `make sync`
- rebuild Codex/OpenCode/OpenClaw/Claude views

If `make sync` says `dot_skills/.agents/skills` is not a symlink yet, run `make bootstrap` once to migrate the older repo-local layout.

## Add a New Third-Party Skill

1. Add the skill entry to `skills.toml`
2. Set the intended CLI booleans
3. If the skill comes from a raw `SKILL.md`, set `install_url`
4. Run `make install-skill SKILL=<skill-name>`
4. Verify the live tool skill sets match the declared tools

## Verification

Use exact-set verification, not just counts:
- expected names from `skills.toml`
- actual names in:
  - `~/.codex/skills/`
  - `~/.config/opencode/skills/`
  - `~/.openclaw/skills/`
  - `~/.claude/skills/`

If a skill is installed but not visible, check:
- `skills.toml` booleans
- `make sync` output
- whether `~/workspace/p/dot_skills/.agents/skills` points to `~/.agents/skills`
- the generated tool directory entry
