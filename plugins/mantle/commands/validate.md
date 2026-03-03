---
name: mantle:validate
description: Validate full-stack changes — ensure services are running, reload changed code, run checks, verify visually via Marionette.
argument-hint: "[description of what to test, link to plan file, etc]"
---

# Validate

Validates changes by exercising the running app directly in the iOS simulator and running automated quality checks.

## When to Use This Skill

Invoke this skill when:
- User runs `/validate` with no args — run the full automated suite
- User runs `/validate <experience description>` — manually test that flow in the simulator
- User asks to "test the login experience", "validate the garage screen", "check that valuation works", etc.
- After completing a feature to confirm it works end-to-end

**When an experience is described, your primary job is to drive the live simulator via Marionette MCP and confirm the flow works.** Automated checks are secondary.

> **Important:** Marionette MCP tools are only available in the main conversation context. Do NOT delegate simulator interaction to a subagent.

---

## Step 1 — Bring the System Up

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

## Step 2 — Understand the Code (when testing an experience)

Before touching the simulator, read the code for the described experience:
- Which screens and routes are involved
- What API calls are triggered
- What validation logic exists
- What state is managed

This tells you **what to test and what errors to watch for.**

Then write out a short test plan — the specific scenarios you'll exercise.

---

## Step 3 — Connect to the Simulator

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

## Step 4 — Execute the Test Plan

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

## Step 5 — Run Automated Checks

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

## Step 6 — Report Findings

Summarize:
- Each scenario tested and what happened (with screenshots)
- Anything broken, unexpected, or inconsistent
- Automated check results
- Any errors seen in `logs/session.log`
