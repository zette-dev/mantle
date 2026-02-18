---
name: mantle:work
model: opus
description: Execute work plans efficiently while maintaining quality and finishing features
argument-hint: "[plan file, specification, or todo file path]"
---

# Work Plan Execution Command

Execute a work plan systematically. Focus: **ship complete features** by understanding requirements quickly, following existing patterns, and maintaining quality.

## Input Document

<input_document> #$ARGUMENTS </input_document>

## Execution Workflow

### Phase 1: Quick Start

1. **Read Plan and Check for Existing Progress**

   - Read the work document completely
   - Scan for `> **Checkpoint` and `> **Phase Summary` lines
   - If checkpoints found: resume from last checkpoint, skip completed tasks
   - If fresh start: review references/links, ask clarifying questions, get user approval
   - **Do not skip this** — better to ask questions now than build the wrong thing

2. **Setup Environment**

   First, detect the root branch and current branch:

   ```bash
   current_branch=$(git branch --show-current)
   default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

   # Fallback if remote HEAD isn't set
   if [ -z "$default_branch" ]; then
     default_branch=$(git rev-parse --verify origin/main >/dev/null 2>&1 && echo "main" || echo "master")
   fi
   ```

   **If resuming (checkpoints found in step 1):**
   - The plan's checkpoint notes will reference the branch/worktree used. Continue on that same branch — do NOT ask, just switch to it.
   - If the branch no longer exists, inform the user and treat as a fresh start.

   **If fresh start (no checkpoints):**
   **MANDATORY: Ask the user how to set up the branch.** Use `AskUserQuestion` with these options:

   | Option | Description |
   |--------|-------------|
   | **Worktree (Recommended)** | Isolated worktree — keeps root branch clean, good for parallel work |
   | **New branch** | Simple feature branch from the root branch |
   | **Stay on root branch** | Commit directly (requires explicit "yes" confirmation) |

   **Do NOT skip this question. Do NOT pick one silently.** Always ask on fresh starts.

   Then execute the chosen setup:
   - **Worktree**: Use the `git-worktree` skill to create an isolated worktree
   - **New branch**: `git pull origin [root_branch] && git checkout -b feature-branch-name`
   - **Stay on root branch**: Only after user explicitly confirms

   **Branch naming:** If the work originates from a Linear issue, use `get_issue_git_branch_name` from the Linear MCP to get the branch name. Otherwise, use a meaningful name based on the work (e.g., `feat/user-authentication`, `fix/email-validation`).

3. **Verify Subagent Permissions**

   Check `.claude/settings.local.json` includes `Edit` and `Write` in the allow list. If not, warn the user that subagents will need write permission.

4. **Create Todo List**

   Use TodoWrite to break plan into actionable, prioritized tasks with dependencies. Include testing tasks.

### Phase 2: Execute

> **Context Management Strategy**: The main context is a **lean orchestrator**. It manages the todo list, checkpoints, and commits — but never reads implementation files. Each task is delegated to a `general-purpose` subagent that reads the full plan file (including all prior checkpoint notes), giving it complete project context. The subagent implements the task, runs tests, and returns a compact summary. The orchestrator writes that summary as a checkpoint in the plan, then moves to the next task. This keeps the main context small while each subagent gets the full picture. Tasks run sequentially — accuracy and autonomy matter more than speed.

1. **Task Execution Loop (One Subagent Per Task)**

   For each task in priority order:

   ```
   while (tasks remain):
     a. Mark task as in_progress in TodoWrite
     b. Determine: delegate to subagent or do inline? (see heuristic)
     c. If delegating: launch Task(general-purpose) with plan file path
     d. Read the subagent's summary response
     e. Update the plan: check off item ([ ] → [x]) and write checkpoint from summary
     f. Mark task as completed in TodoWrite
     g. Evaluate for incremental commit (see below)
   ```

   **WHEN TO DELEGATE vs. DO INLINE**: Most tasks should be delegated. Only do trivial changes inline.

   | Delegate to subagent (default) | Do inline (exception) |
   |--------------------------------|-----------------------|
   | Any task that creates or modifies code | Updating a single line or config value |
   | Any task that requires reading files | Simple rename or flag change |
   | Any task with test writing or running | Git operations (commit, branch, push) |
   | Anything you'd need to "think about" | Editing the plan file itself |

   **TASK IDs**: Refer to tasks by their plan ID (e.g., `1.1`, `2.1`). Plans should number tasks within each phase.

   **SUBAGENT PROMPT TEMPLATE**:

   ````
   Task(general-purpose):
   """
   ## Your Job
   Implement Task [ID] from the plan.

   ## Plan File
   Read the plan at: `[absolute path to plan file]`

   ## How to Orient (do this quickly)
   1. Read **Phase Summaries** (`> **Phase Summary`) for any completed phases — this gives you the big picture without reading every old checkpoint
   2. Read **checkpoint notes** (`> **Checkpoint [ID]`) for tasks in the CURRENT phase only — these are recent and directly relevant to your work
   3. Find **Task [ID]** — read its description and requirements carefully

   ## Project
   - Working directory: `[absolute path]`
   - Branch: `[branch name]`
   - Test command: `[project test command, e.g., npm test, pytest, flutter test]`
   - Project conventions: see CLAUDE.md

   ## How to Implement
   1. Read any files referenced by the plan or recent checkpoints
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

   **KEY RULES FOR THE ORCHESTRATOR**:
   - Do NOT read implementation files in the main context. The subagent reads whatever it needs.
   - Do NOT construct detailed context in the prompt. The plan file IS the context — just point to the task ID.
   - DO update the plan with checkpoint notes after each subagent — this is what gives the NEXT subagent its context.
   - DO keep tasks sequential. Each subagent builds on the prior one's work. No parallel execution.

   **HANDLING FAILURES**: If a subagent reports problems:
   - **Test failures**: Launch a new subagent with the same plan file path plus the failure details appended to the prompt. The new subagent reads the plan, sees the checkpoint context, and fixes the issue.
   - **Ambiguity**: Ask the user for clarification, then re-launch with the answer added to the prompt.
   - **Blocked dependency**: Skip the task, move to the next unblocked one, come back later.
   - **Permission errors**: If a subagent can't write files, check `.claude/settings.local.json` for `Edit` and `Write` in the allow list.

2. **Checkpoint Notes (The Handoff Mechanism)**

   Checkpoints serve a dual purpose: they let the orchestrator resume after compaction, AND they give the next subagent full context about what was built. Every checkpoint you write becomes part of the plan file that the next subagent reads.

   After each subagent completes, the orchestrator updates the plan file:

   **Check off completed items**: Use Edit to change `- [ ]` to `- [x]`.

   **Write checkpoint notes** below the checked item. Include the task ID so subagents can scan efficiently:

   ```markdown
   - [x] **1.1** Create user model with Argon2 password hashing
     > **Checkpoint 1.1 (2026-02-08 14:30):** Created `src/auth/service.dart` with
     > Argon2 hashing. Tests in `test/auth/service_test.dart` (12 assertions, pass).
     > Decision: Used dart_argon2 over bcrypt for WASM compat.
     > Next: Wire up to AuthController.login().
   ```

   Each checkpoint MUST include (sourced from subagent summary):
   1. **Timestamp** - when completed
   2. **What was done** - files created/modified
   3. **Key decisions** - non-obvious choices and why (the next subagent needs these to stay consistent)
   4. **Current state** - tests passing? caveats?
   5. **Next step context** - what the next task needs to know

   **TIERED READING STRATEGY**: Subagents read Phase Summaries (quick scan) for completed phases, checkpoint notes (carefully) for the current phase, then focus on their specific task. This keeps orientation fast as the plan file grows.

   **PHASE SUMMARIES**: At phase boundaries, write a Phase Summary:

   ```markdown
   ### Phase 1: Foundation [COMPLETED]
   > **Phase Summary (2026-02-08 15:45):**
   > Created 4 files: auth_service.dart, auth_controller.dart, auth_test.dart, auth_middleware.dart
   > All 24 tests pass. Branch: feat/user-auth (3 commits ahead of main).
   > Known issues: Email validation not yet wired to frontend.
   > Resume from: Phase 2, Task 1 (Frontend login form)
   ```

   **CODE SIMPLIFICATION PASS (After Every Phase)**: After writing the Phase Summary, run `Task(code-simplifier:code-simplifier)` over the phase's changed files. Point it at the files listed in the Phase Summary. Run tests after to confirm nothing broke, then commit any changes: `refactor(scope): simplify phase N implementation`.

3. **Incremental Commits (Orchestrator Responsibility)**

   Commit when a logical unit is complete and tests pass. Heuristic: if the commit message would be "WIP", wait. Stage specific files (not `git add .`). Use clean conventional messages without attribution — the final PR commit includes attribution.

4. **Follow Existing Patterns**

   Include pattern references in subagent prompts. Don't reinvent — match what exists.

5. **Figma Design Sync** (if applicable)

   Include Figma requirements in subagent prompts. After completion, use figma-design-sync agent to compare.

6. **Track Progress** — Keep TodoWrite updated. Note blockers. Create new tasks if scope expands.

### Phase 3: Quality Check

1. **Run Code-Simplifier** (MANDATORY)

   Run the code-simplifier on all changed files to review the full feature holistically. This evaluates the work as a whole — not per-task — to catch unnecessary complexity, redundancy, or simplification opportunities across the entire changeset.

   ```
   Task(pr-review-toolkit:code-simplifier): "Simplify all changes on this branch"
   ```

   Commit any simplifications before proceeding to linting. **Do NOT skip this step.**

2. **Run Core Quality Checks**

   Always run before submitting:

   ```bash
   # Run full test suite (use project's test command)
   # Examples: npm test, pytest, go test, flutter test, etc.

   # Run linting (per CLAUDE.md or project config)
   ```

   **IMPORTANT: Commit lint reformats.** When linting tools (formatters, import sorters, analyzers) reformat files, those changes enforce the project's code standards. Stage and commit ALL files modified by linting — do NOT discard them. Use a separate commit like `style: apply lint formatting` if the feature commit is already done.

3. **Consider Reviewer Agents** (Optional)

   Use for complex, risky, or large changes:

   - **code-simplicity-reviewer**: Check for unnecessary complexity
   - **performance-oracle**: Check for performance issues
   - **security-sentinel**: Scan for security vulnerabilities
   - Any framework-specific review agents from installed plugins

   Run reviewers in parallel with Task tool:

   ```
   Task(code-simplicity-reviewer): "Review changes for simplicity"
   Task(performance-oracle): "Check for performance issues"
   ```

   Present findings to user and address critical issues.

4. **Final Validation**
   - All TodoWrite tasks marked completed
   - All tests pass
   - Linting passes
   - Lint reformats committed (not discarded)
   - Code follows existing patterns
   - Code-simplifier has run and changes committed
   - Figma designs match (if applicable)
   - No console errors or warnings

### Phase 4: Ship It

Every completed work session ends with a commit and PR. This is not optional.

1. **Update Plan Document**

   Before committing, write the final Phase Summary in the plan document (if not already done during Phase 2 checkpoints). The plan document lives in the repo — it must be committed on the feature branch, not updated after switching back to the root branch.

2. **Create Commit**

   ```bash
   git add .
   git status  # Review what's being committed
   git diff --staged  # Check the changes

   # Commit with conventional format
   git commit -m "$(cat <<'EOF'
   feat(scope): description of what and why

   Brief explanation if needed.

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

3. **Capture Screenshots for UI Changes** (if applicable)

   For any UI work, capture before/after screenshots using the `agent-browser` skill. Include uploaded image URLs in the PR description.

4. **Create Pull Request** (ALWAYS)

   A PR is created for every work session, no exceptions. This ensures all work is reviewable and traceable.

   ```bash
   git push -u origin feature-branch-name

   gh pr create --title "Feature: [Description]" --body "$(cat <<'EOF'
   ## Summary
   - What was built
   - Why it was needed
   - Key decisions made

   ## Testing
   - Tests added/modified
   - Manual testing performed

   ## Before / After Screenshots
   | Before | After |
   |--------|-------|
   | ![before](URL) | ![after](URL) |

   ## Figma Design
   [Link if applicable]

   ---

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

5. **Notify User and Archive Plan**
   - Summarize what was completed
   - Link to PR
   - Note any follow-up work needed
   - Ask: "Move the plan file to `docs/plans/complete/`?" If yes, `mkdir -p docs/plans/complete && git mv [plan file] docs/plans/complete/`

---

## Swarm Mode (Optional)

For plans with 5+ independent tasks, use swarm mode for parallel execution. Say "Use swarm mode for this work" to enable. See the `orchestrating-swarms` skill for patterns and API details.

---

## Quality Checklist

Before creating PR, verify:

- [ ] All clarifying questions asked and answered
- [ ] All TodoWrite tasks marked completed
- [ ] Code-simplifier run on full changeset
- [ ] Tests pass (run project's test command)
- [ ] Linting passes
- [ ] Lint reformats committed (not discarded)
- [ ] Plan document updated on feature branch (not after switching back)
- [ ] Code follows existing patterns
- [ ] Figma designs match implementation (if applicable)
- [ ] Before/after screenshots captured and uploaded (for UI changes)
- [ ] Commit messages follow conventional format
- [ ] PR description includes summary, testing notes, and screenshots
- [ ] PR description includes attribution footer

## Pitfalls

- Never read implementation files in the orchestrator — delegate to subagents
- Never skip or skimp on checkpoints — they're the handoff between subagents
- Never parallelize subagents — sequential execution is intentional
- Test continuously, not at the end
- Finish features completely — no 80% done
