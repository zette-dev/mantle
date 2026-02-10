#!/bin/bash
# Run Flutter web in debug mode and capture the VM service URI for Marionette MCP
# Usage: ./scripts/run-debug-mcp.sh [additional flutter run args]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VM_SERVICE_FILE="$PROJECT_ROOT/.marionette_uri"

# Clean up URI file on exit
cleanup() {
    rm -f "$VM_SERVICE_FILE"
    echo ""
    echo "Cleaned up $VM_SERVICE_FILE"
}
trap cleanup EXIT

rm -f "$VM_SERVICE_FILE"

echo "Starting Flutter web debug session..."
echo "VM service URI will be written to: $VM_SERVICE_FILE"

flutter run "$@" 2>&1 | while IFS= read -r line; do
    echo "$line"

    if [[ "$line" =~ (ws://[0-9.]+:[0-9]+/[^[:space:]]+) ]]; then
        uri="${BASH_MATCH[1]}"
        echo "$uri" > "$VM_SERVICE_FILE"
        echo ""
        echo "================================================"
        echo "Marionette VM Service URI captured: $uri"
        echo "Written to: $VM_SERVICE_FILE"
        echo "================================================"
        echo ""
    elif [[ "$line" =~ (http://127\.0\.0\.1:[0-9]+/[^[:space:]]+) ]]; then
        http_uri="${BASH_MATCH[1]}"
        ws_uri="${http_uri/http:/ws:}"
        if [[ "$ws_uri" != *"/ws" && "$ws_uri" != *"/ws/" ]]; then
            ws_uri="${ws_uri%/}/ws"
        fi
        echo "$ws_uri" > "$VM_SERVICE_FILE"
        echo ""
        echo "================================================"
        echo "Marionette VM Service URI captured: $ws_uri"
        echo "Written to: $VM_SERVICE_FILE"
        echo "================================================"
        echo ""
    fi
done
