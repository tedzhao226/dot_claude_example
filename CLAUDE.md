# dot_claude_example

Example Claude Code (`~/.claude`) configuration with skills, hooks, rules, and permissions.

## Structure

```
dot_claude_example/
├── .claude/
│   ├── CLAUDE.md          # global coding instructions
│   ├── RTK.md             # Rust Token Killer meta commands
│   ├── settings.json      # permissions, hooks, env vars
│   ├── agents/            # custom agent definitions
│   ├── commands/          # slash command definitions
│   ├── hooks/             # hook scripts (RTK rewrite)
│   └── rules/             # per-filetype coding standards
├── skills/                # skill implementations (27 skills)
├── CLAUDE.md              # this file
└── Makefile
```

## Usage

Copy `.claude/` into your home directory to use as a starting point:

```bash
cp -r .claude/ ~/.claude/
```

Or cherry-pick individual pieces (rules, skills, hooks) into your existing config.

## Skills

Run `make list-skills` to see all included skills.
Some skills depend on external CLIs (e.g. `gws`, `td`, `bird`, `rtk`) and won't work without them installed.
