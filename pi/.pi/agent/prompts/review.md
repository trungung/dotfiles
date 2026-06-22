---
description: Review code changes for correctness, security, and maintainability
argument-hint: "[target or instructions]"
---
Review the requested target or instructions:

$ARGUMENTS

If no target/instructions were provided, review the current git changes. Prefer staged changes (`git diff --cached`) when present; otherwise review unstaged/untracked work via `git status`, `git diff`, and relevant files.

Act as a senior code reviewer. Do not make changes unless explicitly asked. Focus on issues that could matter in production:

- Correctness bugs, edge cases, race conditions, data loss
- Security/privacy problems and unsafe input handling
- Error handling, resource cleanup, and reliability gaps
- API/behavior regressions and backward-compatibility risks
- Tests that are missing or insufficient for the changed behavior
- Significant maintainability problems, but avoid nitpicks and pure style comments

Review process:

1. Inspect the diff and any surrounding code needed to understand it.
2. Check related tests/docs/config when relevant.
3. If needed, run targeted commands/tests and mention what you ran.
4. Prioritize concrete findings over general advice.

Output format:

- Start with `Findings`.
- List findings by severity: `Critical`, `High`, `Medium`, `Low`.
- For each finding, include file/line, the problem, why it matters, and a suggested fix.
- If there are no substantive issues, say so clearly and mention any residual risks or tests not run.
- Keep the review concise.
