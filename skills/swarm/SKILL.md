---
name: swarm
description: Use when executing or dry-running an existing plan.md in dependency-aware batches with parallel Agent Teams, resume support, and persistent progress tracking.
---

# Swarm

Execute a plan package in dependency-aware batches.

## When to Use

- `plan.md` already exists (created by `/planner`)
- Independent tasks should run in parallel
- You need resume, dry-run, or batch visibility

No `plan.md`? Run `/planner` first.

## Required Input

Plan folder path — user provides, or use most recent under `~/.agents/plan/<repo-slug>/`.

Required files: `plan.md` | `findings.md` | `progress.md`

## Execution

**1. Parse** — Read `plan.md`. Find the TOON `tasks[N]{...}:` block. Extract fields per row (id, title, depends_on, status, size, type, file). Build dep graph from `depends_on` field.

**2. Batch** — Group by dependency order: batch 1 = no deps, batch 2 = deps only on batch 1, etc. All tasks in a batch run in parallel.

**3. Execute each batch:**

### Multi-task batch (2+ tasks) — use Teams

```
Step 1: TeamCreate
  → team_name: "swarm-batch-{N}" (or reuse existing team)

Step 2: TaskCreate per TOON task
  → subject: "{id}: {title}"
  → description: full task description from plan.md markdown section
  → metadata: { id, size, type, file, depends_on }
  One TaskCreate call per task in the batch.

Step 3: Spawn agents — ALL in a single message
  → One Agent tool call per task, all in the same message (maximizes concurrency)
  → Each Agent call sets:
     - team_name: the team from Step 1
     - model: determined by dispatch routing (see below)
     - name: task id (e.g. "T1")
     - prompt: include task description, relevant file paths, repo context,
       and instruction to mark task completed via TaskUpdate when done
     - mode: "auto" (or user-specified)
```

- **Single task → execute inline** (no team overhead, no TeamCreate)
- For batches with 4+ tasks, still spawn all simultaneously — the system handles concurrency limits.

### After each batch completes

- Update each task's `status` field in the TOON block in `plan.md` in-place
- Append results to `progress.md`
- Promote durable discoveries to `findings.md`

### Dispatch routing

Map task `size` and `type` to model:

```
IF type == "review":
  model = "opus"          # code reviews get strongest model
ELSE:
  SWITCH size:
    "L" → model = "opus"
    "M" → model = "sonnet"
    "S" → model = "haiku"
```

| size | type | Model |
|------|------|-------|
| any | review | `"opus"` |
| L | impl/research/test | `"opus"` |
| M | impl/research/test | `"sonnet"` |
| S | impl/research/test | `"haiku"` |

Default (missing size): `"sonnet"`. Default (missing type): `"impl"`.

**Escalation on failure:** S → M → L (haiku → sonnet → opus)

**4. Gate** — Do not start batch N+1 until batch N is fully resolved. If a task fails, mark dependents as `blocked` in the TOON block and ask the user.

## Dry Run

When user asks to preview (`--dry-run` or "preview batches"):
- Parse TOON block and display batches with titles, size, type, and assigned model
- Show which tasks run in parallel vs serial
- Do not execute anything

## Resume

When resuming an interrupted plan:
- Read `status` field from TOON block rows in `plan.md`
- Skip `done` tasks
- Continue from first batch containing `pending` tasks

## Failure Policy

- 1st failure: diagnose, record in `progress.md`
- 2nd failure: change approach or escalate (S→M→L)
- 3rd failure: stop, surface to user with full context

## Common Mistakes

- Executing tasks inline without following the plan's dependency order
- Running dependent tasks in parallel
- Keeping status only in chat instead of syncing to `plan.md`
- Silently retrying the same failed approach
