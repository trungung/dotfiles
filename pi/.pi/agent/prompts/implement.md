---
description: Implement an approved plan with focused changes and validation
argument-hint: "[plan file or instructions]"
---
Implement the approved plan or instructions:

$ARGUMENTS

If no instructions are provided, read `PLAN.md` from the project root and implement it. Use the git repository root when available; otherwise use the current working directory.

Implementation process:

1. Read the plan/instructions and relevant code before editing.
2. Identify the smallest coherent set of changes.
3. Make focused edits that follow the existing project style.
4. Update docs/config/types as needed for the behavior change.
5. Add or update tests when the change affects behavior.
6. Run targeted formatting, linting, type checks, and tests when available.
7. Summarize what changed and what checks were run.

Guidelines:

- Do not silently expand scope beyond the plan.
- If the plan is missing, stale, or unsafe, stop and ask before proceeding.
- Prefer simple, maintainable code over clever abstractions.
- Do not commit, push, or open a PR unless explicitly asked.
