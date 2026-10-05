#!/usr/bin/env python3
"""Validate the portable core of every skill in this repository, then run
each skill's own tests (skills/*/scripts/test_*.py and test_*.sh)."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
VALID_NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def frontmatter_value(lines: list[str], key: str) -> str | None:
    prefix = f"{key}:"
    for line in lines:
        if not line.startswith(prefix):
            continue
        value = line[len(prefix) :].strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1].strip()
        return value or None
    return None


def validate_skill(directory: Path) -> tuple[str | None, list[str]]:
    problems: list[str] = []
    skill_file = directory / "SKILL.md"
    if not skill_file.is_file():
        return None, [f"{directory.relative_to(ROOT)}: missing SKILL.md"]

    try:
        text = skill_file.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return None, [f"{skill_file.relative_to(ROOT)}: must be UTF-8 text"]

    lines = text.splitlines()
    if not lines or lines[0] != "---":
        return None, [f"{skill_file.relative_to(ROOT)}: must start with YAML frontmatter"]

    try:
        closing = lines.index("---", 1)
    except ValueError:
        return None, [f"{skill_file.relative_to(ROOT)}: frontmatter is not closed"]

    frontmatter = lines[1:closing]
    name = frontmatter_value(frontmatter, "name")
    description = frontmatter_value(frontmatter, "description")

    if name is None:
        problems.append(f"{skill_file.relative_to(ROOT)}: missing non-empty name")
    else:
        if len(name) > 63 or not VALID_NAME.fullmatch(name):
            problems.append(
                f"{skill_file.relative_to(ROOT)}: name must be at most 63 characters "
                "of lowercase letters, digits, and single hyphens"
            )
        if name != directory.name:
            problems.append(
                f"{skill_file.relative_to(ROOT)}: name {name!r} does not match "
                f"folder {directory.name!r}"
            )

    if description is None:
        problems.append(f"{skill_file.relative_to(ROOT)}: missing inline description")

    if not any(line.strip() for line in lines[closing + 1 :]):
        problems.append(f"{skill_file.relative_to(ROOT)}: instructions are empty")

    return name, problems


def main() -> int:
    if not SKILLS.is_dir():
        print("skills/: directory is missing", file=sys.stderr)
        return 1

    problems: list[str] = []
    names: dict[str, Path] = {}
    skill_directories = [
        entry
        for entry in sorted(SKILLS.iterdir())
        if not entry.name.startswith(".")
    ]

    for entry in skill_directories:
        if not entry.is_dir():
            problems.append(f"{entry.relative_to(ROOT)}: expected a skill directory")
            continue

        name, skill_problems = validate_skill(entry)
        problems.extend(skill_problems)
        if name is not None:
            previous = names.get(name)
            if previous is not None:
                problems.append(
                    f"{entry.relative_to(ROOT)}: duplicate skill name {name!r}; "
                    f"first used by {previous.relative_to(ROOT)}"
                )
            else:
                names[name] = entry

    if problems:
        for problem in problems:
            print(f"error: {problem}", file=sys.stderr)
        return 1

    count = len(skill_directories)
    noun = "skill" if count == 1 else "skills"
    print(f"Validated {count} {noun}.")
    return run_skill_tests()


def run_skill_tests() -> int:
    """Run each skill's own tests, so a skill script is gated where it lives."""
    runners = {".py": [sys.executable], ".sh": ["bash"]}
    tests = [
        test
        for test in sorted(SKILLS.glob("*/scripts/test_*"))
        if test.suffix in runners
    ]
    failed = 0
    for test in tests:
        result = subprocess.run(
            [*runners[test.suffix], str(test)],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        if result.returncode:
            failed += 1
            print(f"error: {test.relative_to(ROOT)} failed", file=sys.stderr)
            print(result.stdout + result.stderr, file=sys.stderr)
    if failed:
        return 1
    print(f"Passed {len(tests)} skill test file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
