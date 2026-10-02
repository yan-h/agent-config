#!/usr/bin/env python3
"""Map where change lands on a branch: hotspots, change coupling, fix clusters
and the widest changes, with renames followed to each file's current path.

Run from inside the repository:

    history-map.py origin/main --since "1 year ago" [--path crates/foo/ ...] [--exclude REGEX ...]

Each change landing on the branch counts once: merges are read as their whole
first-parent diff, so a merged branch and a squashed PR count the same.
"""

from __future__ import annotations

import argparse
import collections
import itertools
import os
import re
import subprocess
import sys

FIX = re.compile(r"\b(fix|fixes|fixed|bug|bugs)\b", re.IGNORECASE)


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"git {' '.join(args)}: {result.stderr.strip()}")
    return result.stdout


def changes(ref: str, since: str) -> tuple[list[tuple[str, str, list[str]]], dict[str, str]]:
    """Commits newest first as (hash, subject, paths), and old path -> new path."""
    log = git(
        "log", ref, f"--since={since}", "--first-parent", "--diff-merges=first-parent",
        "-M", "--name-status", "--format=@@%H %s",
    )
    commits: list[tuple[str, str, list[str]]] = []
    renamed: dict[str, str] = {}
    for line in log.splitlines():
        if line.startswith("@@"):
            sha, _, subject = line[2:].partition(" ")
            commits.append((sha, subject, []))
        elif line.strip() and commits:
            fields = line.split("\t")
            if fields[0].startswith("R") and len(fields) == 3:
                renamed.setdefault(fields[1], fields[2])
            commits[-1][2].append(fields[-1])
    return commits, renamed


def current(path: str, renamed: dict[str, str]) -> str:
    seen = set()
    while path in renamed and path not in seen:
        seen.add(path)
        path = renamed[path]
    return path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("ref", help="the primary branch, fetched, e.g. origin/main")
    parser.add_argument("--since", default="1 year ago")
    parser.add_argument("--path", action="append", default=[], help="limit to paths under this prefix (repeatable)")
    parser.add_argument("--exclude", action="append", default=[], help="drop paths matching this regex (repeatable)")
    parser.add_argument("--top", type=int, default=25)
    parser.add_argument("--max-files", type=int, default=12,
                        help="commits touching more files than this are left out of coupling")
    args = parser.parse_args()

    live = set(git("ls-tree", "-r", "--name-only", args.ref).splitlines())
    excluded = [re.compile(pattern) for pattern in args.exclude]

    def kept(path: str) -> bool:
        return (
            path in live
            and (not args.path or any(path.startswith(prefix) for prefix in args.path))
            and not any(pattern.search(path) for pattern in excluded)
        )

    commits, renamed = changes(args.ref, args.since)
    hot: collections.Counter[str] = collections.Counter()
    fixes: collections.Counter[str] = collections.Counter()
    pairs: collections.Counter[tuple[str, str]] = collections.Counter()
    wide: list[tuple[int, str, str]] = []
    for sha, subject, paths in commits:
        files = sorted({p for p in (current(p, renamed) for p in paths) if kept(p)})
        if not files:
            continue
        hot.update(files)
        if FIX.search(subject):
            fixes.update(files)
        if 2 <= len(files) <= args.max_files:
            for a, b in itertools.combinations(files, 2):
                if os.path.dirname(a) != os.path.dirname(b):
                    pairs[(a, b)] += 1
        wide.append((len(files), sha[:10], subject))

    print(f"# History map: {args.ref}, since {args.since}, {len(commits)} changes")
    if args.path:
        print(f"# limited to: {', '.join(args.path)}")
    print("\n## Hotspots (changes, of them with a fix-like subject, lines now)")
    for path, count in hot.most_common(args.top):
        lines = git("show", f"{args.ref}:{path}").count("\n")
        print(f"{count:5} {fixes[path]:4} {lines:6}  {path}")
    print("\n## Change coupling across directories (changes together)")
    for (a, b), count in pairs.most_common(args.top):
        print(f"{count:5}  {a}  +  {b}")
    print("\n## Widest changes (files touched; read the ones that change one concept)")
    for count, sha, subject in sorted(wide, reverse=True)[: args.top]:
        print(f"{count:5}  {sha}  {subject}")
    print("\nFix-like subjects are a rough signal: read each commit before citing it.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
