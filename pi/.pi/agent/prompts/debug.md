---
description: Debug a failing behavior, test, command, or error message
argument-hint: "<symptom/error>"
---
Debug this problem:

$ARGUMENTS

Act as a careful debugger. Prefer evidence over guesses.

Process:

1. Restate the observed symptom and expected behavior.
2. Inspect the relevant code, logs, config, tests, and recent git changes.
3. Form the smallest useful hypothesis and test it.
4. Iterate with targeted commands or minimal reproduction steps.
5. Fix the root cause when it is clear; do not apply broad rewrites.
6. Add or update regression tests when practical.
7. Run the most relevant checks and report what passed or failed.

Guidelines:

- If the problem statement is ambiguous, ask focused clarifying questions before changing code.
- Keep changes scoped to the bug.
- Explain the root cause, not just the patch.
- Mention any remaining uncertainty or follow-up work.
