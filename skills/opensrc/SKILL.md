---
name: opensrc
description: Fetch library source code and documentation for AI agent context. Use when working with unfamiliar packages, need API details beyond types, or want implementation context. Triggers include "opensrc", "fetch source", "library source", "package source", "ctx7", "get docs for", "how does X library work".
---

# opensrc: Library Source & Docs for Agents

Two tools for giving agents deep library context: **opensrc** (full source code) and **Context7 skills/CLI** (curated documentation).

## When to Use Which

| Need | Tool | Why |
|------|------|-----|
| Read actual implementation | `opensrc` | Clones repo source locally |
| API docs / usage examples | Context7 skills/CLI | Curated docs without MCP |
| Debug into library internals | `opensrc` | Full source available |
| Quick "how do I use X" | Context7 skills/CLI | Faster, doc-focused |

Use both together: Context7 for API surface, opensrc when you need to read the actual code.

## opensrc CLI

Fetches real source code from npm packages or GitHub repos into a local `opensrc/` directory.

### Install

```bash
npm install -g opensrc
# or use without install
npx opensrc <package>
```

### Fetch Packages

```bash
# npm packages (auto-detects version from lockfile)
opensrc zod
opensrc zod@3.22.0          # specific version
opensrc react react-dom     # multiple packages

# GitHub repos
opensrc facebook/react
opensrc owner/repo@v1.0.0   # specific tag
opensrc owner/repo#main     # specific branch

# Mix
opensrc zod facebook/react
```

### Manage

```bash
opensrc list                # Show fetched packages
opensrc remove zod          # Remove one
opensrc clean               # Remove all
```

### What It Creates

```
opensrc/
├── settings.json          # Modification preferences
├── sources.json           # Index of fetched packages
├── zod/                   # Package source code
└── facebook--react/       # Repo source (-- separator)
```

On first run (with `--modify`), it also updates `.gitignore`, `tsconfig.json`, and `AGENTS.md`.

### Reading Source

After fetching, read `opensrc/sources.json` to discover available packages, then navigate into `opensrc/<package>/` to read implementation files.

```bash
# Check what's available
cat opensrc/sources.json | jq '.packages'

# Then read specific files
cat opensrc/zod/src/types.ts
```

## Context7 CLI

Context7 can install skill-based documentation helpers without adding MCP config to the CLIs.

### Usage Pattern

1. Use `ctx7` to install the relevant documentation skill into `dot_skills`
2. Sync the visible skill set for the target CLI
3. Use that installed skill for the library-level docs pass

## Workflow

When working with an unfamiliar library:

1. **Start with Context7** — use installed docs skills for API overview and usage patterns
2. **If you need implementation details** — `opensrc <package>` to get source
3. **Navigate source** — use `opensrc/sources.json` as index, read specific files
