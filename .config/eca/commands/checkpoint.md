We are about to lose all chat context. Create/update a durable checkpoint in-repo

1) Update (or create) MEMORY.md (keep <= 120 lines) with:
    - Goal
    - Current status (1-3 bullets)
    - Key decisions (with 1-line rationale each)
    - Code pointers:
      - Changed files (path + 1-line + key symbols/functions touched)
      - Reference files worth re-reading (paths + why)
    - Constraints / invariants / pitfalls
    - How to run / test (copy-paste commands + last observed results)
    - Open questions / risks (facts vs assumptions clearly labeled)
    - Next concrete steps (up to 3, each step including: file/symbol + command to run or check)
    - An effective resume prompt:
      - Must instruct: read MEMORY.md first, then skim PLAN.org if it exists
      - Must name the immediate next task

Rules:
    - If unsure, write "UNKNOWN" rather than inventing details
    - Prefer concrete identifiers (paths, symbols, commands) over prose
    - Don't rewrite sections that haven't changed; patch/update in place

2) If PLAN.org exists, update it:
    - Mark completed TODOs
    - Add/Adjust next TODOs to match "Next concrete steps"
    - Keep it consistent with MEMORY.md
