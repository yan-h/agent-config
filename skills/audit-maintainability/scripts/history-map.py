#!/usr/bin/env python3
"""Map where change lands on a branch: hotspots, change coupling, fix clusters
and the widest changes, with renames followed to each file's current path.

Run from inside the repository:

    history-map.py origin/main --since "1 year ago" [--path crates/foo/ ...] [--exclude REGEX ...]

Each change landing on the branch counts once: merges are read as their whole
first-parent diff, under their PR's title, so a merged branch and a squashed PR
count the same. Each path is followed through renames to the file it is now;
a path that was deleted or replaced counts for nothing.
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
GONE = None  # an older path whose file no longer exists under any name


def git(*args: str) -> str:
    # quotePath off: non-ASCII names come out as themselves rather than as
    # quoted octal, so they match across commands and can be shown.
    result = subprocess.run(
        ["git", "-c", "core.quotePath=false", *args], capture_output=True, text=True, errors="replace"
    )
    if result.returncode != 0:
        sys.exit(f"git {' '.join(args)}: {result.stderr.strip()}")
    return result.stdout


def changes(ref: str, window: list[str]) -> list[tuple[str, str, list[str]]]:
    """Changes newest first as (hash, title, current paths)."""
    titles = {}
    for record in git("log", ref, *window, "--first-parent", "--merges", "--format=%H%x1f%b%x1e").split("\x1e"):
        sha, _, body = record.strip().partition("\x1f")
        title = next((line for line in body.splitlines() if line.strip()), "")
        if sha and title:
            titles[sha] = title
    log = git(
        "log", ref, *window, "--first-parent", "--diff-merges=first-parent",
        "-M", "--name-status", "--format=@@%H %s",
    )
    commits: list[tuple[str, str, list[str]]] = []
    # Walking newest first: where a path in an OLDER change lives now.
    alias: dict[str, str | None] = {}
    gone: list[str] = []
    moved: list[tuple[str, str | None]] = []

    def settle() -> None:
        # A rename's source outranks a path the same change added or vacated.
        for path in gone:
            alias[path] = GONE
        for path, now in moved:
            alias[path] = now
        gone.clear()
        moved.clear()

    for line in log.splitlines():
        if line.startswith("@@"):
            settle()
            sha, _, subject = line[2:].partition(" ")
            commits.append((sha, titles.get(sha, subject), []))
        elif line.strip() and commits:
            fields = line.split("\t")
            status, path = fields[0], fields[-1]
            now = alias.get(path, path)
            if now is not GONE:
                commits[-1][2].append(now)
            if status.startswith("R") and len(fields) == 3:
                gone.append(fields[2])
                moved.append((fields[1], now))
            elif status.startswith("A"):
                gone.append(path)
    settle()
    return commits


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("ref", help="the primary branch, fetched, e.g. origin/main")
    parser.add_argument("--since", default="1 year ago")
    parser.add_argument("--max-count", type=int, help="only the last N changes, instead of --since")
    parser.add_argument("--path", action="append", default=[],
                        help="limit to this file or directory (repeatable; pass every one an area spans)")
    parser.add_argument("--exclude", action="append", default=[], help="drop paths matching this regex (repeatable)")
    parser.add_argument("--top", type=int, default=25)
    parser.add_argument("--max-files", type=int, default=12,
                        help="commits touching more files than this are left out of coupling")
    args = parser.parse_args()

    live = set(git("ls-tree", "-r", "--name-only", args.ref).splitlines())
    excluded = [re.compile(pattern) for pattern in args.exclude]
    prefixes = [p if p in live or p.endswith("/") else p + "/" for p in args.path]

    def kept(path: str) -> bool:
        return (
            path in live
            and (not prefixes or any(path == prefix or path.startswith(prefix) for prefix in prefixes))
            and not any(pattern.search(path) for pattern in excluded)
        )

    window = [f"--max-count={args.max_count}"] if args.max_count else [f"--since={args.since}"]
    commits = changes(args.ref, window)
    hot: collections.Counter[str] = collections.Counter()
    fixes: collections.Counter[str] = collections.Counter()
    pairs: collections.Counter[tuple[str, str]] = collections.Counter()
    wide: list[tuple[int, str, str]] = []
    for sha, subject, paths in commits:
        files = sorted({p for p in paths if kept(p)})
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

    span = f"last {args.max_count}" if args.max_count else f"since {args.since}"
    print(f"# History map: {args.ref}, {span}: {len(commits)} changes, {len(wide)} touching the files mapped")
    if prefixes:
        print(f"# limited to: {', '.join(prefixes)}")
    print("\n## Hotspots (changes, of them with a fix-like subject, lines now)")
    for path, count in hot.most_common(args.top):
        lines = git("cat-file", "-p", f"{args.ref}:{path}").count("\n")
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
