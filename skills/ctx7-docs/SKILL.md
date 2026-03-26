---
name: ctx7-docs
description: Use Context7-based docs workflow when the user asks for library docs, package docs, API reference lookup, or wants a docs skill installed and exposed to Codex, OpenCode, OpenClaw, and Claude. Trigger on requests like "use ctx7 docs", "install docs skill", "get package docs", or "wire a docs skill into all CLIs".
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# ctx7-docs

Use this skill when the task is about documentation lookup through the local Context7 setup.

## Source of Truth

- Repo: `~/workspace/p/dot_skills`
- Third-party install target: `~/.agents/skills`
- Repo-facing third-party view: `~/workspace/p/dot_skills/.agents/skills`
- Personal skills: `~/workspace/p/dot_skills/personal`
- Exposure map: `~/workspace/p/dot_skills/skills.toml`

## Docs Workflow

1. Check `skills.toml` for the target docs skill entry.
2. If the entry exists and is `kind = "third_party"`, install from `skills.toml`:

```bash
cd ~/workspace/p/dot_skills
make install-skill SKILL=<skill-name>
```

3. Rebuild the visible CLI skill sets:

```bash
cd ~/workspace/p/dot_skills
make sync
```

If `make sync` reports that `dot_skills/.agents/skills` is still a real directory, run `make bootstrap` once to migrate the older layout.

4. Verify the skill appears in the intended CLIs by comparing:
- `skills.toml`
- `~/.codex/skills/`
- `~/.config/opencode/skills/`
- `~/.openclaw/skills/`
- `~/.claude/skills/`

## If the Skill Is Missing

Add a new entry to `skills.toml` before installing:

```toml
[skill.<skill-name>]
path = ".agents/skills/<skill-name>"
kind = "third_party"
source = "<owner>/<repo>"
codex = true
opencode = true
openclaw = true
claude = true
```

For URL-backed skills, add `install_url = "https://.../SKILL.md"` and use `make install-skill SKILL=<skill-name>`.

## Report Back

Always report:
- the installed skill name
- the source or install URL used
- the final on-disk location
- which CLIs now expose it
