---
name: mantle:work
model: opus
description: "Execute work plans, specifications, or todo files by delegating tasks to subagents. Use when ready to implement a plan from /mantle:plan or any structured task list."
argument-hint: "[plan file, specification, or todo file path]"
---

# Work Plan Execution

Ship complete features by delegating tasks to subagents while maintaining quality. The main context is a **lean orchestrator** — it manages the todo list, checkpoints, and commits but never reads implementation files.

## Input Document

<input_document> #$ARGUMENTS </input_document>

## Phase 1: Quick Start

1. **Read Plan and Check for Existing Progress**

   - Read the work document completely
   - Scan for `> **Checkpoint` and `> **Phase Summary` lines
   - If checkpoints found: resume from last checkpoint, skip completed tasks
   - If fresh start: review references/links, ask clarifying questions, get user approval
   - **Do not skip this** — better to ask now than build the wrong thing

2. **Setup Environment**

   Detect the current branch and default branch (main or master).

   **If resuming (checkpoints found):**
   Continue on the branch referenced in checkpoint notes. If it no longer exists, inform the user and treat as fresh start.

   **If fresh start:**
   Use AskUserQuestion to ask how to set up the branch:

   | Option | Description |
   |--------|-------------|
   | **Worktree (Recommended)** | Isolated worktree — keeps root branch clean, good for parallel work |
   | **New branch** | Feature branch from the default branch |
   | **Stay on current branch** | Commit directly (requires explicit confirmation) |

   Then execute: worktree via `git-worktree` skill, new branch via `git checkout -b`, or stay after confirmation.

   **Branch naming:** If from a Linear issue, use `get_issue_git_branch_name` from Linear MCP. Otherwise, use a meaningful name (e.g., `feat/user-authentication`, `fix/email-validation`).

3. **Create Todo List**

   Use TodoWrite to break the plan into actionable, prioritized tasks with dependencies. Include testing tasks.

## Phase 2: Execute

Tasks run sequentially — each subagent builds on the prior one's work.

1. **Task Execution Loop**

   ```
   while (tasks remain):
     a. Mark task as in_progress in TodoWrite
     b. Determine: delegate to subagent or do inline?
     c. If delegating: launch Task(general-purpose) — see work-templates.md
     d. Read the subagent's summary response
     e. Update the plan: check off item and write checkpoint from summary
     f. Mark task as completed in TodoWrite
     g. Commit when a logical unit is complete and tests pass
   ```

   **When to delegate vs do inline:** Default to delegating. Only do trivial changes inline (single line edits, config value changes, git operations, editing the plan file itself).

   **Task IDs:** Refer to tasks by their plan ID (e.g., `1.1`, `2.1`).

2. **Subagent Prompts and Checkpoints**

   Use the subagent prompt template, checkpoint format, and phase summary format from [work-templates.md](work-templates.md).

   **Key rules:**
   - Do NOT read implementation files in the orchestrator — the subagent reads what it needs
   - Do NOT construct detailed context in the prompt — the plan file IS the context
   - DO update the plan with checkpoint notes after each subagent
   - DO keep tasks sequential — no parallel execution

3. **Handling Failures**

   - **Test failures**: Launch a new subagent with the plan file path plus failure details
   - **Ambiguity**: Ask the user, then re-launch with the answer
   - **Blocked dependency**: Skip, move to next unblocked task, come back later

4. **After Each Phase**

   Write a Phase Summary (see [work-templates.md](work-templates.md)), then run `/simplify` over the phase's changed files. Run tests to confirm nothing broke, then commit: `refactor(scope): simplify phase N implementation`.

5. **Commits**

   Commit when a logical unit is complete and tests pass. Stage specific files (not `git add .`). Use conventional commit messages. Save attribution for the final PR.

6. **Figma** (if applicable): Compare implementation against Figma designs after completion and include screenshots in the PR.

## Phase 3: Quality Check

1. **Code Simplifier** (mandatory) — Run `/simplify` on all changed files to catch unnecessary complexity across the full changeset. Commit simplifications before proceeding.

2. **Tests and Linting** — Run the project's full test suite and linter. Commit any lint reformats — don't discard them.

3. **Reviewer Agents** (optional, for complex/risky changes) — Run in parallel:
   - `code-simplicity-reviewer`: unnecessary complexity
   - `performance-oracle`: performance issues
   - `security-sentinel`: security vulnerabilities

4. **Final Validation**: All TodoWrite tasks completed, tests pass, linting passes, lint reformats committed, code follows existing patterns.

## Phase 4: Ship It

1. **Update Plan** — Write final Phase Summary in the plan document before switching branches. The plan lives in the repo and must be committed on the feature branch.

2. **Commit and PR** — Push the branch and create a PR. Include: summary of what was built and why, key decisions, testing notes, and screenshots for UI changes. Use the attribution footer:
   ```
   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

3. **Wrap Up** — Summarize what was completed, link to PR, note follow-up work. Ask: "Move the plan file to `docs/plans/complete/`?"

---

For plans with 5+ independent tasks, consider the `orchestrating-swarms` skill for parallel execution.
