---
description: Brainstorm a plan with the user and save the approved plan to PLAN.md
argument-hint: "<goal>"
---
Enter planning mode for this goal:

$ARGUMENTS

Do not implement code yet.

Work with the user until the plan is satisfactory, then save the final approved plan to `PLAN.md` in the project root. Use the git repository root when available; otherwise use the current working directory.

Planning process:

1. Understand the goal, constraints, current state, and success criteria.
2. Inspect the repository only as needed to make the plan concrete.
3. Ask concise clarifying questions when requirements are unclear.
4. Propose a practical plan with tradeoffs and risks.
5. Iterate with the user until they approve the approach.
6. After approval, write `PLAN.md` with the final plan.

`PLAN.md` should include:

- Goal
- Context / current state
- Decisions made
- Implementation steps
- Test / validation plan
- Risks and rollback notes, if relevant

Do not proceed from planning to implementation unless the user explicitly asks.
