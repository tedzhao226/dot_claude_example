---
name: handoff
description: "Capture session state into HANDOFF.md for cross-session continuity. Use when user says handoff, save context, pick up later, pause and resume, or after a swarm batch completes."
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Handoff

Capture current session state so the next session (or swarm phase) can resume without re-discovery.
Better than compaction because it's intentional, structured, and written while context is fresh.

## When to Use

- Session is getting long or context-heavy
- Switching between CLI tools (Claude Code ↔ OpenCode)
- Pausing work to resume later
- After a swarm batch completes, before the next batch
- Before `/clear` to preserve state

## Scenario Detection

1. If user passes `--swarm <plan-path>` → swarm mode with that path
2. If user passes `--session` → regular mode
3. Auto-detect:
   - Find most recent plan folder under `~/.agents/plan/` matching current repo
   - If its TOON block has `done` tasks alongside `pending` tasks → swarm mode
   - Otherwise → regular mode

## Output Location

| Scenario | Path |
|----------|------|
| Swarm | `<plan-folder>/HANDOFF.md` |
| Regular (git repo) | `<repo-root>/HANDOFF.md` |
| Regular (no repo) | `<cwd>/HANDOFF.md` |

If `HANDOFF.md` already exists at target → rename to `HANDOFF.prev.md` (one generation of history, git has the rest).

## Execution

### Step 1 — Gather Context

Run read-only commands:

```bash
git branch --show-current 2>/dev/null
git log --oneline -10 2>/dev/null
git diff --stat HEAD 2>/dev/null
```

For **swarm mode**, also read:
- `plan.md` — parse TOON block for task statuses
- `progress.md` — latest entries
- `findings.md` — discoveries from completed tasks

### Step 2 — Write HANDOFF.md

Use the matching template below.
Keep it scannable: headers, bullets, no prose walls.
Use absolute file paths.
Target length: 40–80 lines.

#### Regular Session Template

```markdown
# Handoff — YYYY-MM-DD HH:MM

## Goal
[One sentence: what the user was trying to accomplish]

## Accomplished
- [/absolute/path]: [what changed and why]
- [/absolute/path]: [what changed and why]

## Dead Ends
- [Approach tried]: [why it failed, what was learned]
(Omit section if none)

## Decisions
- [Decision]: [rationale]
(Omit section if none)

## Verification Status
- [x] [check that passed]
- [ ] [check not yet run or failed]

## Next Steps
1. [Immediate next action]
2. [Follow-on]

## Context
- Branch: [name]
- Working directory: [absolute path]
- [Any other orientation info the next session needs]
```

#### Swarm Phase Template

```markdown
# Handoff — Phase N — YYYY-MM-DD HH:MM

## Phase Summary
[One sentence: what this batch was supposed to accomplish]

## Task Status
tasks[N]{id,title,status}:
  T1,Research auth,done
  T2,Implement JWT,done
  T3,Write tests,failed

## Completed
- T1: [result summary, key file paths]
- T2: [result summary, key file paths]

## Failed / Blocked
- T3: [error summary, what went wrong]
(Omit section if all succeeded)

## Findings for Next Phase
- [Discovery relevant to upcoming tasks]

## Blockers
- [Must-resolve items before continuing]
(Omit section if none)

## Next Phase
Batch N+1 tasks from TOON block:
- T4: [title]
- T5: [title]

## Context
- Branch: [name]
- Plan: [absolute path to plan.md]
- Working directory: [absolute path]
```

### Step 3 — Report

After writing, output:

```
Handoff saved → <absolute path to HANDOFF.md>

Resume:
  Read <path>/HANDOFF.md
  /swarm <plan-path>          ← if swarm mode
```

## Common Mistakes

- Writing prose paragraphs instead of bullet points
- Using relative paths instead of absolute
- In swarm mode, inventing task status from memory instead of reading TOON block
- Including full file contents instead of one-line summaries
- Forgetting to check for existing HANDOFF.md before overwriting
