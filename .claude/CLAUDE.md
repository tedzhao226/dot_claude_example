# Coding

## Approach

Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- After tool results: reflect on quality, plan next steps, then act.
- When corrected: reflect on what went wrong, consider if it could recur, suggest a CLAUDE.md update if systemic.

When designing classes or interfaces:
- Who are the callers? What do they actually need?
- What's the contract? (inputs, outputs, errors)
- Does this already exist? Should I extend rather than create?
- Does the user have a design in mind? Ask before proposing.

**Banned words** (in docstrings, comments, commit messages):
`consolidate`, `modernize`, `streamline`, `flexible`, `delve`, `establish`, `enhanced`, `comprehensive`, `optimize`

## Build

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Surgical changes — touch only what you must:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Every changed line should trace directly to the user's request.

## Tests

Use the /testing skill for test strategy and patterns.

## Verify

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

After completing any code modification, run the full test suite (unit + integration) before marking work complete.

Strong success criteria let you loop independently. Weak criteria require constant clarification.

# Tools

RTK command rewriting is handled by hooks. See @RTK.md for meta commands (gain, discover).

# File Rules

When editing these file types, read the matching rule file first:

- Python (`.py`): `~/.claude/rules/python.md`
- Dockerfile: `~/.claude/rules/docker.md`
- Docker Compose: `~/.claude/rules/docker-compose.md`
- Makefile: `~/.claude/rules/makefile.md`
- Markdown (`.md`): `~/.claude/rules/markdown.md`
- `.env`: `~/.claude/rules/env.md`
- FastAPI: `~/.claude/rules/fastapi.md`

# Context Management

## Compact Instructions

When compressing context, preserve in priority order:
1. Architecture decisions and constraints (NEVER summarize away)
2. Modified files and their key changes
3. Current verification status (which checks passed/failed)
4. Open TODOs and rollback notes
5. Tool outputs can be dropped — keep pass/fail only

## Safety Rails

NEVER:
- Commit .env files, credentials, or secrets
- Remove feature flags without searching all call sites
- Skip tests before marking work complete
- Modify CI config, lockfiles, or deploy scripts without explicit approval

ALWAYS:
- Run full test suite after code changes
- Update CHANGELOG.md for user-facing changes
