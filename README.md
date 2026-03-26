# dot_claude_example

Example [Claude Code](https://claude.ai/code) configuration showcasing skills, hooks, rules, and permissions.

## What's inside

| Directory | Description |
|-----------|-------------|
| `.claude/settings.json` | Permissions (allow/deny/ask), hooks, env vars |
| `.claude/CLAUDE.md` | Global coding instructions and constraints |
| `.claude/rules/` | Per-filetype coding standards (Python, Docker, FastAPI, etc.) |
| `.claude/hooks/` | Hook scripts (RTK token reduction, Python syntax check) |
| `.claude/agents/` | Custom agent definitions |
| `.claude/commands/` | Slash command definitions |
| `skills/` | 27 skill implementations |

## Skills included

Agent orchestration, Gmail/Drive integration, Obsidian vault management, Twitter/X, Todoist, planning/swarm workflows, testing strategy, and more.

```bash
make list-skills
```

## Getting started

Copy the whole config:

```bash
cp -r .claude/ ~/.claude/
```

Or pick individual pieces:

```bash
# Just the rules
cp .claude/rules/*.md ~/.claude/rules/

# A specific skill
cp -r skills/handoff ~/.claude/skills/
```

## Notes

- Some skills depend on external CLIs (`gws`, `td`, `bird`, `rtk`) and won't work without them
- `settings.json` hook paths assume `~/.claude/hooks/` — adjust if your config lives elsewhere
- This is a snapshot — not a live config repo
