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
    failed = []
    for name, config in servers.items():
        registered = re.search(rf"^{re.escape(name)}\b", existing, re.MULTILINE)

        missing = set()
        resolved = substitute(config, values, missing)
        if missing:
            skipped.append((name, sorted(missing)))
            print(f"{name}: SKIPPED, unset {', '.join(sorted(missing))}")
            continue

        cmd = ["claude", "mcp", "add-json", name, json.dumps(resolved), "--scope", "user"]
        if DRY_RUN:
            action = "refresh" if registered else "register"
            print(f"would {action} {name} ({config.get('type', 'stdio')})")
            continue

        if registered:
            print(f"+ refreshing {name}")
            result = subprocess.run(["claude", "mcp", "remove", name, "--scope", "user"])
            if result.returncode:
                failed.append((name, "remove existing registration"))
                continue
        else:
            print(f"+ registering {name}")

        result = subprocess.run(cmd)
        if result.returncode:
            failed.append((name, "add registration"))

    if skipped:
        print(f"\nSet these in {SECRETS} (or export them) and re-run:", file=sys.stderr)
        for name, missing in skipped:
            print(f"  {name}: {', '.join(missing)}", file=sys.stderr)
    if failed:
        print("\nMCP registration failed:", file=sys.stderr)
        for name, action in failed:
            print(f"  {name}: could not {action}", file=sys.stderr)
    return 1 if skipped or failed else 0


if __name__ == "__main__":
    sys.exit(main())
