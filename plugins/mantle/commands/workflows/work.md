---
name: mantle:work
description: Execute work plans efficiently while maintaining quality and finishing features
argument-hint: "[plan file, specification, or todo file path]"
---

# Work Plan Execution Command

Execute a work plan efficiently while maintaining quality and finishing features.

## Introduction

This command takes a work document (plan, specification, or todo file) and executes it systematically. The focus is on **shipping complete features** by understanding requirements quickly, following existing patterns, and maintaining quality throughout.

## Input Document

<input_document> #$ARGUMENTS </input_document>

## Execution Workflow

### Phase 1: Quick Start

1. **Read Plan and Check for Existing Progress**

   - Read the work document completely
   - **Check for checkpoint notes**: Scan for `> **Checkpoint` and `> **Phase Summary` lines
   - If checkpoints found:
     - Read ALL checkpoints to understand prior session progress
     - Identify the last completed task and first unchecked `- [ ]` item
     - Announce: "Resuming from [last checkpoint]. Prior session completed X of Y tasks."
     - Use checkpoint context to avoid re-reading files or re-making decisions
     - Skip to the first unchecked task
   - If no checkpoints found: this is a fresh start
   - Review any references or links provided in the plan
   - If anything is unclear or ambiguous, ask clarifying questions now
   - Get user approval to proceed
   - **Do not skip this** - better to ask questions now than build the wrong thing

2. **Setup Environment**

   First, check the current branch:

   ```bash
   current_branch=$(git branch --show-current)
   default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

   # Fallback if remote HEAD isn't set
   if [ -z "$default_branch" ]; then
     default_branch=$(git rev-parse --verify origin/main >/dev/null 2>&1 && echo "main" || echo "master")
   fi
   ```

   **If already on a feature branch** (not the default branch):
   - Ask: "Continue working on `[current_branch]`, or create a new branch?"
   - If continuing, proceed to step 3
   - If creating new, follow Option A or B below

   **If on the default branch**, choose how to proceed:

   **Option A: Create a new branch**
   ```bash
   git pull origin [default_branch]
   git checkout -b feature-branch-name
   ```
   Use a meaningful name based on the work (e.g., `feat/user-authentication`, `fix/email-validation`).

   **Option B: Use a worktree (recommended for parallel development)**
   ```bash
   skill: git-worktree
   # The skill will create a new branch from the default branch in an isolated worktree
   ```

   **Option C: Continue on the default branch**
   - Requires explicit user confirmation
   - Only proceed after user explicitly says "yes, commit to [default_branch]"
   - Never commit directly to the default branch without explicit permission

   **Recommendation**: Use worktree if:
   - You want to work on multiple features simultaneously
   - You want to keep the default branch clean while experimenting
   - You plan to switch between branches frequently

3. **Verify Subagent Permissions**

   This command delegates implementation tasks to subagents that need file write access. Check that the project's `.claude/settings.local.json` includes `Edit` and `Write` in the allow list:

   ```json
   {
     "permissions": {
       "allow": ["Edit", "Write", "Bash(git:*)"]
     }
   }
   ```

   If not configured, warn the user: "Subagents will need write permission. You'll be prompted to approve the first file write — select 'Allow for this session' for smooth operation, or add `Edit` and `Write` to your project settings."

4. **Create Todo List**
   - Use TodoWrite to break plan into actionable tasks
   - Include dependencies between tasks
   - Prioritize based on what needs to be done first
   - Include testing and quality check tasks
   - Keep tasks specific and completable

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

   **TASK IDs**: The orchestrator refers to each task by its ID from the plan (e.g., `1.1`, `1.2`, `2.1`). Plans should number tasks within each phase:

   ```markdown
   ### Phase 1: Foundation
   - [ ] **1.1** Create user model with Argon2 password hashing
   - [ ] **1.2** Add authentication service with login/logout
   - [ ] **1.3** Write auth middleware for protected routes

   ### Phase 2: Frontend
   - [ ] **2.1** Build login form component
   - [ ] **2.2** Add session management to app state
   ```

   **SUBAGENT PROMPT TEMPLATE**: The prompt points the subagent to a specific task ID. The subagent reads the plan file to orient itself, then focuses on implementation.

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

   **Write thorough checkpoints.** These aren't just for you — they're the primary way each subagent understands what was built. Skimpy checkpoints lead to inconsistent implementations. But note: subagents in later phases read **phase summaries** for completed phases, not individual checkpoints. So the checkpoints matter most for tasks within the same phase. Phase summaries matter for cross-phase context.

   **TIERED READING STRATEGY**: Subagents don't read the entire plan deeply. They use a tiered approach:

   | What to read | How to read it | Why |
   |---|---|---|
   | Phase Summaries for completed phases | Quick scan — get the gist | Compressed context for older work |
   | Checkpoint notes in the current phase | Read carefully | Recent decisions directly affect this task |
   | The specific task description | Read deeply | This is the actual job |
   | Referenced files from plan + checkpoints | Read and study patterns | Implementation guidance |

   This means: for Task 2.3, the subagent reads the Phase 1 Summary (3 lines), then Checkpoints 2.1 and 2.2 in detail, then focuses entirely on implementing Task 2.3. It doesn't need to deeply analyze every checkpoint from Phase 1.

   **WHY THIS WORKS FOR LONG PLANS**: The plan file grows with each checkpoint, but the tiered reading strategy keeps subagent orientation fast. Phase summaries compress earlier work. The orchestrator's context stays small (just todo updates and checkpoint edits). When automatic compaction compresses earlier messages, the plan file still has everything. The orchestrator re-reads it (single file read) and picks up from the last checkpoint.

   **PHASE SUMMARIES**: At phase boundaries (when all tasks in a phase are complete), write a Phase Summary:

   ```markdown
   ### Phase 1: Foundation [COMPLETED]
   > **Phase Summary (2026-02-08 15:45):**
   > Created 4 files: auth_service.dart, auth_controller.dart, auth_test.dart, auth_middleware.dart
   > All 24 tests pass. Branch: feat/user-auth (3 commits ahead of main).
   > Known issues: Email validation not yet wired to frontend.
   > Resume from: Phase 2, Task 1 (Frontend login form)
   ```

3. **Incremental Commits (Orchestrator Responsibility)**

   After completing each task (or group of related tasks), evaluate whether to commit. Commits happen in the main context, not in subagents.

   | Commit when... | Don't commit when... |
   |----------------|---------------------|
   | Logical unit complete (model, service, component) | Small part of a larger unit |
   | Tests pass + meaningful progress | Tests failing |
   | About to switch contexts (backend → frontend) | Purely scaffolding with no behavior |
   | About to attempt risky/uncertain changes | Would need a "WIP" commit message |

   **Heuristic:** "Can I write a commit message that describes a complete, valuable change? If yes, commit. If the message would be 'WIP' or 'partial X', wait."

   **Commit workflow:**
   ```bash
   # 1. Check what changed (trust the subagent's summary for file list)
   git status
   git diff --stat

   # 2. Stage files related to this logical unit (not `git add .`)
   git add <files from subagent summary>

   # 3. Commit with conventional message
   git commit -m "feat(scope): description of this unit"
   ```

   **Note:** Incremental commits use clean conventional messages without attribution footers. The final Phase 4 commit/PR includes the full attribution.

4. **Follow Existing Patterns**

   - Include pattern references in subagent prompts — the subagent will read and follow them
   - The plan should reference similar code and files
   - Don't reinvent — match what exists

5. **Figma Design Sync** (if applicable)

   For UI work with Figma designs, include Figma requirements in the subagent prompt so it can implement to spec. After the subagent completes, use figma-design-sync agent to compare the result.

6. **Track Progress**
   - Keep TodoWrite updated as each subagent completes
   - Note any blockers or unexpected discoveries from subagent responses
   - Create new tasks if scope expands
   - Keep user informed of major milestones

### Phase 3: Quality Check

1. **Run Core Quality Checks**

   Always run before submitting:

   ```bash
   # Run full test suite (use project's test command)
   # Examples: npm test, pytest, go test, flutter test, etc.

   # Run linting (per CLAUDE.md or project config)
   ```

2. **Consider Reviewer Agents** (Optional)

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

3. **Final Validation**
   - All TodoWrite tasks marked completed
   - All tests pass
   - Linting passes
   - Code follows existing patterns
   - Figma designs match (if applicable)
   - No console errors or warnings

### Phase 4: Ship It

1. **Create Commit**

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

2. **Capture and Upload Screenshots for UI Changes** (REQUIRED for any UI work)

   For **any** design changes, new views, or UI modifications, you MUST capture and upload screenshots:

   **Step 1: Start dev server** (if not running)
   ```bash
   bin/dev  # Run in background
   ```

   **Step 2: Capture screenshots with agent-browser CLI**
   ```bash
   agent-browser open http://localhost:3000/[route]
   agent-browser snapshot -i
   agent-browser screenshot output.png
   ```
   See the `agent-browser` skill for detailed usage.

   **What to capture:**
   - **New screens**: Screenshot of the new UI
   - **Modified screens**: Before AND after screenshots
   - **Design implementation**: Screenshot showing Figma design match

   **IMPORTANT**: Always include uploaded image URLs in PR description. This provides visual context for reviewers and documents the change.

3. **Create Pull Request**

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

4. **Notify User**
   - Summarize what was completed
   - Link to PR
   - Note any follow-up work needed
   - Suggest next steps if applicable

---

## Swarm Mode (Optional)

For complex plans with multiple independent workstreams, enable swarm mode for parallel execution with coordinated agents.

### When to Use Swarm Mode

| Use Swarm Mode when... | Use Standard Mode when... |
|------------------------|---------------------------|
| Plan has 5+ independent tasks | Plan is linear/sequential |
| Multiple specialists needed (review + test + implement) | Single-focus work |
| Want maximum parallelism | Simpler mental model preferred |
| Large feature with clear phases | Small feature or bug fix |

### Enabling Swarm Mode

To trigger swarm execution, say:

> "Make a Task list and launch an army of agent swarm subagents to build the plan"

Or explicitly request: "Use swarm mode for this work"

### Swarm Workflow

When swarm mode is enabled, the workflow changes:

1. **Create Team**
   ```
   Teammate({ operation: "spawnTeam", team_name: "work-{timestamp}" })
   ```

2. **Create Task List with Dependencies**
   - Parse plan into TaskCreate items
   - Set up blockedBy relationships for sequential dependencies
   - Independent tasks have no blockers (can run in parallel)

3. **Spawn Specialized Teammates**
   ```
   Task({
     team_name: "work-{timestamp}",
     name: "implementer",
     subagent_type: "general-purpose",
     prompt: "Claim implementation tasks, execute, mark complete",
     run_in_background: true
   })

   Task({
     team_name: "work-{timestamp}",
     name: "tester",
     subagent_type: "general-purpose",
     prompt: "Claim testing tasks, run tests, mark complete",
     run_in_background: true
   })
   ```

4. **Coordinate and Monitor**
   - Team lead monitors task completion
   - Spawn additional workers as phases unblock
   - Handle plan approval if required

5. **Cleanup**
   ```
   Teammate({ operation: "requestShutdown", target_agent_id: "implementer" })
   Teammate({ operation: "requestShutdown", target_agent_id: "tester" })
   Teammate({ operation: "cleanup" })
   ```

See the `orchestrating-swarms` skill for detailed swarm patterns and best practices.

---

## Key Principles

### Start Fast, Execute Faster

- Get clarification once at the start, then execute
- Don't wait for perfect understanding - ask questions and move
- The goal is to **finish the feature**, not create perfect process

### The Plan File is the Single Source of Truth

- The plan file carries ALL context: requirements, references, AND checkpoint notes from completed tasks
- Each subagent reads the full plan to understand the project arc before implementing
- Write thorough checkpoints — they're the handoff mechanism between subagents
- Don't reinvent — match patterns referenced in the plan and established by prior tasks

### Test As You Go

- Run tests after each change, not at the end
- Fix failures immediately
- Continuous testing prevents big surprises

### Quality is Built In

- Follow existing patterns
- Write tests for new code
- Run linting before pushing
- Use reviewer agents for complex/risky changes only

### Ship Complete Features

- Mark all tasks completed before moving on
- Don't leave features 80% done
- A finished feature that ships beats a perfect feature that doesn't

## Quality Checklist

Before creating PR, verify:

- [ ] All clarifying questions asked and answered
- [ ] All TodoWrite tasks marked completed
- [ ] Tests pass (run project's test command)
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] Figma designs match implementation (if applicable)
- [ ] Before/after screenshots captured and uploaded (for UI changes)
- [ ] Commit messages follow conventional format
- [ ] PR description includes summary, testing notes, and screenshots
- [ ] PR description includes attribution footer

## When to Use Reviewer Agents

**Don't use by default.** Use reviewer agents only when:

- Large refactor affecting many files (10+)
- Security-sensitive changes (authentication, permissions, data access)
- Performance-critical code paths
- Complex algorithms or business logic
- User explicitly requests thorough review

For most features: tests + linting + following patterns is sufficient.

## Common Pitfalls to Avoid

- **Analysis paralysis** - Don't overthink, read the plan and execute
- **Skipping clarifying questions** - Ask now, not after building wrong thing
- **Ignoring plan references** - The plan has links for a reason
- **Testing at the end** - Test continuously or suffer later
- **Forgetting TodoWrite** - Track progress or lose track of what's done
- **80% done syndrome** - Finish the feature, don't move on early
- **Over-reviewing simple changes** - Save reviewer agents for complex work
- **Reading files in the orchestrator** - Never read implementation files in the main context. Every file you read stays in the context window. Subagents read the plan + whatever files they need, then return a summary.
- **Skipping checkpoints** - Checkpoints are the handoff between subagents. Without them, the next subagent starts blind and makes inconsistent decisions. They're also your compaction insurance.
- **Skimpy checkpoints** - "Done" is not a checkpoint. Include files changed, decisions made, and context the next task needs. Same-phase subagents read these carefully.
- **Skimpy phase summaries** - Phase summaries compress an entire phase for later subagents. If the Phase 1 Summary doesn't mention the naming convention you chose, the Phase 2 subagents won't know about it.
- **Parallelizing subagents** - Sequential execution is intentional. Each subagent reads the plan with all prior checkpoints. Parallel agents would race on the same files and miss each other's decisions.
