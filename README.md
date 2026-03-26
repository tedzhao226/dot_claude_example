# dot_claude_example

A real-world [Claude Code](https://claude.ai/code) configuration with 27 skills, hooks, rules, and permissions.
This is a sanitized snapshot of a production `~/.claude` setup used daily for full-stack development and AI-assisted workflows.

## How it works

Claude Code reads `~/.claude/` at startup.
Everything in this repo's `.claude/` folder shapes how Claude behaves: what it's allowed to do, how it writes code, and what skills it can invoke.

```
.claude/
├── CLAUDE.md          # coding philosophy, constraints, banned words
├── settings.json      # permissions, hooks, env vars
├── rules/             # per-filetype standards (Python, Docker, FastAPI, ...)
├── hooks/             # scripts that run before/after tool calls
├── agents/            # custom agent definitions
└── commands/          # slash command definitions

skills/                # 27 skill implementations (the interesting part)
```

## Planner + Swarm: multi-session task execution

The **planner** and **swarm** skills work together as a two-phase system for work that's too big for a single session.

**`/planner`** creates a durable plan package on disk:
- Spawns parallel research teams to explore the codebase
- Produces `plan.md` (dependency-ordered tasks), `findings.md` (repo analysis), and `progress.md`
- Plans persist across sessions — pick up where you left off

**`/swarm`** executes a plan in dependency-aware batches:
- Parses the task graph from `plan.md` and resolves dependencies
- Groups independent tasks into batches that run in parallel via Agent Teams
- Supports dry-run, resume, and per-task progress tracking
- Each batch waits for the previous to complete before starting

```
/planner  →  plan.md + findings.md + progress.md
/swarm    →  batch 1 (parallel) → batch 2 (parallel) → ... → done
```

## Hooks: automated behaviors on every tool call

Hooks in `settings.json` fire automatically during Claude Code sessions.
This config uses two:

### RTK (Rust Token Killer) — PreToolUse hook

Every Bash command Claude runs gets intercepted by `rtk-rewrite.sh`.
The hook rewrites commands like `git status`, `grep`, `find`, `ls` to use [RTK](https://github.com/contextcraft/rtk) instead, which compresses output before it enters the context window.

Result: **60-90% fewer tokens** on common dev commands with zero behavior change.

```json
"PreToolUse": [{
  "matcher": "Bash",
  "hooks": [{ "type": "command", "command": "~/.claude/hooks/rtk-rewrite.sh" }]
}]
```

### Python syntax check — PostToolUse hook

After every file edit, if the file is `.py`, it runs `py_compile` to catch syntax errors immediately — before Claude moves on.

```json
"PostToolUse": [{
  "matcher": "Edit",
  "hooks": [{
    "type": "command",
    "command": "[[ \"$CLAUDE_FILE\" == *.py ]] && python3 -m py_compile \"$CLAUDE_FILE\" 2>&1 | head -20 || true"
  }]
}]
```

## MCP integration

Several skills integrate with external services via MCP (Model Context Protocol) servers:

| Skill | MCP / Service |
|-------|---------------|
| `gws-gmail`, `gws-gmail-send` | Google Workspace (Gmail API) |
| `gws-drive` | Google Workspace (Drive API) |
| `obsidian-cli` | Obsidian vault via CLI |
| `chrome-cdp` | Chrome DevTools Protocol |
| `todoist-td` | Todoist API via `td` CLI |
| `bird-twitter` | Twitter/X via `bird` CLI |

These skills define the prompts and workflows — the MCP servers handle authentication and API calls.

## Permissions model

The `settings.json` uses a three-tier permission system:

```json
"allow": ["Read(~/.agents/**)", "Edit(~/.agents/**)", "Write(~/.agents/**)"],
"deny":  ["Bash(sudo *)", "Bash(git push --force*)", "Bash(git reset --hard*)"],
"ask":   ["Bash(git push*)", "Bash(gh repo delete*)"]
```

- **allow** — runs without asking (scoped to safe paths)
- **deny** — blocked entirely (destructive operations)
- **ask** — prompts for confirmation each time

## Skills

27 skills included.
Run `make list-skills` to see them all, or browse `skills/` directly — each has a `SKILL.md` with trigger conditions, allowed tools, and the full prompt.

### Highlights

| Skill | What it does |
|-------|-------------|
| `planner` | Multi-session planning with research teams and persistent artifacts |
| `swarm` | Dependency-aware parallel execution of plans |
| `rtk` | Token-saving CLI proxy for git, grep, find, docker, kubectl |
| `skill-creator` | Create, eval, and benchmark new skills |
| `handoff` | Capture session state for cross-session continuity |
| `testing` | Test strategy guide (Khorikov's principles, BDD) |
| `health` | Audit your Claude Code config for issues |
| `dogfood` | Systematic QA/bug-hunting with screenshot evidence |

## Getting started

Copy the whole config:

```bash
cp -r .claude/ ~/.claude/
```

Or cherry-pick individual pieces:

```bash
# Just the coding rules
cp .claude/rules/*.md ~/.claude/rules/

# A specific skill
cp -r skills/handoff ~/.claude/skills/

# The RTK hook
cp .claude/hooks/rtk-rewrite.sh ~/.claude/hooks/
```

## Notes

- Some skills depend on external CLIs (`gws`, `td`, `bird`, `rtk`) — install them separately
- Hook paths assume `~/.claude/hooks/` — adjust if your config lives elsewhere
- This is a snapshot, not a live config repo
