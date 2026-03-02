# Plan File Template

## File Location

- Linear issue with identifier (e.g., `HM-523`): `docs/plans/{ticket-id}-{plan-name}.md`
- Everything else: `docs/plans/{NNN}-{plan-name}.md` — auto-increment NNN from existing plans

## Structure

```markdown
# Plan: {Title}

| Created | {YYYY-MM-DD} |
| Last Updated | {YYYY-MM-DD} |
| Systems | {system1}, {system2}, ... |
| Source | {ticket URL, issue URL, or "N/A"} |

## Discovery Summary
Concise summary of codebase exploration findings: existing architecture, key files,
patterns, and constraints discovered during research.

## Implementation Overview
- Architecture decisions made and why
- Existing patterns being followed (with file references)
- New components and how they integrate
- Key interfaces and data flow
- Best practices to follow (reference docs/solutions/, CLAUDE.md rules, or external guides)

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
- {YYYY-MM-DD}: Surprising behavior, non-obvious conventions, gotchas, edge cases
```
