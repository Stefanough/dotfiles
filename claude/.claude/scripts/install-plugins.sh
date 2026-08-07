#!/usr/bin/env python3
"""Reinstall Claude Code marketplaces and plugins from plugin-manifest.json.

Usage: install-plugins.sh [-d]
       -d  dry run, print commands without executing
"""
import json
import os
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
        return set()
    try:
        data = json.loads(out.stdout)
    except json.JSONDecodeError:
        return set()
    if isinstance(data, dict):
        data = data.get("plugins", data)
    if isinstance(data, dict):
        return set(data.keys())
    return {p.get("id") or p.get("name") for p in data if isinstance(p, dict)}


def main():
    with open(MANIFEST) as f:
        manifest = json.load(f)

    existing_markets = subprocess.run(
        ["claude", "plugin", "marketplace", "list"], capture_output=True, text=True
    ).stdout

    for market in manifest["marketplaces"]:
        if market["name"] in existing_markets:
            print(f"marketplace {market['name']}: already present")
            continue
        run(["claude", "plugin", "marketplace", "add", market["source"]])

    have = installed_ids()
    failed = []
    for plugin in manifest["plugins"]:
        if plugin in have:
            print(f"plugin {plugin}: already installed")
            continue
        if not run(["claude", "plugin", "install", plugin]):
            failed.append(plugin)

    if failed:
        print(f"\nFAILED ({len(failed)}): " + ", ".join(failed), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
