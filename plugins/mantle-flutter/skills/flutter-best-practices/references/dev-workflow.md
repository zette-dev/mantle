# Simulator Testing with Marionette MCP

## Overview

Use the **Marionette Flutter MCP server** (`marionette_mcp`) to test features in the running app. Marionette connects to the Flutter VM service and provides MCP tools to interact with the simulator: tap buttons, enter text, scroll, take screenshots, and read logs.

## Starting the App

1. run `wire up` to run the entire system
2. Check if `.wire-state` file exists (`cat .wire-state`)
3. If file exists, use `connect` with the URI to attach to the running app

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

## Workflow After Code Changes

1. Make code changes
2. `hot_reload` to apply changes without losing state
3. `get_interactive_elements` to see what's on screen
4. `tap` / `enter_text` / `scroll_to` to navigate to the affected area
5. `take_screenshots` to visually verify the result
6. `get_logs` to check for errors or unexpected behavior
