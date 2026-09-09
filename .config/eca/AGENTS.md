# AGENTS.md

## Local clones and worktrees

The user's local repo clones live under `~/development`. Keep them on `master` and clean and avoid branching off a dirty tree.
When work may be concurrent or long-running prefer a worktree. Create these under `~/development/.worktrees` with a flat `<repo>--<short-context>` name (e.g. `fleet--telemetry-feature`), and remove it once merged or abandoned.
