We are about to lose all chat context. Create or update a durable checkpoint in the user's Org agenda.

## 1) Identify the project headline that owns the checkpoint

- If the exact target is already known (stable Org ID, exact outline path, or exact file+pos), use it.
- Otherwise, try to locate it via the org-agenda bridge using exact heading lookup.
- If the parent/project headline is ambiguous, unknown, or does not exist, STOP and ask the user:
  - where it should live
  - whether it should be created
- Do not silently invent or create a new project/root headline.
- If the parent headline is known, it is OK to create missing direct child headings `Plan` and `Memory`.

## 2) Under the known parent/project headline, ensure direct child headings `Plan` and `Memory` exist

- Prefer the org-agenda bridge helpers over ad hoc raw Elisp when possible.
- Prefer idempotent child-heading helpers (`ensure-*`) over always-insert helpers (`insert-*`) so reruns do not duplicate structure.
- Do not destroy existing subtree structure under `Plan` or `Memory`; patch or update in place.

## 3) Update the `Memory` subtree

Keep it concise; target <= 120 lines if practical.

Include:

- Goal
- Current status (1–3 bullets)
- Key decisions (with a 1-line rationale for each)
- Code pointers
  - Changed files (path + 1-line summary + key symbols/functions touched)
  - Reference files worth re-reading (path + why)
- Constraints / invariants / pitfalls
- How to run / test (copy-paste commands + last observed results)
- Open questions / risks (facts vs. assumptions clearly labeled)
- Next concrete steps (up to 3; each step must include: file/symbol + command to run or check)
- An effective resume prompt
  - Must instruct: read the `Memory` subtree first, then skim the `Plan` subtree
  - Must name the immediate next task
  - Should include the exact project heading path or ID if known

## 4) Update the `Plan` subtree

- Mark completed TODOs/checkitems.
- Add or adjust next TODOs/checkitems to match the "Next concrete steps" section.
- Keep it consistent with `Memory`.
- Keep `Plan` action-oriented and lighter-weight than `Memory`.

## Rules

- If unsure, write `UNKNOWN` rather than inventing details.
- Prefer concrete identifiers (Org ID, exact heading path, file paths, symbols, commands) over vague prose.
- Patch or update in place instead of rewriting everything.
- Preserve useful existing notes/history unless they are clearly obsolete.
- If the exact parent/project headline cannot be confidently found, ask the user instead of guessing.
