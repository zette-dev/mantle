---
name: mantle:validate
description: "Validate changes by detecting what needs testing from code diffs, running a plan's test checklist, or exercising a specific experience in the iOS simulator."
argument-hint: "[plan file path, experience description, or leave empty to auto-detect]"
---

# Validate

<input> #$ARGUMENTS </input>

Determine which path to take based on the input:

- **Empty** → Path A: auto-detect changes and generate a test list
- **Plan file path** (`.md` file in `docs/plans/`) → Path B: run the test plan in that document
- **Experience description** (any other text) → Path C: drive the live simulator via Marionette

---

## Path A: Auto-Detect Changes

### Step 1: Gather Changes

Run these in parallel:

```bash
git diff --name-only HEAD           # uncommitted changes
git diff --name-only main...HEAD    # changes since branching from main (or master)
git status --short                  # untracked/staged files
```

If on main with no branch diff, use only uncommitted changes. Compile a deduplicated list of all changed files.

### Step 2: Understand What Changed

Launch one `repo-research-analyst` agent:

```
Task repo-research-analyst: "Analyze these changed files and summarize what behavior was added or modified:

Changed files:
[list from Step 1]

For each file:
1. What does this code do?
2. What user-facing or system behavior does it affect?
3. What are the key code paths introduced or changed?
4. What could break if this is wrong?

Return a concise summary grouped by feature/area, not by file."
```

### Step 3: Generate Test List

From the agent's summary, produce a concrete test list. Each item should be:
- A specific action a person or automated test can perform
- Linked to the behavior it validates
- Labeled as: **manual**, **automated**, or **either**

Group by feature area:

```
### [Feature Area]
- [ ] [manual] Describe the exact action and expected result
- [ ] [automated] Describe what the test should assert
```

### Step 4: Confirm with User

Use AskUserQuestion with multiSelect to let the user pick which items to validate. Include an "All of the above" option.

Wait for the user's selection before proceeding.

### Step 5: Execute

For each confirmed test item:
- **Automated** — Run it. Report pass/fail with output.
- **Manual (simulator)** — Continue to Step 1 of Path C below using the test item as the experience description.
- **Manual (non-simulator)** — Describe exactly what to do. Wait for user confirmation before moving on.

Track results:
```
✅ [test description] — passed
❌ [test description] — FAILED: [what happened]
⏭️ [test description] — skipped
```

### Step 6: Report

```markdown
## Validation Report

**Branch:** [branch name]
**Changed files:** [count]
**Tests run:** [count]

### Results
- ✅ Passed: [count]
- ❌ Failed: [count]
- ⏭️ Skipped: [count]

### Failures
[For each failure: what was tested, what happened, suggested fix]
```

---

## Path B: Plan Document

### Step 1: Read the Plan

Read the full plan file. Extract all `#### Testing` sections and `- [ ]` test items. If no testing sections are found, switch to Path A using the plan's branch context.

### Step 2: Confirm Scope

Present the extracted test list grouped by phase. Use AskUserQuestion with multiSelect:
- All tests
- Only unchecked (incomplete) tests
- Specific phases — list each as an option

### Step 3: Execute Tests

For each selected test:
- **Automated** — Run it. Report pass/fail.
- **Manual (simulator)** — Proceed through Path C steps using the test description.
- **Manual (other)** — Describe what to do. Wait for user confirmation.

As each test completes, update the plan file immediately:
- `- [ ]` → `- [x]` for passing tests
- Leave `- [ ]` for failures, add inline note: `— ❌ failed: [reason]`

### Step 4: Update Plan

Append to the plan's Progress Log:
```markdown
- {today}: Validation run — [N] passed, [M] failed. [Brief summary or "All tests passing."]
```

### Step 5: Report

```markdown
## Validation Report

**Plan:** [plan file path]
**Tests run:** [count]

### Results
- ✅ Passed: [count]
- ❌ Failed: [count]
- ⏭️ Skipped: [count]

### Plan Updated
Checked off [N] tests in [plan file path]. [M] tests still open.
```

---

## Path C: Experience Description

Validates a specific user experience by driving the live iOS simulator via Marionette and running automated checks.

**When an experience is described, your primary job is to drive the live simulator via Marionette MCP and confirm the flow works.** Automated checks are secondary.

> **Important:** Marionette MCP tools are only available in the main conversation context. Do NOT delegate simulator interaction to a subagent.

### Step 1 — Bring the System Up

```bash
wire status --json    # check current state
wire up               # if services are not running — starts DB → API → Flutter in order
```

After running `wire up`, **poll until all services are healthy** before proceeding. Do not skip ahead — connecting to a service that hasn't started will fail silently or error.

```bash
# Poll until healthy (check every 5s, up to 5 minutes)
for i in $(seq 1 60); do
  STATUS=$(wire status --json)
  ALL_HEALTHY=$(echo "$STATUS" | python3 -c "import sys,json; s=json.load(sys.stdin); print(all(svc['healthy'] for svc in s['services']))" 2>/dev/null)
  if [ "$ALL_HEALTHY" = "True" ]; then echo "All services healthy"; break; fi
  echo "Waiting for services... ($i/60)"; sleep 5
done
```

If services still aren't healthy after the timeout, check `logs/session.log` and `logs/mobile.log` for errors.

All logs stream to `logs/session.log`. Monitor during testing:

```bash
tail -f logs/session.log
```

Log tags: `[DB]`, `[API]`, `[MOBILE]`

---

### Step 2 — Understand the Code

Before touching the simulator, read the code for the described experience:
- Which screens and routes are involved
- What API calls are triggered
- What validation logic exists
- What state is managed

This tells you **what to test and what errors to watch for.**

Then write out a short test plan — the specific scenarios you'll exercise.

---

### Step 3 — Connect to the Simulator

First confirm the mobile service is healthy:

```bash
wire status --json | python3 -c "import sys,json; s=json.load(sys.stdin); m=[x for x in s['services'] if x['name']=='mobile'][0]; print('healthy' if m['healthy'] else 'NOT healthy')"
```

If not healthy, do NOT proceed — go back to Step 1.

Read the Flutter VM URI from `.wire-state`:

```bash
grep MOBILE_FLUTTER_URI .wire-state
# e.g. MOBILE_FLUTTER_URI=ws://127.0.0.1:55346/abc=/ws
```

Then connect using the Marionette MCP:

```
mcp__marionette__connect(uri: "<value of MOBILE_FLUTTER_URI>")
```

If `.wire-state` has no `MOBILE_FLUTTER_URI`, the mobile app isn't running — run `wire up` first (or ask the user to run `make mobile-debug`).

---

### Step 4 — Execute the Test Plan

### Discover the current screen
```
mcp__marionette__take_screenshots()
mcp__marionette__get_interactive_elements()
```

### Navigate and interact
```
mcp__marionette__tap(text: "Sign In")             # by visible text
mcp__marionette__tap(key: "login_submit")         # by semantic key (preferred)
mcp__marionette__enter_text(key: "login_email", text: "user@example.com")
mcp__marionette__scroll_to(text: "Forgot password?")
```

### Verify after every action
```
mcp__marionette__take_screenshots()               # visual confirmation
mcp__marionette__get_interactive_elements()       # check for errors, state changes
```

**Take a screenshot at every significant step.** Never assume an action worked without verifying.

After any interaction that triggers an API call, check `logs/session.log` for `[API]` errors.

---

### Step 5 — Run Automated Checks

Run checks scoped to what changed:

| Changed area | Commands |
|-------------|----------|
| API only | `make api-lint && make api-typecheck && make api-test` |
| Mobile only | `make mobile-lint && make mobile-test` |
| Full stack | All of the above |

### Known pre-existing failures (do not flag as regressions)
- `make api-typecheck` — 231 errors on `main`, pre-existing
- `make mobile-test` — 2 failures in `service_records_state_test.dart` (PostHog binding), pre-existing

---

### Step 6 — Report Findings

Summarize:
- Each scenario tested and what happened (with screenshots)
- Anything broken, unexpected, or inconsistent
- Automated check results
- Any errors seen in `logs/session.log`
