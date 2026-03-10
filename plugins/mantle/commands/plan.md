---
name: mantle:plan
model: opus
description: "Transform feature descriptions, issue URLs, or ticket IDs into phased implementation plans. Use when starting new features, planning complex changes, or scoping Linear/GitHub issues."
argument-hint: "[feature description, issue URL, or ticket ID]"
---

# Development Planning

**CRITICAL: This command produces a plan document ONLY. Do NOT write any implementation code, create any source files, or begin executing the plan. Your job ends when the plan file is written and the user has been presented with next-step options. Stop after Phase 6.**

Plan features systematically: gather requirements → understand the codebase → ask clarifying questions → design architecture → produce a self-contained plan. Use TodoWrite to track phases.

## Core Principles

- **Follow existing patterns**: Match what's already in the codebase. Only introduce new approaches when genuinely necessary.
- **Understand before planning**: Read existing code before designing anything.
- **Ask informed questions**: Explore first, then ask. Questions after understanding the code are better than questions asked blind.
- **Self-contained plans**: The plan file must contain everything an implementer needs to complete the work without asking questions.

---

## Phase 1: Requirements Gathering

Input: <feature_description> #$ARGUMENTS </feature_description>

**If empty**, ask the user what they'd like to plan.

**Detect input type:**

1. **Plain text** → Use directly as requirements
2. **Linear URL or ticket ID** (e.g., `HM-123`, URL with `/issue/` or `/project/`):
   - Fetch issue/project description via Linear MCP tools
   - Check sub-issues, comments, and attachments
   - If part of a project, fetch project description for broader context
3. **GitHub issue URL** → `gh issue view`
4. **Check for existing docs** in `docs/prds/`, `docs/brainstorms/` — use if found

Summarize understanding and confirm with user.

---

## Phase 2: Local Research

Launch ONE `repo-research-analyst` agent:

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

1. Read key files identified in the brief
2. Present summary: systems affected, existing patterns, relevant learnings
3. If "gaps found" AND topic is high-risk (security, payments, external APIs, data privacy), offer `/deepen-plan`

---

## Phase 3: Clarifying Questions

**Do not skip this phase.**

1. Cross-reference requirements against codebase findings
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, backward compatibility
3. Identify conflicts between requirements and existing architecture
4. Present all questions via AskUserQuestion
5. Wait for answers before proceeding

---

## Phase 4: Architecture Design

**Obvious approach** — existing pattern clearly applies:
- State it: "This follows the pattern in [file path]"
- Confirm with user and move on

**Unclear approach** — no precedent, multiple strategies, or significant tradeoffs:
1. Launch `code-architect` agent to propose approaches based on Phase 2 findings
2. Each approach should reference which existing pattern it follows
3. Present approaches with trade-offs and your recommendation
4. Ask user which they prefer

---

## Phase 5: Write Plan

**Requires user approval of architecture from Phase 4.**

Write the plan file following the structure in [plan-template.md](plan-template.md).

**Writing rules:** Write the plan file early, update at checkpoints (after phases, before questions, before long operations). Keep detail minimal — enough to execute without questions, but don't over-specify. At phase boundaries, compact completed sections to one-line outcomes. Every acceptance criterion must map to a test. Include full file paths for files to create, modify, and follow as patterns.

**Agent assignment:** Assign agents to tasks when beneficial — `agent:Explore` for code search, `agent:general-purpose` for multi-step implementation, `skill:brainstorming` for feature design. Not every task needs one.

**Learning log:** Log surprising codebase behavior, non-obvious conventions, gotchas, edge cases. Don't log routine progress. After implementation, promote learnings to `docs/solutions/` via `/mantle:compound`.

---

## Phase 6: Review and Finalize

1. **Requirements traceability**: Confirm every requirement maps to a task
2. Verify phase ordering and dependencies
3. Present executive summary:
   - Feature overview (one paragraph)
   - Systems involved
   - Phase breakdown
   - Key decisions and risk areas
   - Complexity: simple / moderate / complex
4. Ask user for final approval

**After approval**, use AskUserQuestion to present next steps, then **STOP — do not take any further action**:

**Question:** "Plan ready at `[plan_path]`. What next?"

**Options:**
1. **Open in editor** — `code [plan_path]`
2. **Start `/mantle:work`** — Begin implementing
3. **Run `/deepen-plan`** — Enhance with research agents
4. **Simplify** — Reduce detail level

**Your work is done after presenting these options. Wait for the user to explicitly invoke the next command. Do not proceed with implementation, do not run `/mantle:work`, do not write any code.**
