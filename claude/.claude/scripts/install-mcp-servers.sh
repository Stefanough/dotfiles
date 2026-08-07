#!/usr/bin/env python3
"""Register user-scope MCP servers from mcp-servers.json.

Secrets are ${VAR} placeholders in the manifest. Values come from the
environment, falling back to ~/.config/dotfiles/secrets.env (gitignored,
KEY=value lines). A server whose placeholders are unresolved is skipped.

Usage: install-mcp-servers.sh [-d]
       -d  dry run, print what would be registered without executing
"""
import json
import os
import re
import subprocess
import sys

DRY_RUN = "-d" in sys.argv[1:]
MANIFEST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mcp-servers.json")
SECRETS = os.path.expanduser("~/.config/dotfiles/secrets.env")
PLACEHOLDER = re.compile(r"\$\{([A-Z0-9_]+)\}")


def load_secrets():
    values = dict(os.environ)
    if not os.path.exists(SECRETS):
        return values
    with open(SECRETS) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            values.setdefault(key.strip(), value.strip().strip("'\""))
    return values


def substitute(node, values, missing):
    if isinstance(node, dict):
        return {k: substitute(v, values, missing) for k, v in node.items()}
    if isinstance(node, list):
        return [substitute(v, values, missing) for v in node]
    if isinstance(node, str):
        def replace(match):
            name = match.group(1)
            if name not in values:
                missing.add(name)
                return match.group(0)
            return values[name]
        return PLACEHOLDER.sub(replace, node)
    return node


def main():
    with open(MANIFEST) as f:
        servers = json.load(f)["mcpServers"]

    values = load_secrets()
    existing = subprocess.run(
        ["claude", "mcp", "list"], capture_output=True, text=True
    ).stdout

    skipped = []
    for name, config in servers.items():
        if re.search(rf"^{re.escape(name)}\b", existing, re.MULTILINE):
            print(f"{name}: already registered")
            continue

        missing = set()
        resolved = substitute(config, values, missing)
        if missing:
            skipped.append((name, sorted(missing)))
            print(f"{name}: SKIPPED, unset {', '.join(sorted(missing))}")
            continue

        cmd = ["claude", "mcp", "add-json", name, json.dumps(resolved), "--scope", "user"]
        if DRY_RUN:
            print(f"would register {name} ({config.get('type', 'stdio')})")
            continue
        print(f"+ registering {name}")
        subprocess.run(cmd)

    if skipped:
        print(f"\nSet these in {SECRETS} (or export them) and re-run:", file=sys.stderr)
        for name, missing in skipped:
            print(f"  {name}: {', '.join(missing)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
