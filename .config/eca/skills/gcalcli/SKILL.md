---
name: gcalcli
description: "Manage Google Calendar with gcalcli: inspect calendars, view agendas, search events, and create/update/delete events only after explicit confirmation."
metadata:
  version: "1.0"
---

# gcalcli skill

Use `gcalcli` to manage the user's Google Calendar from the shell. Prefer concise, read-only commands for inspection, and require explicit user confirmation before creating, editing, importing, or deleting events.

## Setup checks

1. Verify the command exists:

   ```bash
   command -v gcalcli && gcalcli --version
   ```

2. Verify authentication and list calendars:

   ```bash
   gcalcli --nocolor list
   ```

3. If auth is missing or `gcalcli init` prompts for `Client ID`, the user must first create Google OAuth credentials:

   - Create or reuse a Google Cloud project.
   - Enable the Google Calendar API for that project.
   - Configure the OAuth consent screen for personal/testing use.
   - Add the user's Google account as a test user if the app is in testing mode.
   - Create an OAuth Client ID with application type `Desktop app`.
   - Copy the generated Client ID and Client Secret.

4. Finish auth by passing the Client ID to `gcalcli` and completing the browser-based Google OAuth flow:

   ```bash
   gcalcli --client-id="CLIENT_ID.apps.googleusercontent.com" init
   # or trigger setup with a first read-only command:
   gcalcli --client-id="CLIENT_ID.apps.googleusercontent.com" list
   ```

   When prompted, paste the Client Secret. After auth completes, retry `gcalcli --nocolor list`.

5. Optional config lives at `~/.config/gcalcli/config.toml`. `gcalcli` also supports `GCALCLI_CONFIG` and `--config-folder`; prefer the default unless the user has a custom setup.

## Operating rules

- Use global display flags before the subcommand, for example `gcalcli --nocolor agenda`.
- Use `--calendar "Name"` when the target calendar matters. If there are multiple writable calendars and the user did not specify one, ask which calendar to use.
- For read-only output shown in chat, prefer `--nocolor`; use `--lineart ascii` if Unicode/ANSI box drawing is hard to read.
- Do not create, edit, import, or delete events without first summarizing the exact intended change and getting the user's explicit OK.
- After creating, editing, importing, or deleting an event, verify the result with a read-only `search` or `agenda` command.
- Avoid interactive commands unless the user is present and expects interaction. `edit` and `delete` are interactive by default.
- Never use `delete --iamaexpert` unless the user explicitly confirmed the exact deletion.
- Be precise with dates and time zones. If the user uses relative dates such as "tomorrow", restate the resolved calendar date before creating or changing an event.

## Common read-only commands

List calendars:

```bash
gcalcli --nocolor list
```

Show agenda:

```bash
gcalcli --nocolor agenda
gcalcli --nocolor agenda "today" "tomorrow"
gcalcli --nocolor agenda "2026-07-01" "2026-07-08" --details all
```

Week/month views:

```bash
gcalcli --nocolor calw --monday --width 120
gcalcli --nocolor --lineart ascii calm
```

Search events:

```bash
gcalcli --nocolor search "dentist"
gcalcli --nocolor search "meeting" "next week"
gcalcli --nocolor search "project" "2026-07-01" "2026-07-31" --details all
```

Useful output options:

- `--details all` for complete details, or one supported detail field such as `calendar`, `location`, `description`, `attendees`, or `end`
- `--nodeclined` to hide declined events
- `--military` for 24-hour time
- `--width 120` for wider agenda/calendar output
- `--tsv` for tab-separated output when parsing results

## Creating events

After confirmation, use `quick` for simple natural-language events. Pass exactly one target calendar unless the user's default calendar is known and acceptable.

```bash
gcalcli quick --calendar "Work" "Team standup tomorrow 9am"
gcalcli quick --calendar "Personal" "Lunch with Sarah Friday at 12pm" --reminder "10m popup"
```

Use `add` when details should be explicit. If the user asks for no alerts/reminders, omit `--reminder` and do not pass `--default-reminders`.

```bash
gcalcli add \
  --calendar "Work" \
  --title "Project Review" \
  --when "2026-07-15 14:00" \
  --duration 60 \
  --where "Conference Room B" \
  --description "Quarterly review with the team" \
  --who "colleague@example.com" \
  --reminder "10m popup" \
  --noprompt
```

All-day or multi-day event:

```bash
gcalcli add \
  --calendar "Personal" \
  --title "Vacation" \
  --when "2026-08-03" \
  --allday \
  --duration 5 \
  --noprompt
```

## Editing, deleting, and importing

Find candidate events first with `search`, then confirm the exact event and action with the user.

Interactive edit:

```bash
gcalcli edit "dentist" "next month"
```

Interactive delete:

```bash
gcalcli delete "dentist" "next month"
```

Non-interactive delete, only after explicit confirmation:

```bash
gcalcli delete "dentist" "2026-07-01" "2026-07-31" --iamaexpert
```

Import an ICS file, only after confirming the file and calendar:

```bash
gcalcli import "/absolute/path/to/event.ics" --calendar "Work"
```

Verify changes afterward:

```bash
gcalcli --nocolor --lineart ascii search "Project Review" "2026-07-15" "2026-07-16" --details all
```

## Troubleshooting

- `command not found`: install `gcalcli` and ensure it is on `PATH`.
- Auth errors or first command hangs: run setup checks again; if `Client ID` is requested, use the OAuth credential flow above.
- `Error 403: access_denied` with “app is currently being tested”: in the Google Cloud project that owns the OAuth client, add the user's Google account under the OAuth consent screen's test users/audience, then retry auth with the same Client ID and Client Secret.
- Wrong or missing calendar: run `gcalcli --nocolor list` and use the exact calendar name.
- Ambiguous natural-language parsing: use `add` with explicit `--when`, `--duration`, and `--calendar`.
- Garbled color or line art: add `--nocolor`; for grid views also add `--lineart ascii`.
