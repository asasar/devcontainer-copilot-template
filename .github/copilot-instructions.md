# Copilot Instructions

## Communication

- Always respond in English, no exceptions, regardless of the language the request is written in.
- Address the repository owner as "Alexis". When asking him a question, always use his name.

## Implementation plans

- Never write a plan as a single monolithic file. Always split it into a directory (`docs/superpowers/plans/<name>/`) with an `index.md` (goal, architecture, file structure, dependency graph, self-review) plus one self-contained file per task (each repeating the Global Constraints it needs). A sub-agent dispatched to a task must be able to work from that task's file alone, without loading the rest of the plan into context.
- Cross-links between plan files (task ↔ index) must use absolute GitHub blob URLs, not relative paths — relative links do not resolve when the content is embedded in a GitHub Issue.

## Version control discipline

- Commit regularly, in small increments, as work progresses — never let a work session accumulate large uncommitted changes. Every completed task, fix round, or reviewer-approved change gets its own commit immediately.
- Push every commit to the remote (`git push`) right after committing, not just at the end of a session. Uncommitted or unpushed work is at risk of being lost; the remote branch is the durable record.
- This applies inside worktrees too: push the worktree's branch (e.g. `git push origin <branch>`) after each commit, not only when the branch is finished and ready to merge.
- Follow trunk-based development: use short-lived branches, one per task (or a small tightly related group), merged into `main` via PR as soon as that task is implemented and reviewed. Never accumulate multiple unrelated tasks on a single long-lived branch — this makes review, rollback, and context-loading for future agents much harder.
- Every PR must include test evidence before being merged: the actual output of the test suite(s) run at the merge base (e.g. `pytest -v`, `vitest run`), posted in the PR description or as a PR comment. A PR without test evidence must not be merged, even if the sub-agent/reviewer reports say tests passed.

## Task tracking

- Always add tasks to GitHub as Issues — always, no exceptions. Describing a task in chat or in a plan document is never sufficient; the corresponding GitHub Issue (with labels/milestone) must actually be created before considering the task tracked.
- **Hard gate — applies to every task, including ad-hoc ones requested directly in chat (not just the numbered plan tasks):** before writing/editing any file for a task, the agent must first run and show the output of (a) `gh issue create` (or confirm an existing issue number) and (b) `gh project item-add 5 --owner asasar --url <issue-url>`. Do not start implementation "and create the issue after" — that is the exact mistake that has repeated. If these two commands haven't been run yet, stop and run them first, even mid-task.
- **Mechanical enforcement of the hard gate above** (not just a written rule): every commit message must include `#<issue-number>`, enforced by a local `commit-msg` git hook (`scripts/git-hooks/commit-msg`, installed via `bash scripts/install-git-hooks.sh` — run once per clone/worktree). Every PR into `main` is additionally checked by CI (`.github/workflows/issue-link-check.yml`), which fails the PR if it doesn't reference an issue that both exists and is an item in the Project (#5).
- Each GitHub Issue must contain the **full text** of its task file as the issue body, not just a link/reference to the file. The issue must be self-contained so an agent can work from it without fetching another file.
- Every task issue's lifecycle state must always be kept in sync with reality: Todo (not started), In Progress (implementer dispatched/working), In Review (implemented, reviewer dispatched or fix loop running — use a comment or the Project item if no explicit "In Review" option exists), Done (reviewed and merged to `main`). Blocked issues must explain why in a comment.
- Update the lifecycle state immediately at every transition — the moment a task starts, moves to review, gets blocked, or gets merged. Never let it lag behind reality; a stale status is treated as a tracking bug, not a minor omission.
- When a task reaches Done (merged to `main`), close its issue and reference the merging PR in a closing comment.
- Use GitHub's own standard mechanism for lifecycle tracking, not custom labels. Every task issue must be added to it (`gh project item-add`) and its native `Status` field kept in sync with the transitions above. Do not create `status:*` labels — the Project's `Status` field is the single source of truth.

## Subagent-driven execution

- Execute implementation plans using the `subagent-driven-development` skill: for each task, dispatch one implementer sub-agent, then one reviewer sub-agent against the resulting diff, then a bounded fix loop (dispatch the same implementer with the reviewer's Important/Critical findings, then a scoped re-review) until clean. Minor findings are deferred/ledgered, never looped.
- Implementer sub-agents (parallel implementers), even when multiple tasks are theoretically independent, may be active simultaneously.
- The skill's per-plan scratch workspace (`.superpowers/sdd/<plan>/`) — ledger, task briefs copies, implementer/reviewer reports, diff packages — is ephemeral and must be `.gitignore`d. Never let a sub-agent `git add`/commit files from this directory; if one accidentally does, `git rm --cached` it and add the ignore rule immediately.
- Each task gets its own short-lived branch/worktree (see Version control discipline), not one long-lived branch spanning the whole plan.

## Brainstorming checklist (things to always ask before finalizing a design/plan)

These observations came from real gaps found while brainstorming this project. Any future brainstorming session in this repo (new features, new subsystems) must ask about them explicitly, not assume defaults:

1. **Execution environment for sub-agents/tools.** Before writing an implementation plan, ask where sub-agents will actually run commands that need Docker, Azure CLI, or other heavy tooling: a shared host, an isolated devcontainer, or CI only. Do not assume tools like `docker` or `az` are already installed — verify with the target environment first.
2. **GitHub-native task management.** Design/plan tasks must be tracked as GitHub Issues (with labels for type/priority/agent and a milestone) and as items in a GitHub Project (v2) board with a native `Status` field — not only in local todo tables. A fine-grained PAT/token can be granted the `project` scope via `gh auth refresh -s project` (interactive device-code approval); this does work for personal accounts, not just organizations — don't assume it's unsupported.
3. **Multi-agent role mapping.** For any plan executed by multiple sub-agents, explicitly define which specialized agent role owns each task (e.g. frontend-dev, backend-dev, devops-azure, qa-pytest, qa-vitest, qa-playwright) and how parallel dispatch is decided (dependency graph + file/folder overlap check), as part of the design — not left implicit.
4. **Multi-environment infra from the start.** If the project deploys anywhere, ask about dev/test/prod (or similar) environments and naming conventions (e.g. Microsoft CAF) up front, rather than designing for a single environment and retrofitting later.
5. **Who creates GitHub artifacts.** Clarify that issue/label/milestone/board creation is done by the orchestrating session/agent (single source of truth), never by implementation sub-agents, to avoid duplicates or conflicts.
