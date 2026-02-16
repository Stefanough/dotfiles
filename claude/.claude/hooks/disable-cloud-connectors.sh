#!/bin/bash
# Auto-disable claude.ai MCP connectors synced from claude.ai account.
# Runs as a SessionStart hook to patch ~/.claude.json per-project.
# Uses disabledMcpServers (project state) instead of feature flags (gets overwritten).
# See: https://github.com/anthropics/claude-code/issues/20412#issuecomment-3862058782

set -euo pipefail

CLAUDE_JSON="$HOME/.claude.json"

# All cloud-synced connectors from claude.ai account
CONNECTORS='[
  "claude.ai Atlassian",
  "claude.ai Atlassian (2)",
  "claude.ai Canva",
  "claude.ai Cloudflare Developer Platform",
  "claude.ai Figma",
  "claude.ai Fireflies",
  "claude.ai Gamma",
  "claude.ai Linear",
  "claude.ai Notion",
  "claude.ai Ramp",
  "claude.ai Sentry",
  "claude.ai Slack",
  "claude.ai Stripe",
  "claude.ai Vercel"
]'

# Read hook input to get current working directory
CWD=$(jq -r '.cwd' < /dev/stdin)

if [ -z "$CWD" ] || [ "$CWD" = "null" ]; then
  exit 0
fi

if [ ! -f "$CLAUDE_JSON" ]; then
  exit 0
fi

# Add connectors to the project's disabledMcpServers array (deduplicated).
# Creates the project entry and array if they don't exist.
jq --arg cwd "$CWD" --argjson connectors "$CONNECTORS" '
  .projects[$cwd].disabledMcpServers = (
    (.projects[$cwd].disabledMcpServers // []) + $connectors | unique
  )
' "$CLAUDE_JSON" > "${CLAUDE_JSON}.tmp" && mv "${CLAUDE_JSON}.tmp" "$CLAUDE_JSON"
