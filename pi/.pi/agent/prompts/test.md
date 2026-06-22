---
description: Add or improve tests for changed or requested behavior
argument-hint: "[target behavior]"
---
Add or improve tests for:

$ARGUMENTS

If no target is provided, inspect the current git changes and add tests for the behavior they introduce or modify.

Do not change production code unless needed to fix an obvious testability issue; ask first for broader changes.

Testing process:

1. Identify the behavior under test and the relevant test framework/patterns.
2. Inspect nearby tests and follow existing conventions.
3. Cover meaningful success, failure, and edge cases.
4. Keep tests deterministic and focused.
5. Avoid over-mocking when a realistic unit/integration test is practical.
6. Run the targeted test command, and broader checks when appropriate.
7. Report what tests were added and what commands passed or failed.

If tests are not practical in this repo, explain why and suggest the best manual validation steps.
