---
name: planner
description: Use when planning multi-step work that should survive across sessions, especially when the user wants a persistent plan folder with findings/progress tracking, or later swarm execution.
---

# Planner

Create a durable plan package on disk.

## When to Use

- Work spans multiple sessions or CLIs
- Execution should later be batched by `/swarm`
- You need persistent `plan.md`, `findings.md`, `progress.md`

Skip for trivial one-shot tasks that fit in a single session.

## Plan Folder

`~/.agents/plan/<repo-slug>/<YYYYMMDDTHHMM>-<task-slug>/`

Files: `plan.md` | `findings.md` | `progress.md`

When creating files, read the templates in `references/` for structure.

## Workflow

1. Ground in the repo and current branch.
2. Ask only questions that materially affect the plan.
3. Create or reuse the plan folder (check for existing plans first).
4. **Research** — capture repo facts and prior art in `findings.md`.
   - Single-area → explore inline (no team overhead).
   - Multi-area (2+ independent questions) → use Research Teams:

   ### Research Teams

   **Step 1 — TeamCreate**
   ```
   team_name: "planner-research-{task-slug}"
   ```

   **Step 2 — TaskCreate per research question**
   One task per independent question:
   ```
   subject: "R{n}: {question}"
   description: what to look for, where to look, what to capture
   metadata: { id: "R{n}", area: "{area}", scope: "{dirs or files}" }
   ```

   **Step 3 — Spawn agents — ALL in a single message**
   One `Agent` tool call per research task, all in the same message block:
   ```
   team_name: the team from Step 1
   model: use lightweight model for research
   subagent_type: "Explore"
   name: "R{n}"
   prompt: include research question, target dirs/files,
           and instruction to TaskUpdate with findings when done
   ```

   **Step 4 — Collect**
   After all agents complete, merge findings into `findings.md`
   and use them to inform task planning.
5. Write `plan.md` with tasks in canonical format (below).
6. Initialize `progress.md` with assumptions and next action.
7. **Handoff** — print plan location and suggest next steps.

## Task Format

Each task in `plan.md` uses a TOON block for machine-parseable metadata, with markdown sections for descriptions.

**TOON block** (source of truth for metadata):

```
tasks[N]{id,title,depends_on,status,size,type,file}:
  T1,Research auth patterns,,pending,S,research,src/auth.py
  T2,Implement JWT validation,T1,pending,M,impl,src/auth.py
  T3,Refactor core logic,T2,pending,L,impl,src/core.py
  T4,Code review PR #42,,pending,M,review,src/
```

Fields:
- `id`: T{n} identifier
- `title`: short task name
- `depends_on`: comma-separated T{n} refs or empty
- `status`: pending|in_progress|done|failed|blocked
- `size`: S (Small) | M (Medium) | L (Large) — task complexity (see Sizing below)
- `type`: impl | review | research | test — task category (default: impl)
- `file`: primary file path (optional, helps swarm give context)

**Markdown sections** (descriptions only, no duplicate metadata):

```
### T1: Research auth patterns
[description — scope, deliverable, acceptance criteria]
```

The TOON block is the source of truth. Swarm reads it for parsing and status updates.
Prefer pseudo-code over real code in task descriptions — describe intent
and logic flow, not implementation syntax. Concrete code belongs in execution.

**Planner assigns size and type only.** Model/agent selection is the executor's responsibility.

## Sizing (LMS)

Assign `size` per task based on complexity:

| Signal | Size |
|--------|------|
| Refactor, debug, migrate, architecture | **L** (Large) |
| Multi-file (>3 files) or >100 LOC | **L** |
| Security/credentials/auth logic | **L** |
| Ambiguous requirements needing interpretation | **L** |
| Add/create/implement/fix/test (clear spec) | **M** (Medium) |
| Clear spec, ≤2 files, ≤100 LOC | **M** |
| UI/frontend, config, API endpoints | **M** |
| Typo, rename, comment, doc updates | **S** (Small) |
| Read-only: research, summarize, explore | **S** |

Default: **S**. User can override any assignment.

Rule of thumb:
- Complex multi-file or ambiguous → L
- Clear spec, writes/edits ≤2 files → M
- Trivial or read-only → S

## Type Assignment

Assign `type` to categorize what the task does:

| Type | When |
|------|------|
| `impl` | Writing or editing code (default) |
| `review` | Code review, audit, PR analysis |
| `research` | Read-only exploration, summarization |
| `test` | Writing or running tests |

Default: **impl**. Type is orthogonal to size — a review can be S, M, or L.

## Dependency Graph + Batches

After the task list, add an ASCII dep graph and batch plan:

    T1 → T2 ─┐
         T3 ─┴→ T4 → T5

    Batches:
    1: T1           2: T2, T3 (parallel)
    3: T4           4: T5

Tasks in the same batch have no mutual deps → run in parallel via Agent Teams.

**Maximize parallelism:**
- Prefer wide batches over deep serial chains — split tasks to reduce deps
- Independent subtasks (different files, no shared state) belong in the same batch
- Research tasks (type=research) are always parallelizable — batch them together early
- If a task touches >3 independent files, split into per-file tasks that run in parallel
- Target: ≥50% of tasks should be parallelizable (in a batch with 2+ tasks)

## Handoff

After writing all three files, output:

    Plan ready.
      {absolute path to plan.md}
    Next steps:
      /clear            — free context before execution
      /swarm {path}     — execute the plan
      /swarm --dry-run  — preview batch order

If trivial (≤3 tasks, no deps), offer inline execution instead of swarm.

## Memory Rules

- `progress.md` = live task log, disposable after completion
- `findings.md` = research, promote only durable items to project memory
- Follow host project's memory SSOT if one exists

## Common Mistakes

- Creating plan without `findings.md` and `progress.md`
- Missing TOON block or mismatched field count (breaks swarm parsing)
- Missing dependency graph or batch plan
- Re-planning from scratch when a plan folder already exists
- Embedding real code in task descriptions instead of pseudo-code
