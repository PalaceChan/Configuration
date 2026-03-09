---
name: elpy
description: Run Python code in an Emacs Elpy shell, capture appended transcript output, and generate plots as PNGs for inline display in chat.
metadata:
  version: "1.0"
---

# Elpy Python interactive analysis

Run Python code in an Emacs Elpy-managed inferior Python shell, capture the appended shell transcript, and optionally save plots as PNGs for inline display in chat.

This v1 skill supports the core editor-centered workflow:
- load a small Emacs Lisp bridge
- create or reuse an Elpy inferior Python shell
- send short snippets or generated Python files to that shell
- capture the appended shell transcript back into ECA
- save plots to `.eca/diagrams/` and return them as markdown images

Interactive plot window parity with ESS is intentionally out of scope for this version. PNG output is the supported plotting path.

## Preconditions

### Elpy must be available in Emacs

This skill assumes Elpy is installed and available in the current Emacs session. If Elpy shell support is unavailable, ask the user to enable or load Elpy before continuing.

### Plotting requires the target environment to have Matplotlib

If the user asks for plots, the targeted Python shell environment must already have `matplotlib` available. Do not assume it is installed system-wide.

### Load the bridge elisp

The skill ships a helper (`scripts/eca-elpy-bridge.el`) that provides the public bridge functions. Load it once per session before first use:

```bash
emacsclient --eval '
    (load "~/.config/eca/skills/elpy/scripts/eca-elpy-bridge.el" nil t)'
```

The bridge will create or reuse an Elpy inferior Python shell, wait for a prompt before and after sending code, and return the appended shell transcript as a string.

## Bridge API

### Evaluate a short code string

```bash
emacsclient --eval "
    (eca-elpy-eval \"print(sum([1, 2, 3]))\" 30)"
```

Signature:

```emacs-lisp
(eca-elpy-eval CODE &optional TIMEOUT BUFFER-NAME DIRECTORY)
```

### Execute a Python file

```bash
ABS_PY_FILE="$(realpath "$PY_FILE")"
emacsclient --eval "
    (eca-elpy-source-file \"$ABS_PY_FILE\" 120)"
```

Signature:

```emacs-lisp
(eca-elpy-source-file FILE &optional TIMEOUT BUFFER-NAME DIRECTORY)
```

### Optional helper

The bridge also exposes:

```emacs-lisp
(eca-elpy-inferior-python-process &optional BUFFER-NAME DIRECTORY)
```

Most skill workflows should use `eca-elpy-eval` or `eca-elpy-source-file` directly.

## Shell targeting rules

When multiple inferior Python shells exist, the bridge currently applies these rules:

1. If `BUFFER-NAME` is supplied, an exact shell buffer match wins.
2. Otherwise, if `DIRECTORY` is supplied, an exact shell `default-directory` match is preferred.
3. If no exact directory match exists, the bridge falls back to a prefix directory match.
4. If an explicit `BUFFER-NAME` or `DIRECTORY` is supplied and no matching shell exists, the bridge starts a new shell for that target.
5. If neither `BUFFER-NAME` nor `DIRECTORY` is supplied, the bridge falls back to the most-recently-used live inferior Python shell.

Important caveat: prefix directory matching can still be ambiguous if multiple shells live under the same parent directory. Prefer an exact shell buffer name or an exact shell directory when possible.

If both `BUFFER-NAME` and `DIRECTORY` are supplied, exact `BUFFER-NAME` targeting takes precedence.

## Workflow

### Step 1: Create workspace files

Write generated Python scripts under `.eca/tmp/` and plots under `.eca/diagrams/`:

```bash
mkdir -p .eca/tmp .eca/diagrams
TS="$(date +%s)"
PY_FILE=".eca/tmp/elpy-$TS.py"
```

### Step 2: Write the Python script

Write the Python code to `$PY_FILE`. Prefer explicit `print()` for important results so they reliably appear in the captured transcript.

For short snippets and one-liners, you can skip the temp file and call `eca-elpy-eval` directly. For anything multi-line, prefer writing a file and sending the file.

Whole-file execution currently uses Elpy's file-sending behavior, which means the last expression of a file may also print into the transcript. Even so, explicit `print()` is still the most reliable way to surface important results.

### Step 3: Generate plots as PNGs when needed

When the user wants an inline plot in chat, save it to `.eca/diagrams/` and return the PNG path as markdown.

A safe default Matplotlib pattern is:

```python
plot_file = ".eca/diagrams/elpy-plot-TIMESTAMP.png"

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 6), dpi=144)

# plotting code here ...

fig.savefig(plot_file, bbox_inches="tight", facecolor="white")
plt.close(fig)
print(f"Saved plot to {plot_file}")
```

Notes:
- Use a unique timestamp in the filename.
- Prefer `plt.close(fig)` after saving to keep the session tidy.
- You have full freedom over colors, themes, and styling; optimize for readability.
- Do not rely on interactive plot windows for this skill.
- If you are targeting a shell whose working directory may differ from the current project root, prefer an absolute `plot_file` path.

### Step 4: Execute in the Elpy shell

For multi-line code, source a file:

```bash
ABS_PY_FILE="$(realpath "$PY_FILE")"
emacsclient --eval "
    (eca-elpy-source-file \"$ABS_PY_FILE\" 120)"
```

This returns the appended shell transcript chunk as a string.

For short snippets, use `eca-elpy-eval`:

```bash
emacsclient --eval "
    (eca-elpy-eval \"print(sum([1, 2, 3]))\" 30)"
```

### Step 5: Target a specific Python shell when needed

By exact shell buffer name:

```bash
emacsclient --eval "
    (eca-elpy-source-file \"$ABS_PY_FILE\" 120 \"*Python[proj]*\")"
```

By exact directory:

```bash
emacsclient --eval "
    (eca-elpy-source-file \"$ABS_PY_FILE\" 120 nil \"/path/to/project/\")"
```

If both are supplied, the exact shell buffer name wins.

### Step 6: Respond in chat

1. Paste the returned transcript in a code block, truncating if it is very large.
2. If a PNG plot was generated, output it on its own line:

```markdown
![Python plot](./.eca/diagrams/elpy-plot-TIMESTAMP.png)
```

3. If the user wants a larger view, open the PNG in Emacs:

```bash
emacsclient --no-wait ".eca/diagrams/elpy-plot-TIMESTAMP.png"
```

## Tips

- Prefer `eca-elpy-eval` for small, self-contained snippets.
- Prefer temp files plus `eca-elpy-source-file` for multi-line code, plotting, or anything you may want to inspect later.
- Use explicit `print()` calls for results you definitely want in the transcript.
- Prefer an exact shell buffer name when you know it. If you use directory targeting, prefer the exact shell directory rather than a broad parent directory.
- For Pandas objects, prefer `print(df.head().to_string())`, `print(df.describe().to_string())`, or similarly focused summaries rather than dumping huge tables.
- Session state persists across calls; that is useful for iterative work, but remember that previous imports, variables, and working-directory state may still be present.
- If reproducibility matters, write self-contained scripts that import what they need explicitly.
- For wide text output, consider setting display options in the script, for example with Pandas display settings.
- If plotting or imports fail unexpectedly, confirm that the targeted shell is using the intended virtual environment or interpreter.

## Guardrails

- Output directories: write generated scripts to `.eca/tmp/` and plots to `.eca/diagrams/`. Create both directories before writing files.
- Filenames: always use unique timestamp-based names such as `$(date +%s)`.
- No unsolicited installs: do not run `pip install`, `uv pip install`, `poetry add`, or similar package-install commands without asking the user first.
- No shell escapes: do not call `subprocess`, `os.system`, shell commands, or external processes from Python without asking the user first.
- Performance: keep Python commands reasonably fast; long-running code blocks the Emacs shell. For heavy work, warn the user and increase the timeout if needed.
- Plotting contract: for chat-visible plots, save PNGs explicitly. Do not assume an interactive plot window will be available.
- Output discipline: avoid printing extremely large data structures unless the user explicitly asks for full output.

## Limitations

- Initial shell creation may briefly open or select a Python shell buffer because of Elpy internals.
- Prompt-based waiting is meant for normal interactive use; long-running code or code waiting for input may need larger timeouts or smaller chunks.
- Transcript capture assumes one command at a time per shell. Concurrent sends to the same shell may interleave output.
- Directory targeting prefers exact matches before prefix matches, but ancestor-directory requests can still be ambiguous when multiple shells live underneath the same parent path.
- File execution currently uses Elpy's `elpy-shell-send-file`; the bridge strips a known internal `codecs.open()` deprecation warning from returned transcript output.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| No Elpy/Python shell found | No inferior Python shell is running yet | The bridge will try to start one; if that fails, ask the user to start or enable an Elpy shell in Emacs |
| Elpy functions unavailable | Elpy is not loaded in the current Emacs session | Ask the user to enable/load Elpy, then reload the bridge |
| Timeout waiting for Python shell | Code is slow, blocked, or waiting on input | Increase the timeout or break the work into smaller chunks |
| Transcript is missing the key result | The script did not print the desired value explicitly | Add `print()` around important results |
| Plot file was not created | Save path wrong, figure not saved, or plotting code errored | Ensure `.eca/diagrams/` exists, call `savefig(...)`, and inspect the transcript for exceptions |
| `matplotlib` import fails | The targeted shell is using an environment without `matplotlib` | Retarget to a shell in the correct virtual environment or restart the shell in the intended environment |
| Wrong shell received the code | Multiple Python shells exist and the target hint was too broad | Pass an exact shell buffer name when possible; otherwise use an exact shell directory instead of a parent directory |
| A shell buffer opens unexpectedly | A new shell had to be started | Reuse an existing shell when possible; be aware that first creation may briefly affect window selection |
| State seems inconsistent across runs | Session state persists between evaluations | Reinitialize variables, write a self-contained script, or restart the shell |
