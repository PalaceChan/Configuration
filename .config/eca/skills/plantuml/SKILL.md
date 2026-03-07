---
name: plantuml
description: Generate diagrams from conversation context using PlantUML, rendered as PNG images inline in Emacs. Preferred for detailed UML — complex sequence diagrams with lifelines/fragments with method signatures, component/deployment architecture, and activity diagrams with swimlanes. Use when the user explicitly asks for UML or the diagram needs rich metadata. For simpler diagrams (flowcharts, ER, Gantt, git graphs), prefer the mermaid skill instead.
metadata:
  version: "1.0"
---

# PlantUML diagram generation

Generate diagrams from conversation context using PlantUML, rendered as PNG images inline in Emacs. Preferred for detailed UML — complex sequence diagrams with lifelines/fragments with method signatures, component/deployment architecture, and activity diagrams with swimlanes. Use when the user explicitly asks for UML or the diagram needs rich metadata. For simpler diagrams (flowcharts, ER, Gantt, git graphs), prefer the mermaid skill instead.

## Preconditions

### PlantUML is installed

Verify with:

```bash
which plantuml
```

If missing, advise the user to install it.

## Workflow

### Step 1: Extract diagrammatic data

Analyze the current conversation context and identify what to diagram. If no diagrammatic data exists, inform the user and stop.

Choose the most appropriate diagram type for the data:

- Sequence: request/response flows, API call chains
- Class: type hierarchies, data models
- Component: system architecture, service boundaries
- Activity: workflows, decision trees
- State: state machines, lifecycle transitions
- Deployment: physical deployment of artifacts
- Object: object instance relationships
- Use Case: system interactions with actors

### Step 2: Write the .puml file

Write the PlantUML source to a timestamped file under `.eca/diagrams/` in the workspace:

```bash
OUT_DIR=".eca/diagrams"
mkdir -p "$OUT_DIR"
TS=$(date +%s)
PUML_FILE="$OUT_DIR/agent-diagram-$TS.puml"
```

Write the .puml file with the diagram content. Choose a theme and color scheme that makes the diagram clear and visually appealing. You have full creative freedom over styling.

### Step 3: Render to PNG

Render the diagram to PNG:

```bash
plantuml "$PUML_FILE"
```

The output PNG will be at the same path with a .png extension (agent-diagram-$TS.png).

### Step 4: Output the image

Output a markdown image on its own line so it renders inline:

```markdown
![PlantUML diagram](./.eca/diagrams/agent-diagram-$TS.png)
```

If the user asks for a larger view, open the PNG in its own Emacs buffer:

```bash
emacsclient --no-wait ".eca/diagrams/agent-diagram-$TS.png"
```

## PlantUML tips

- Use `!theme` directives to style diagrams — pick whatever looks clear and readable.
- PlantUML ships with built-in themes (e.g., `!theme cerulean`, `!theme black-and-white`, `!theme bluegray`, `!theme crt-amber`, `!theme cyborg`, `!theme hacker`, `!theme lightgray`, `!theme materia`, `!theme metal`, `!theme minty`, `!theme plain`, `!theme sandstone`, `!theme silver`, `!theme sketchy-outline`, `!theme spacelab`, `!theme superhero`, `!theme united`).
- Use `skinparam` for finer-grained control over colors, fonts, and spacing.
- Add comments to the diagram source to help users understand the diagram's purpose and functionality.
- Use `!include` to incorporate common definitions or style files.

## Guardrails

- Output directory: always write to `.eca/diagrams/` in the workspace (not `/tmp` or other out-of-workspace paths). Create the directory with `mkdir -p` before writing.
- Flattening: always use a Unix timestamp (`$(date +%s)`). Never use descriptive names — avoid collisions and leaking context into filenames. Use the same timestamp for all related files.
- Diagram types: pick the type that best represents the data — don't default to one type for everything.
- Data access: if there is nothing diagrammable in the recent context, inform the user rather than generating an empty or placeholder diagram.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `plantuml: command not found` | PlantUML not installed or not on `$PATH` | Advise user to install PlantUML |
| Diagram too large / cluttered | Diagram complexity too high | Simplify diagram or split into multiple diagrams |
| Image not rendering | Markdown image syntax wrong or path incorrect | Verify the `.puml` file exists and the image path is correct |
| PNG not generated | PlantUML execution failed | Check PlantUML syntax in `.puml` file |
| Missing actors/elements | Syntax errors in diagram definition | Validate PlantUML syntax locally |
