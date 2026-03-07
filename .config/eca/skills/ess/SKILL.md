---
name: ess
description: Run R code in an Emacs iESS session, capture the transcript output, and optionally produce plots – either inline as PNGs or directly in the iESS plot window for quick iteration.
metadata:
  version: "1.0"
---

# ESS R interactive analysis

Run R code in an Emacs iESS session, capture the transcript output, and optionally produce plots – either inline as PNGs or directly in the iESS plot window for quick iteration.

## Preconditions

### Load the bridge elisp

The skill ships a helper (`scripts/eca-ess-bridge.el`) that provides `eca-ess-source-file` and `eca-ess-eval`. Load it once per session before first use:

```bash
emacsclient --eval '
    (load "~/.config/eca/skills/ess/scripts/eca-ess-bridge.el" nil t)'
```

The bridge will find an existing iESS R process or start one via (R) if none exists.

## Workflow

### Step 1: Create workspace files

Write generated R scripts under `.eca/tmp/` and plots under `.eca/diagrams/`:

```bash
mkdir -p .eca/tmp .eca/diagrams
TS="$(date +%s)"
R_FILE=".eca/tmp/ess-$TS.R"
```

### Step 2: Write the R script

Write the R code to "$R_FILE". Prefer explicit `print()` / `cat()` for important results so they appear in the captured transcript.

For inline plots, wrap the plotting code in a `png()` device that writes to `.eca/diagrams/`:

```r
plot_file <- ".eca/diagrams/ess-plot-TIMESTAMP.png"
png(plot_file, width = 1400, height = 900, res = 144, bg = "transparent")
on.exit(dev.off(), add = TRUE)

# plotting code here ...
# for ggplot objects, always call print(p) explicitly
```

You have full creative freedom over plot styling – choose colors, themes, and aesthetics that make the chart clear and readable.

**For interactive plots** (user is iterating and doesn't need inline display), omit the `png()` wrapper entirely and just send the plot commands. They'll render in the iESS session's plot window, which is faster for exploration.

### Step 3: Execute in the iESS session

Source the file so multi-line code is handled cleanly:

```bash
ABS_R_FILE="$(realpath "$R_FILE")"
emacsclient --eval "
    (eca-ess-source-file \"$ABS_R_FILE\" 120)"
```

This returns the appended iESS transcript chunk as a string. For short one-liners, you can use `eca-ess-eval` instead:

```bash
emacsclient --eval "
    (eca-ess-eval \"summary(df)\" 30)"
```

**Targeting a specific R session**: when multiple iESS sessions are running, pass a buffer name or directory to avoid picking the wrong one:

```bash
# By buffer name
emacsclient --eval "
    (eca-ess-source-file \"$ABS_R_FILE\" 120 \"*R:2:proj*\")"

# By project directory
emacsclient --eval "
    (eca-ess-source-file \"$ABS_R_FILE\" 120 \"/path/to/project/\")"
```

If neither is specified, the bridge picks the most-recently-used iESS session.

### Step 4: Respond in chat

1. Paste the returned transcript in a code block (truncate if very large).
2. If an inline plot was generated, output it as a markdown image on its own line:

```markdown
![R plot](./.eca/diagrams/ess-plot-TIMESTAMP.png)
```

If the user asks for a larger view, open the PNG in its own Emacs buffer:

```bash
emacsclient --no-wait ".eca/diagrams/ess-plot-TIMESTAMP.png"
```

3. If the plot was sent to the iESS session window (no PNG), tell the user to check their plot window.

## Tips

- Iterating on plots: when the user is exploring data and tweaking plots, skip `png()` and let plots render in the iESS plot window — it's much faster than regenerating PNGs each time.
- ggplot2 objects: always `print(p)` explicitly — `source()` won't auto-print ggplot objects.
- Large data: use `head()`, `str()`, or `summary()` rather than printing entire data frames.
- Wide output: add `options(width=120)` at the top of the script to avoid truncation.

## Guardrails

- Output directory: write scripts to `.eca/tmp/` and plots to `.eca/diagrams/`. Create directories with `mkdir -p` before writing.
- Filename: always use a unique timestamp (`$(date +%s)`) to ensure unique names.
- No unsolicited installs: do not run `install.packages()` without asking the user first.
- No shell escapes: do not call `system()` or shell commands from R without asking the user first.
- Performance: keep commands reasonably fast — long-running R code blocks Emacs. For heavy computation, warn the user and consider increasing the timeout.
- Styling: you have full freedom over plot colors, themes, and aesthetics. Pick whatever makes the output clear.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| No ESS R process found | No iESS session running | The bridge will try `(R)` to start one; if that fails, ask the user to start an R session in Emacs |
| Timeout waiting for ESS process | R code is slow or hanging | Increase the timeout argument, or break the work into smaller chunks |
| ggplot renders blank PNG | Forgot to `print(p)` | Always explicitly `print()` the ggplot object |
| Plot appears in iESS but no PNG | `png()` device not opened | Wrap plotting code in `png()` / `dev.off()` for inline display |
| Transcript output is truncated | Very wide output | Add `options(width=120)` at the top of the script |
| Code runs in wrong R session | Multiple iESS sessions, bridge picked MRU | Pass buffer-name or directory argument to target the correct session |
