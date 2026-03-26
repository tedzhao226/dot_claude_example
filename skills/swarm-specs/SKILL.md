---
name: swarm-specs
description: Parallel executor for OpenSpec tasks.md. Use when you have an OpenSpec change with tasks.md and want parallel execution instead of sequential /opsx:apply.
---

# swarm-specs

Execute an OpenSpec `tasks.md` with parallel dispatch per section.

## When to Use

- `openspec/changes/<name>/tasks.md` exists in the current repo
- You want parallel execution of independent tasks within each section
- Use `/opsx:apply` instead if you prefer sequential single-agent execution

## Input

Change folder path -- user provides, or auto-detect:
- Look for `openspec/changes/` in current repo
- If multiple changes exist, ask which one
- Required: `tasks.md` in the change folder
- Optional context: `proposal.md`, `design.md`, `specs/` in the same folder

## Execution

**1. Parse** -- Read `tasks.md`. Extract:
- H2 sections as task groups (`## N. Group Name`)
- Checkbox lines as tasks (`- [ ] N.M description` = pending, `- [x]` = done)
- Read `proposal.md` and `design.md` from the change folder for shared context

**2. Batch** -- Sections are batches. Section 1 = batch 1, section 2 = batch 2.
- Tasks within a section are independent -> run in parallel
- Sections run sequentially (section N+1 waits for section N)
- Skip sections where all tasks are `[x]`

**3. Execute each batch:**

For each section with pending tasks:

- **Multi-task (2+):** Spawn one Agent per task, ALL in a single message (parallel dispatch).
  Each agent receives:
  - The task description
  - `proposal.md` content (what and why)
  - `design.md` content (how)
  - Relevant file paths from the task description
  - Size: `M` (default). Override per-task with `<!-- L -->` or `<!-- S -->` inline comment.
    Each CLI maps sizes to its own models.

- **Single task:** Execute inline, no agent overhead.

**4. After each batch:**
- Toggle completed tasks in tasks.md: `- [ ]` -> `- [x]`
- Log results to stdout

**5. Gate** -- Do not start next section until current section completes.
If a task fails: retry once at next size up (S->M->L), then stop and surface to user.

## Dry Run

When user says `--dry-run` or "preview":
- Parse and display sections as batches
- Show task count per batch, which run in parallel
- Show inferred size per task
- Do not execute

## Resume

- Read checkboxes from tasks.md
- Skip completed `[x]` tasks and fully-done sections
- Continue from first section with pending `[ ]` tasks

## After Completion

tasks.md checkboxes are updated in place.
Run `/opsx:archive` to merge specs and clean up the change folder.
