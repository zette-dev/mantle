# Work Execution Templates

## Subagent Prompt Template

````
Task(general-purpose):
"""
## Your Job
Implement Task [ID] from the plan.

## Plan File
Read the plan at: `[absolute path to plan file]`

## How to Orient (do this quickly)
1. Read **Phase Summaries** (`> **Phase Summary`) for completed phases
2. Read **checkpoint notes** (`> **Checkpoint [ID]`) for the CURRENT phase only
3. Find **Task [ID]** — read its description and requirements carefully

## Project
- Working directory: `[absolute path]`
- Branch: `[branch name]`
- Test command: `[project test command]`
- Project conventions: see CLAUDE.md

## How to Implement
1. Read files referenced by the plan or recent checkpoints
2. Find existing patterns in the codebase to follow
3. Implement the task following established conventions
4. Write tests for new functionality
5. Run the test command and fix any failures
6. Do NOT modify the plan file — the orchestrator handles that

## Respond With a Structured Summary
When done, return ONLY this (not file contents):
1. **Files changed**: list of created/modified/deleted files
2. **What was done**: 2-3 sentence description
3. **Decisions made**: any non-obvious choices and reasoning
4. **Test results**: pass/fail, number of tests, command output summary
5. **Issues or caveats**: anything unresolved or worth noting
6. **Next task context**: what the next task's subagent needs to know
"""
````

## Checkpoint Format

After each subagent completes, check off the item and write a checkpoint note:

```markdown
- [x] **1.1** Create user model with Argon2 password hashing
  > **Checkpoint 1.1 (2026-02-08 14:30):** Created `src/auth/service.dart` with
  > Argon2 hashing. Tests in `test/auth/service_test.dart` (12 assertions, pass).
  > Decision: Used dart_argon2 over bcrypt for WASM compat.
  > Next: Wire up to AuthController.login().
```

Each checkpoint MUST include:
1. **Timestamp**
2. **What was done** — files created/modified
3. **Key decisions** — non-obvious choices and why
4. **Current state** — tests passing? caveats?
5. **Next step context** — what the next task needs to know

## Phase Summary Format

At phase boundaries, write a Phase Summary:

```markdown
### Phase 1: Foundation [COMPLETED]
> **Phase Summary (2026-02-08 15:45):**
> Created 4 files: auth_service.dart, auth_controller.dart, auth_test.dart, auth_middleware.dart
> All 24 tests pass. Branch: feat/user-auth (3 commits ahead of main).
> Known issues: Email validation not yet wired to frontend.
> Resume from: Phase 2, Task 1 (Frontend login form)
```

**Tiered reading strategy:** Subagents read Phase Summaries (quick scan) for completed phases, checkpoint notes (carefully) for the current phase, then focus on their specific task.
