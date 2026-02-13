---
name: mantle:plan
description: Transform feature descriptions into well-structured implementation plans with codebase understanding and architecture focus
argument-hint: "[feature description, issue URL, or ticket ID]"
---

# Development Planning

**Note: The current year is 2026.** Use this when dating plans and searching for recent documentation.

You are helping a developer plan the implementation of a feature. Follow a systematic approach: gather requirements, understand the codebase, ask clarifying questions, design architecture, and produce a self-contained implementation plan. No implementation happens here — only research and planning.

## Core Principles

- **Follow existing patterns**: Do not introduce new architectural approaches, libraries, or abstractions unless the feature genuinely requires something that doesn't exist in the codebase. When in doubt, match what's already there.
- **Understand before planning**: Read and comprehend existing code patterns before designing anything.
- **Ask informed questions**: Explore the codebase first, then ask clarifying questions. Questions asked after understanding the code are better than questions asked blind.
- **Self-contained plans**: The plan file must contain everything needed to execute — an implementer reading only this file should be able to complete the work without asking questions.
- **Use TodoWrite**: Track all phases throughout execution.

---

## Phase 1: Requirements Gathering

**Goal**: Deeply understand what needs to be built

Input: <feature_description> #$ARGUMENTS </feature_description>

**If the input is empty**, ask the user: "What would you like to plan? Describe the feature, bug fix, or improvement — or provide a Linear/GitHub issue URL."

**Detect input type and gather requirements:**

1. **Plain text description** → Use it directly as requirements
2. **Linear URL or ticket ID** (e.g., `HM-123`, URL with `/issue/` or `/project/`):
   - Use Linear MCP tools to fetch the issue/project description
   - Check for sub-issues, comments, and attachments for additional context
   - If issue belongs to a project, fetch project description for broader context
3. **GitHub issue URL** → Use `gh issue view` to fetch details
4. **Check for existing PRD or brainstorm**:
   - Look for relevant docs in `docs/prds/`, `docs/brainstorms/`
   - If found, announce and use as requirements source

**Extract and organize:**
- Core requirements (must-have)
- Secondary requirements (nice-to-have)
- Acceptance criteria
- Constraints and non-functional requirements

**Summarize understanding and confirm with user.**

---

## Phase 2: Local Research

**Goal**: Understand relevant existing code, patterns, learnings, and conventions

Launch ONE `repo-research-analyst` agent with a focused prompt:

```
Task repo-research-analyst: "Local context research for planning: [feature description]

Search for:
1. docs/solutions/ — scan frontmatter tags for relevant learnings and gotchas
2. Codebase — existing patterns for similar features (trace through abstractions)
3. CLAUDE.md — applicable conventions and project rules
4. docs/plans/ — similar past plans

Return:
- A compact research brief (key patterns, conventions, learnings found)
- List of 5-10 key files to read (full paths)
- Sufficiency assessment: 'enough local context' OR 'gaps found in [specific areas]'"
```

**After the agent returns:**

1. **Read key files** identified in the brief to build deep understanding in the main context
2. **Present summary**: systems affected, existing patterns to follow/extend, relevant learnings
3. **Check sufficiency**: If the brief says "gaps found" AND the topic is high-risk (security, payments, external APIs, data privacy), offer to run `/deepen-plan` for external research before continuing

---

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing

**CRITICAL**: This is one of the most important phases. DO NOT SKIP.

**Actions**:
1. Cross-reference requirements against codebase findings
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance needs
3. Identify any conflicts between requirements and existing architecture
4. **Present all questions to the user using AskUserQuestion tool**
5. **Wait for answers before proceeding to architecture design**

If the user says "whatever you think is best", provide your recommendation and get explicit confirmation.

---

## Phase 4: Architecture Design

**Goal**: Design the implementation approach using existing codebase patterns

**If the approach is obvious** — an existing pattern clearly covers this feature (e.g., adding a new API endpoint that follows the same structure as existing ones):
1. State the approach: "This follows the same pattern as [existing feature] in [file path]"
2. Briefly confirm with user and move on. Don't manufacture alternatives for the sake of options.

**If the approach is unclear** — no clear precedent, multiple valid strategies, or significant tradeoffs:
1. Launch a `code-architect` agent to propose approaches based on patterns discovered in Phase 2
2. Each approach should explicitly reference which existing feature/pattern is being followed
3. Present to user: summary of each approach, trade-offs, **your recommendation with reasoning**
4. **Ask user which approach they prefer**

---

## Phase 5: Write Implementation Plan

**Goal**: Produce a self-contained phased plan that can be executed in a separate session with no additional context needed

**DO NOT START WITHOUT USER APPROVAL OF ARCHITECTURE**

### Plan File Location

Determine the plan file path:
- If from a Linear issue with identifier (e.g., `HM-523`): `docs/plans/{ticket-id}-{plan-name}.md`
- For everything else: `docs/plans/{NNN}-{plan-name}.md` — auto-increment NNN from existing plans

### Plan File Structure

Write the plan using this structure:

```markdown
# Plan: {Title}

| Created | {YYYY-MM-DD} |
| Last Updated | {YYYY-MM-DD} |
| Systems | {system1}, {system2}, ... |
| Source | {ticket URL, issue URL, or "N/A"} |

## Discovery Summary
Concise summary of codebase exploration findings: existing architecture, key files,
patterns, and constraints discovered during research. Serves as a persistent record
so future sessions don't need to re-explore.

## Implementation Overview
- Architecture decisions made and why
- Which existing patterns/features are being followed (with file references)
- New components being introduced and how they integrate
- Key interfaces and data flow
- Best practices to follow (reference docs/solutions/ files, CLAUDE.md rules,
  or external guides discovered during research — e.g., "See docs/solutions/api-patterns/pagination.md")

## Tasks
Break into phases where each phase is independently testable.

### Phase 1: {Foundation}
- [ ] Task description → `file/to/create.ts` (pattern: `file/to/follow.ts`)
- [ ] Task description → `file/to/modify.ts`

#### Testing (unit)
- [ ] Test scenario 1
- [ ] Test scenario 2

### Phase 2: {Core Implementation}
- [ ] Task description → `agent:general-purpose`
- [ ] Task description (no agent needed for simple tasks)

#### Testing (integration)
- [ ] Test scenario 1

## Progress Log
- {YYYY-MM-DD}: What was done, what's next

## Learning Log
- {YYYY-MM-DD}: What was learned and is worth documenting
```

### Plan Writing Rules

| Rule | Why |
|------|-----|
| Write early, update at checkpoints | Create the plan file as soon as there's content. Update after completing a phase, before asking the user a question, before launching long operations. |
| Minimal detail | Only what's needed to execute. An implementer should be able to complete tasks without asking questions, but don't over-specify. |
| Compact at milestones | At phase boundaries, reduce completed sections to one-line outcomes. Only compact what's stale. |
| Every acceptance criterion maps to a test | No requirement should be untested. |
| Include file paths | Full paths for files to create, modify, and follow as patterns. |

### Task Agent Assignment

Assign agents/skills to tasks when beneficial. Not every task needs one.

| Task Type | Agent/Skill |
|-----------|-------------|
| Explore code, find files | `agent:Explore` |
| Multi-step implementation | `agent:general-purpose` |
| Feature design | `skill:brainstorming` |

### Learning Log Guidance

The Learning Log in the plan captures quick notes during planning. After implementation, use `/mantle:compound` to promote important learnings into `docs/solutions/` as permanent, searchable documentation that future `/mantle:plan` runs will discover.

**During planning, note:** Surprising codebase behavior, non-obvious conventions, gotchas, undocumented edge cases, decisions future sessions should know about.

**Don't log:** Routine progress (that's for Progress Log) or restating what the code already says.

---

## Phase 6: Plan Review

**Goal**: Validate the plan satisfies all requirements and is complete

**Actions**:
1. **Requirements traceability**: Walk through every requirement and confirm it maps to a task
2. Flag any requirements not covered and resolve with user
3. Verify phase ordering and dependencies are correct
4. Present executive summary:
   - Feature overview (one paragraph)
   - Systems involved and how they're affected
   - Number of phases and high-level breakdown
   - Key architectural decisions
   - Risk areas or assumptions
   - Estimated complexity (simple / moderate / complex)
5. **Ask user for final approval of the plan**

---

## Post-Generation Options

After writing the plan file, use the **AskUserQuestion tool** to present these options:

**Question:** "Plan ready at `[plan_path]`. What would you like to do next?"

**Options:**
1. **Open in editor** - Open the plan file in VS Code/Cursor
2. **Start `/mantle:work`** - Begin implementing this plan
3. **Run `/deepen-plan`** - Enhance with parallel research agents for best practices and edge cases
4. **Simplify** - Reduce detail level

Based on selection:
- **Open in editor** → Run `code [plan_path]` (not `open` — that defaults to Xcode on macOS)
- **`/mantle:work`** → Call the /mantle:work command with the plan file path
- **`/deepen-plan`** → Call the /deepen-plan command with the plan file path
- **Simplify** → Ask what to simplify, regenerate
- **Other** (automatically provided) → Accept free text for changes

NEVER CODE! Just research and write the plan.
