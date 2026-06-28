---
name: gcalcli
description: Manage Google Calendar from the command line via gcalcli — view agenda, quick-add events, search, list calendars, add detailed events, delete/edit events, and more. All results are displayed inline.
metadata:
  version: "1.0"
---

# gcalcli — Google Calendar CLI

Manage Google Calendar directly from the shell using `gcalcli`, which wraps the official Google Calendar API v3. This skill covers the full lifecycle: viewing your schedule, creating events, searching, editing, deleting, and importing.

## Preconditions

### gcalcli must be installed

Verify with:

```bash
which gcalcli
```

If missing, install it. Recommended approach on Arch Linux:

```bash
python -m venv ~/.local/venvs/gcalcli
~/.local/venvs/gcalcli/bin/pip install gcalcli
ln -sf ~/.local/venvs/gcalcli/bin/gcalcli ~/.local/bin/gcalcli
```

### gcalcli must be authenticated

Before first use, the user must run the OAuth 2.0 init flow:

```bash
gcalcli init
```

This opens a browser for the user to authorize gcalcli. After that, a token is stored locally (default: `~/.config/gcalcli/`).

Verify authentication is working:

```bash
gcalcli list
```

If the user hasn't done this yet, ask them to run `gcalcli init` and complete the browser auth flow. If the token has expired, re-run `gcalcli init`.

### Calendar names

The user's primary calendar is usually just their email address (e.g., `user@gmail.com`). Additional calendars have whatever name they were given. Use `gcalcli list` to discover calendar names if unsure.

## Workflow: Golden-path operations

### 1. List available calendars

```bash
gcalcli list
```

This shows all calendars the user has access to, along with their access level (owner/writer/reader).

### 2. View today's agenda

```bash
gcalcli agenda
```

Or for a specific day:

```bash
gcalcli agenda "tomorrow"
gcalcli agenda "2026-03-20"
gcalcli agenda "next monday" "next friday"
```

Pass `--military` for 24-hour time, `--width 120` for wider output, `--nodeclined` to hide declined events.

Show details (location, description, calendar name, etc.):

```bash
gcalcli agenda --details location,description,calendar
```

Show all details:

```bash
gcalcli agenda --details all
```

### 3. See a week or month calendar view

Week view (defaults to current week):

```bash
gcalcli calw
```

Start on Monday:

```bash
gcalcli calw --monday
```

Month view:

```bash
gcalcli calm
```

### 4. Quick-add an event (natural language)

The `quick` command parses natural language for the fastest event creation:

```bash
gcalcli quick "Lunch with Sarah tomorrow at 12pm"
gcalcli quick "Meeting next monday 3pm-4pm"
gcalcli quick "Dentist appointment on friday at 10am"
```

If the user has multiple calendars, specify one:

```bash
gcalcli quick "Coffee at 2pm" --calendar "Work"
```

Multiple reminders:

```bash
gcalcli quick "Team standup tomorrow 9am" --reminder "10m popup" --reminder "1h email"
```

### 5. Add a detailed event

For events that need location, description, attendees, etc.:

```bash
gcalcli add \
  --title "Project Review" \
  --when "2026-03-20 14:00" \
  --duration 60 \
  --where "Conference Room B" \
  --description "Quarterly review with the team" \
  --who "colleague@example.com" \
  --noprompt
```

All-day event:

```bash
gcalcli add \
  --title "Team Offsite" \
  --when "2026-04-01" \
  --allday \
  --duration 2 \
  --noprompt
```

### 6. Search for events

```bash
gcalcli search "dentist"
gcalcli search "meeting" "next week"
```

### 7. Edit an event (interactive)

```bash
gcalcli edit "dentist"
```

This opens an interactive prompt to choose which matching event to edit and what to change.

### 8. Delete an event (interactive)

```bash
gcalcli delete "dentist"
```

This searches and interactively prompts for confirmation. To skip confirmation:

```bash
gcalcli delete "dentist" --iamaexpert
```

### 9. Import an .ics file

```bash
gcalcli import event.ics
gcalcli import event.ics --calendar "Work"
```

## Tips

- **Natural language dates**: `gcalcli` accepts many formats — `"today"`, `"tomorrow"`, `"next monday"`, `"friday"`, `"+3 days"`, `"2026-03-20"`, etc.
- **Multiple calendars**: use `--calendar "CalendarName"` to target a specific calendar. For agenda/calw/calm, you can pass `--calendar` multiple times to show several calendars at once.
- **TSV output**: `--tsv` gives tab-separated output, useful for piping to other tools or for parsing programmatically.
- **Combining with Emacs**: you can capture gcalcli output into Emacs buffers, e.g.:
  ```bash
  emacsclient --eval "(with-current-buffer (get-buffer-create \"*gcalcli*\") (erase-buffer) (insert (shell-command-to-string \"gcalcli agenda today\")) (display-buffer (current-buffer)))"
  ```
- **Config file**: gcalcli reads `~/.config/gcalcli/config.toml` for persistent settings (default calendar, colors, etc.).

## Guardrails

- **Authentication**: If `gcalcli list` or any command fails with an auth error, tell the user to re-run `gcalcli init`.
- **Destructive operations**: `delete` and `edit` are interactive by default and require user confirmation. If the user wants non-interactive deletion, use `--iamaexpert` only after confirming with the user.
- **Calendar targeting**: when the user has multiple calendars, always ask or confirm which calendar to use unless they already specified one. Don't assume "primary" unless you've verified it.
- **No unsolicited event creation**: always confirm the event details with the user before running `quick` or `add`. Show them the exact command you're about to run and get their OK.
- **Timezones**: gcalcli uses the system timezone by default. Be mindful of this when the user specifies times in a different timezone — prefer to adjust the command rather than silently using the wrong time.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `gcalcli: command not found` | Not installed or not on PATH | Install gcalcli and ensure `~/.local/bin` is in PATH |
| `ERROR: No authentication token found` | Never authenticated | Run `gcalcli init` and complete the browser OAuth flow |
| `ERROR: Token invalid/expired` | Token expired | Re-run `gcalcli init` |
| `ERROR: No calendars found` | No calendars or wrong auth account | Run `gcalcli list` to check; verify the authorized Google account has calendars |
| `No events found` | Truly no events in that period | Try a wider date range or check a different calendar |
| `The calendar doesn't exist` | Wrong calendar name | Run `gcalcli list` to get the exact name |
| `quick` command seems to misparse | Natural language is ambiguous | Use `add` with explicit `--when` and `--duration` instead |
| Color output looks garbled | Terminal doesn't support ANSI colors | Use `--nocolor` flag |
