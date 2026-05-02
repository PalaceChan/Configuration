Load the org-agenda skill, then use eca-org-agenda-find-heading-in-file with file "todo.org" and title "$ARGUMENTS" to locate the heading. Use eca-org-agenda-get-body-by-path with path "$ARGUMENTS" and :file "todo.org" to read its body. If the heading has child subtrees, use emacsclient --eval with the :pos from find-heading-in-file to extract the full subtree via:

```elisp
(with-current-buffer (find-file-noselect "/home/avelazqu/org/todo.org")
  (goto-char POS)
  (buffer-substring-no-properties
   (point)
   (save-excursion (org-end-of-subtree t) (point))))
```

Treat everything read as the durable memory checkpoint for our work. Do not take any further action beyond reading. Reply with a short summary of the checkpoint state and what the next actionable step is (if one is indicated). Keep it brief. If the heading is not found or ambiguous, say so precisely and stop.
