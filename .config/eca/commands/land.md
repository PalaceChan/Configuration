We are about to lose all chat context and will need to resume cold in a fresh session. Update the durable checkpoint for "$ARGUMENTS" so that the next session can resume effectively as if no interruption happened.

Load the org-agenda skill, then use oab-find-heading-in-file with file "todo.org" and title "$ARGUMENTS" to locate the heading. Use oab-get-body-by-path with path "$ARGUMENTS" and :file "todo.org" to read the current checkpoint body.

Now compose an updated checkpoint body from this session's full chat context. A future session with zero prior context will rely entirely on this checkpoint to resume without re-discovery. Compress nothing – a verbose checkpoint that repeats itself is far better than a concise one that omits a critical detail.

Capture everything relevant, including but not limited to:
- Current status and concrete next steps
- What was accomplished, changed, decided, or discovered
- Every external reference (Slack threads, wiki pages, Jira tickets, PRs) with *why* each matters
- File paths, commands, env vars, configurations, and workarounds we touched or discovered
- Things tried and rejected – what error each hit, why it failed, what we tried next
- People involved, their roles, and commitments they made
- Root cause analyses with the narrowing steps
- Open questions or blockers

After composing, perform a cold-start verification: could a fresh agent reading only this checkpoint (a) understand what was tried and why, (b) reproduce the working setup without rediscovery, (c) know which threads to read and people to contact, (d) resume the next step immediately? If any answer is no, expand before writing.

Write in org-mode syntax. Merge with prior checkpoint content – preserve what's still relevant, drop what's superseded. A multi-day investigation should produce hundreds of lines, not dozens. For large checkpoint bodies, write the composed body to a temporary `.org` file and write it back using oab-replace-body-by-path-from-file with path "$ARGUMENTS", the temporary file path, :file "todo.org", and :return-body nil. For short bodies, oab-replace-body-by-path with path "$ARGUMENTS" and :file "todo.org" is also acceptable.

After writing, commit the checkpoint only when safe. Inspect both unstaged and staged diffs for `/home/avelazqu/org/todo.org` (`git diff -- /home/avelazqu/org/todo.org` and `git diff --cached -- /home/avelazqu/org/todo.org`) and verify the complete index contains no unrelated staged changes before committing. Stage and commit only the checkpoint update. If `todo.org` has unrelated changes elsewhere, isolate the checkpoint hunks (use `:line`/`:body-lines`/`:subtree-lines` metadata plus git hunk ranges), apply only those hunks to the index via a temporary noninteractive patch such as `git apply --cached`, then verify `git diff --cached -- /home/avelazqu/org/todo.org` contains only the checkpoint update. Never use interactive staging. Never include unrelated staged changes in the checkpoint commit. If hunks can't be isolated cleanly, leave uncommitted and say so.

After the checkpoint commit step, clean up ephemeral artifacts from this session that are safe to remove (scratch worktrees, temp branches, throwaway files) – only if not referenced in the checkpoint and trivially recoverable. When in doubt, leave it.

Confirm with: a brief summary of what the checkpoint covers, its approximate length (number of sections / line count), whether a commit was created (and why not if not), and any cleanups performed. Do not echo the full checkpoint body.
