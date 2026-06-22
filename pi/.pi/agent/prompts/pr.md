---
description: Prepare the current branch for a pull request into main
argument-hint: "[base branch]"
---
Prepare the current branch for a pull request into `${1:-main}`.

Do not push, commit, open the PR, or edit files unless explicitly asked.

Process:

1. Inspect git state: current branch, status, commits, and diff against `${1:-main}` or `origin/${1:-main}`.
2. Use the merge-base/triple-dot diff when possible, for example `git diff origin/${1:-main}...HEAD` and `git log origin/${1:-main}..HEAD`.
3. Understand the purpose of the branch from commits, diffs, issue references, and docs.
4. Check for unrelated changes, debug leftovers, secrets, generated files, and missing docs/tests.
5. Run relevant formatting, linting, type checks, and tests when practical.
6. Suggest any final cleanup needed before opening the PR.
7. Draft a PR title and body. If a PR template exists, use it as the starting point.

PR body should include:

- Summary
- Key changes
- Tests / validation
- Risks / rollout notes, if relevant

If the branch is not ready, prioritize a concise checklist of blockers before the PR draft.
