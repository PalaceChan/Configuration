# Emacsclient usage

Always use `emacsclient` instead of Emacs for any Emacs operations as the user has an Emacs server running at all times.

## Examples

- Open a file: `emacsclient --no-wait "/path/to/file"`
- Evaluate elisp: `emacsclient --eval '(some-function)'`
- Open at a line: `emacsclient --no-wait +42 "/path/to/file"`
- Byte compile a file:
```sh
emacsclient --eval '
(byte-compile-file "/path/to/file.el")'
```

- Check parentheses:
```sh
emacsclient --eval '
(with-temp-buffer
  (insert-file-contents "/path/to/file.el")
  (check-parens))'
```
- Run ERT tests:
```sh
emacsclient --eval '
(progn
  (load "/path/to/test-file.el" nil t)
  (ert-run-tests-batch-and-exit "pattern"))'
```

## Rules

- Always use `emacsclient`, never `emacs` or `emacs --batch`.
- Use `--no-wait` when opening files so the command returns immediately.
- Use `--eval` when evaluating elisp.
- Always format `--eval` elisp across multiple lines with proper indentation.
- Run `emacsclient` commands via the shell.
