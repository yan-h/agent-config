#!/usr/bin/env python3
"""install.sh's settings step, run alone on temporary files: what it does to
autoMode in settings.json with this checkout's global/claude/auto-mode.json."""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLOCK = re.search(r"<<'EOF'\n(.*?)\nEOF\n", (ROOT / "scripts/install.sh").read_text(), re.S).group(1)
TAG = "[agent-config] "


def step(settings, repo=ROOT, cloud="false"):
    return subprocess.run([sys.executable, "-c", BLOCK, str(settings), cloud, str(repo)],
                          capture_output=True, text=True)


with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    rules = json.loads((ROOT / "global/claude/auto-mode.json").read_text())

    fresh = tmp / "fresh.json"
    assert step(fresh).returncode == 0
    auto = json.loads(fresh.read_text())["autoMode"]
    # A list without "$defaults" replaces the built-in rules of that section.
    assert all(entries[0] == "$defaults" for entries in auto.values()), auto
    assert auto == {key: ["$defaults"] + [TAG + e for e in entries] for key, entries in rules.items()}
    first = fresh.read_text()
    assert step(fresh).returncode == 0 and fresh.read_text() == first, "a rerun changed settings.json"

    owned = tmp / "owned.json"
    owned.write_text(json.dumps({"permissions": {"allow": ["Bash(ls:*)"]}, "autoMode": {
        "allow": ["$defaults", "mine", TAG + "dropped from the checkout"],
        "soft_deny": ["mine alone", TAG + "dropped too"]}}))
    assert step(owned).returncode == 0
    got = json.loads(owned.read_text())
    assert got["permissions"] == {"allow": ["Bash(ls:*)"]}
    assert got["autoMode"]["allow"] == ["$defaults", "mine"] + [TAG + e for e in rules["allow"]]
    assert got["autoMode"]["soft_deny"] == ["mine alone"], "the owner's list gained defaults or kept a stale entry"

    bad = tmp / "repo/global/claude"
    bad.mkdir(parents=True)
    (bad / "auto-mode.json").write_text('{"alow": ["x"]}')
    refused = tmp / "refused.json"
    assert step(refused, repo=tmp / "repo").returncode != 0 and not refused.exists()
print("install.sh's settings step: ok")
