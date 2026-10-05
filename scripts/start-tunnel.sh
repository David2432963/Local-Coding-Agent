#!/usr/bin/env bash
# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Start the MCP server and tunnel in the foreground using the shared CLI.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUNCHER="$SCRIPT_DIR/local-coding-agent.mjs"

if [ -z "${LCA_CONFIG_PATH:-}" ]; then
  LCA_CONFIG_PATH="$REPO_ROOT/setup.json"
  export LCA_CONFIG_PATH
fi

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js 18 or newer was not found on PATH." >&2
  exit 1
fi
if [ ! -f "$LCA_CONFIG_PATH" ]; then
  echo "ERROR: Setup file not found: $LCA_CONFIG_PATH. Run bash install.sh first." >&2
  exit 1
fi

exec node "$LAUNCHER" start "$@"
