# Simulator Testing with Marionette MCP

## Overview

Use the **Marionette Flutter MCP server** (`marionette_mcp`) to test features in the running app. Marionette connects to the Flutter VM service and provides MCP tools to interact with the simulator: tap buttons, enter text, scroll, take screenshots, and read logs.

## Prerequisites

The Flutter app must include the Marionette binding (debug mode only):
```dart
if (kDebugMode) {
  MarionetteBinding.ensureInitialized();
}
```

## Starting the App

1. Check the project's **Makefile** for the command to run the app (e.g., `make run-debug-mcp`, `make run-dev`)
2. The Makefile target typically wraps [run-debug-mcp.sh](../scripts/run-debug-mcp.sh), which:
   - Starts `flutter run` in debug mode
   - Captures the VM service WebSocket URI from Flutter's output
   - Writes it to `.marionette_uri` at the project root
3. Never start the app directly — ask the user to run the Makefile command

## Connecting

1. Check if `.marionette_uri` file exists (`cat .marionette_uri`)
2. If file exists, use `connect` with the URI to attach to the running app
   - If connection fails: ask user to restart the app
3. If file doesn't exist: ask user to start the app via Makefile

## MCP Tools Reference

| Tool | Description |
|------|-------------|
| `connect` | Connect to a Flutter app via its VM service URI (e.g., `ws://127.0.0.1:54321/ws`) |
| `disconnect` | Disconnect from the currently connected app |
| `hot_reload` | Hot reload the app, applying code changes without losing state |
| `take_screenshots` | Capture screenshots of all active views (returned as base64 images) |
| `get_interactive_elements` | List all interactive UI elements visible on screen (buttons, inputs, etc.) |
| `tap` | Tap an element by key or visible text |
| `enter_text` | Enter text into a text field by key |
| `scroll_to` | Scroll until an element matching a key or text becomes visible |
| `get_logs` | Retrieve application logs collected since the last check |

## Workflow After Code Changes

1. Make code changes
2. `hot_reload` to apply changes without losing state
3. `get_interactive_elements` to see what's on screen
4. `tap` / `enter_text` / `scroll_to` to navigate to the affected area
5. `take_screenshots` to visually verify the result
6. `get_logs` to check for errors or unexpected behavior
