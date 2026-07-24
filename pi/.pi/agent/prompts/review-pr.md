---
description: Review the actual GitHub PR for the current branch
argument-hint: "[PR URL/number or instructions]"
---
Review the actual GitHub pull request. Do not approximate a PR review from local branch diffs.

User-provided PR URL/number or extra instructions:

$ARGUMENTS

Do not make changes unless explicitly asked. Act as a senior code reviewer and focus on production-relevant issues.

PR discovery rules:

1. Identify repository/branch state with `git status --short --branch`.
2. Use GitHub CLI to find the actual PR:
   - If the user provided a PR URL or PR number, inspect it with:
     - `gh pr view <PR> --json number,url,title,body,baseRefName,headRefName,state,isDraft,author,commits,files,additions,deletions`
   - Otherwise, inspect the PR associated with the current branch using:
     - `gh pr view --json number,url,title,body,baseRefName,headRefName,state,isDraft,author,commits,files,additions,deletions`
3. If no actual PR can be found, stop and ask the user for a PR URL/number. Do not fall back to `git diff`, `origin/main`, `origin/HEAD`, or any inferred base branch.
4. Review the actual PR diff using:
   - `gh pr diff <PR> --patch`
   - If reviewing the current branch PR, `gh pr diff --patch` is acceptable.
5. Inspect additional PR context when useful:
   - PR title/body
   - changed file list
   - commit list
   - relevant surrounding code in the local checkout
   - related tests/docs/config
6. If local uncommitted changes exist, mention that they are not part of the PR unless the PR diff includes them. Review the PR itself first.

Review focus:

- Correctness bugs, edge cases, race conditions, data loss
- Security/privacy problems and unsafe input handling
- Error handling, resource cleanup, and reliability gaps
- API/behavior regressions and backward-compatibility risks
- Tests that are missing or insufficient for the changed behavior
- Significant maintainability problems, but avoid nitpicks and pure style comments

Review process:

1. Confirm the actual PR number/URL and base/head branches.
2. Inspect the actual PR diff and surrounding code needed to understand it.
3. Check related tests/docs/config when relevant.
4. Run targeted commands/tests only when useful, and mention what you ran.
5. Prioritize concrete findings over general advice.

Output format:

- Start with `Findings`.
- Mention the PR reviewed, e.g. `PR: #123 — <title>`.
- Mention base/head branches, e.g. `Base/head: main ← feature-branch`.
- List findings by severity: `Critical`, `High`, `Medium`, `Low`.
- For each finding, include file/line, the problem, why it matters, and a suggested fix.
- If there are no substantive issues, say so clearly and mention any residual risks or tests not run.
- Keep the review concise.
