#!/usr/bin/env bash
# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# One-shot setup (macOS / Linux). Run from the repo root:  bash install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Local Coding Agent - setup =="

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found. Install Node 18+ (e.g. 'brew install node' or your package manager), then re-run." >&2
  exit 1
fi
echo "node $(node -v)"

echo "Installing dependencies and preparing setup.json..."
LCA_CONFIG_PATH="$ROOT/setup.json" node "$ROOT/scripts/local-coding-agent.mjs" install

chmod +x "$ROOT/scripts/start-tunnel.sh" 2>/dev/null || true

cat <<'EOF'

Done. Next steps:
  1. Put your OpenAI tunnel client at: tools/tunnel-client   (chmod +x it)
  2. Edit setup.json in this project folder (workspace, keys, policies, tunnel settings).
  3. Start the server and tunnel:    bash scripts/lca start
  4. In ChatGPT: Settings -> Connectors -> Developer mode -> add the MCP connector.
  5. Verify in chat: "call workspace_info".

Dashboard (when running): http://127.0.0.1:8790/ui
EOF
