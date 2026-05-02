We are about to lose all chat context and will need to resume cold in a fresh session. Update the durable checkpoint for "$ARGUMENTS" so that the next session can resume effectively as if no interruption happened.

Load the org-agenda skill, then use eca-org-agenda-find-heading-in-file with file "todo.org" and title "$ARGUMENTS" to locate the heading. Use eca-org-agenda-get-body-by-path with path "$ARGUMENTS" and :file "todo.org" to read the current checkpoint body.

Now compose an updated checkpoint body from this session's full chat context. Be thorough — err on the side of capturing too much rather than too little. A future session with zero prior context will rely entirely on this checkpoint to resume without re-discovery.

Include whatever is relevant. Common things worth preserving:
    - Current status and where things stand
    - What was accomplished or changed this session
    - Key decisions, findings, or context a fresh session wouldn't know
    - Concrete next steps (in priority order, if priority known)
    - File paths, locations, commands, and configurations we touched
    - Scaffolding, environment setup, or tooling details
    - Partial implementations, dead ends, or things we tried and rejected
    - Open questions or blockers

Use whatever length and structure fits the material. A short task gets a short checkpoint; a complex multi-file investigation should be detailed. Organize with sub-headings or bullet lists as needed but don't force brevity. Write in org-mode syntax (not markdown) since this goes into an org file. Merge with any prior checkpoint content rather than discarding it — preserve earlier context that is still relevant, drop anything superseded by this session's work. Write the result back using eca-org-agenda-replace-body-by-path with path "$ARGUMENTS" and :file "todo.org".

After writing the checkpoint, clean up any ephemeral artifacts from this session that are safe to remove — such as scratch worktrees, temporary branches, or throwaway files we created. Only remove things that were created during this session, are not referenced in the checkpoint as needed for resumption, and whose loss is trivially recoverable. When in doubt, leave it. Do not remove committed branches that back open PRs or contain unpushed unique work.

Confirm the checkpoint was written by replying with a brief summary of what it covers and roughly how long it is (e.g. line count or section count). Also list any cleanups performed, or note that none were needed. Do not echo the full checkpoint body back. If the heading is not found or ambiguous, say so precisely and stop.
