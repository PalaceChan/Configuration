---
name: mermaid
description: Generate diagrams from conversation context using Mermaid, rendered as PNG images inline in Emacs. Preferred for flowcharts, ER diagrams, Gantt charts, git graphs, pie charts, and mind maps. Use as the default when the user generically asks for a diagram or visual representation without specifying a tool. For complex UML (detailed class/component/deployment diagrams, swimlane activities), prefer the plantuml skill instead.
metadata:
  version: "1.0"
---

# Mermaid diagram generation

Generate diagrams from conversation context using Mermaid (mmd), rendered as PNG images that display inline. This is the default diagramming skill — use it for flowcharts, ER diagrams, Gantt charts, git graphs, pie charts, mind maps, and any generic "draw me a diagram" request. For detailed UML (complex class/component/deployment diagrams, swimlane activities), use the plantuml skill instead.

## Preconditions

### Mermaid CLI is installed

Verify with:

```bash
which mmdc
```

If missing, advise the user to install `@mermaid-js/mermaid-cli`.

## Workflow

### Step 1: Extract diagrammatic data

Analyze the current conversation context and identify what to diagram. If no diagrammatic data exists, inform the user and stop.

Choose the most appropriate diagram type for the data:

- Flowchart: process flows, decision logic, pipelines
- Sequence: request/response flows, API call chains
- Class: type hierarchies, data models
- State: state machines, lifecycle transitions
- Entity Relationship: database schemas
- Gantt: timelines, project schedules
- Git graph: branch/merge visualizations
- Pie chart: proportional data
- Mind map: brainstorming, concept mapping

### Step 2: Write the .mmd file

Write the Mermaid source under `.eca/diagrams/` in the workspace:

```bash
OUT_DIR=".eca/diagrams"
mkdir -p "$OUT_DIR"
TS=$(date +%s)
MMD_FILE="$OUT_DIR/agent-diagram-$TS.mmd"
```

Write the .mmd file with the diagram content. You have full creative freedom over styling — choose a theme and colors that make the diagram clear and readable.

Optionally, write a JSON config file (agent-diagram-$TS-config.json) if you want to customize themeVariables beyond what the built-in themes provide.

### Step 3: Render to PNG

Render the diagram to PNG:

```bash
mmdc -i "$MMD_FILE" -o "$OUT_DIR/agent-diagram-$TS.png" -b transparent --scale 2
```

To use a custom config file, add --configFile "$OUT_DIR/agent-diagram-$TS-config.json". You can also pass -t dark, -t forest, -t neutral, etc. to select a built-in theme.

### Step 4: Output the image

Output a markdown image on its own line so it renders inline:

```markdown
![Mermaid diagram](./.eca/diagrams/agent-diagram-$TS.png)
```

If the user asks for a larger view, open the PNG in its own Emacs buffer:

```bash
emacsclient --no-wait ".eca/diagrams/agent-diagram-$TS.png"
```

## Mermaid tips

- Built-in themes: default, dark, forest, neutral, base — pass via `-t <theme>`.
- For finer control, write a JSON config file with themeVariables and pass via `--configFile`. See Mermaid theming documentation for available variables.
- Always use `-b transparent` and `--scale 2` for clean inline rendering.
- Agent variables are available in the recent context; tell the user rather than generating an empty or placeholder diagram.

## Guardrails

- Output directory: always write to `.eca/diagrams/` in the workspace (not `/tmp` or other out-of-workspace paths). Create the directory with `mkdir -p` before writing.
- Flattening: always use a Unix timestamp (`$(date +%s)`). Never use descriptive names — avoid collisions and leaking context into filenames. Use the same timestamp for all related files.
- Styling: optionally use a single stylesheet. Avoid multiple stylesheets or placeholders.
- Diagram types: pick the type that best represents the data — don't default to one type for everything.
- Data access: if there is nothing diagrammable in the recent context, inform the user rather than generating an empty or placeholder diagram.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `mmdc: command not found` | Mermaid CLI not installed | Install `@mermaid-js/mermaid-cli` |
| `Error: Failed to parse` | Syntax error in `.mmd` file | Validate Mermaid syntax locally |
| `Error: Could not load config` | Config file path incorrect | Check `--configFile` path |
| Image not rendering | File path incorrect | Verify PNG path matches output location |
| Image broken icon | PNG not generated | Check mmdc output for errors |
