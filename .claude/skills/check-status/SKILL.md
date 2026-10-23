---
name: check-status
description: Compare the current lab's Terraform code against the lab instructions up to a given step, and list missing or misconfigured resources/config with fixes.
argument-hint: <step>
---

# Check lab status

Step to check: `$1` (if empty, check up to the lab's last step).
Determine the lab directory and lab URL from the skill /read-lab in the current conversation. If either is missing, ask for it.

**Rules:** Read only, do not edit files.

1. Read `<lab>/README.md` and every `.tf` file in `<lab>/terraform/`.
2. Fetch the matching lab instructions from lab URL with WebFetch, reading only up to step `$1`.
3. Compare each step with the code. Ignore intentional differences documented in CLAUDE.md (backend, `skip_final_snapshot`, `delete_on_termination`, etc.).

## Finish

Group outputs:
**Error:** that block validate/plan.
**Missing:** resources/config not yet present.
**Wrong:** values that differ from the instructions (file:line, current → expected).

All of outputs come with suggested fix and present in table.
No need to list matching resources.

If nothing is missing or wrong, state clearly that the code matches up to step `$1`.
