#!/usr/bin/env python3
"""Reinstall Claude Code marketplaces and plugins from plugin-manifest.json.

Usage: install-plugins.sh [-d]
       -d  dry run, print commands without executing
"""
import json
import os
import re
import subprocess
import sys

DRY_RUN = "-d" in sys.argv[1:]
MANIFEST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "plugin-manifest.json")


def run(cmd):
    print(("would run: " if DRY_RUN else "+ ") + " ".join(cmd))
    if DRY_RUN:
        return True
    return subprocess.run(cmd).returncode == 0


def installed_ids():
    out = subprocess.run(
        ["claude", "plugin", "list", "--json"], capture_output=True, text=True
    )
    if out.returncode != 0:
        raise RuntimeError("claude plugin list --json failed")
    try:
        data = json.loads(out.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"claude plugin list returned invalid JSON: {error}") from error
    if isinstance(data, dict):
        data = data.get("plugins", data)
    if isinstance(data, dict):
        return set(data.keys())
    return {p.get("id") or p.get("name") for p in data if isinstance(p, dict)}


def main():
    with open(MANIFEST) as f:
        manifest = json.load(f)

    market_result = subprocess.run(
        ["claude", "plugin", "marketplace", "list"], capture_output=True, text=True
    )
    if market_result.returncode != 0:
        print("claude plugin marketplace list failed", file=sys.stderr)
        return 1
    existing_markets = set(
        re.findall(r"^\s*❯\s+(\S+)\s*$", market_result.stdout, re.MULTILINE)
    )
    try:
        have = installed_ids()
    except RuntimeError as error:
        print(error, file=sys.stderr)
        return 1

    failed_markets = []
    for market in manifest["marketplaces"]:
        if market["name"] in existing_markets:
            print(f"marketplace {market['name']}: already present")
            continue
        if not run(["claude", "plugin", "marketplace", "add", market["source"]]):
            failed_markets.append(market["name"])

    failed_plugins = []
    for plugin in manifest["plugins"]:
        if plugin in have:
            print(f"plugin {plugin}: already installed")
            continue
        if not run(["claude", "plugin", "install", plugin]):
            failed_plugins.append(plugin)

    if failed_markets:
        print("\nFAILED marketplaces: " + ", ".join(failed_markets), file=sys.stderr)
    if failed_plugins:
        print("FAILED plugins: " + ", ".join(failed_plugins), file=sys.stderr)
    return 1 if failed_markets or failed_plugins else 0


if __name__ == "__main__":
    sys.exit(main())
