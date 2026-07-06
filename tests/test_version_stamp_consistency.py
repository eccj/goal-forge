#!/usr/bin/env python3
"""
Regression test: VERSION-STAMP consistency across goal-forge docs.

Guards the recurring 1.4/1.5 doc-hygiene prosecutor-finding class: a bumped
badge paired with a stale heading (or a heading with no VERSIONS.md row) is a
defect. Asserts one identical version string across all four anchors:

  1. README.md   shields.io status badge   ->  status-<VER>-blue.svg
  2. SKILL.md    line 6 heading            ->  # Goal Forge <VER> — ...
  3. TEMPLATE.md line 1 heading            ->  # ... (<VER>, full detail)
  4. VERSIONS.md has a table row for <VER> (SemVer column, bold-optional)

Read-only: never writes to any file. Point it at any skill dir via argv[1];
defaults to the installed skill. Deps: python3 stdlib only. Deterministic.

Exit 0  = all four anchors agree on one version.
Exit 1  = any stamp mismatch / missing anchor / missing VERSIONS row.
"""
import os
import re
import sys

DEFAULT_SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # portable: tests/..
# major.minor with optional patch, e.g. 1.6 or 1.6.2
VER = r"(\d+\.\d+(?:\.\d+)?)"


def die(msg):
    print("FAIL: " + msg)
    sys.exit(1)


def read_lines(path):
    if not os.path.isfile(path):
        die("missing required file: " + path)
    with open(path, encoding="utf-8") as fh:
        return fh.read().splitlines()


def extract(pattern, text, what):
    m = re.search(pattern, text)
    if not m:
        die("could not extract a version from %s (pattern /%s/)" % (what, pattern))
    return m.group(1)


def find_versions_md(skill):
    for cand in (os.path.join(skill, "VERSIONS.md"),
                 os.path.join(skill, "goals", "VERSIONS.md")):
        if os.path.isfile(cand):
            return cand
    for root, _dirs, files in os.walk(skill):
        if "VERSIONS.md" in files:
            return os.path.join(root, "VERSIONS.md")
    die("VERSIONS.md not found anywhere under " + skill)


def main():
    skill = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else DEFAULT_SKILL)
    if not os.path.isdir(skill):
        die("skill dir does not exist: " + skill)

    # --- Anchor 1: README status badge -------------------------------------
    readme = "\n".join(read_lines(os.path.join(skill, "README.md")))
    v_readme = extract(r"status-" + VER + r"-blue\.svg", readme,
                       "README.md status badge")

    # --- Anchor 2: SKILL.md line 6 heading ---------------------------------
    skill_lines = read_lines(os.path.join(skill, "SKILL.md"))
    if len(skill_lines) < 6:
        die("SKILL.md has fewer than 6 lines (expected the title heading at :6)")
    line6 = skill_lines[5]
    if not line6.lstrip().startswith("#") or "Goal Forge" not in line6:
        die("SKILL.md line 6 is not the 'Goal Forge' heading: %r" % line6)
    v_skill = extract(r"Goal Forge\s+" + VER, line6, "SKILL.md line 6 heading")

    # --- Anchor 3: TEMPLATE.md line 1 heading ------------------------------
    tmpl_lines = read_lines(os.path.join(skill, "TEMPLATE.md"))
    if not tmpl_lines:
        die("TEMPLATE.md is empty (expected a version-stamped heading at :1)")
    line1 = tmpl_lines[0]
    if not line1.lstrip().startswith("#"):
        die("TEMPLATE.md line 1 is not a heading: %r" % line1)
    v_template = extract(VER, line1, "TEMPLATE.md line 1 heading")

    stamps = [
        ("README badge",   v_readme),
        ("SKILL.md:6",     v_skill),
        ("TEMPLATE.md:1",  v_template),
    ]
    print("Discovered version stamps:")
    for name, val in stamps:
        print("  %-15s %s" % (name + ":", val))

    distinct = sorted({v for _, v in stamps})
    if len(distinct) != 1:
        die("version stamps DISAGREE -> " +
            ", ".join("%s=%s" % (n, v) for n, v in stamps) +
            "  (distinct: " + ", ".join(distinct) + ")")
    version = distinct[0]

    # --- Anchor 4: VERSIONS.md has a row for this version ------------------
    vpath = find_versions_md(skill)
    vtext = "\n".join(read_lines(vpath))
    # a table cell equal to the version, optionally **bold**-wrapped:
    row_re = r"\|\s*\*{0,2}" + re.escape(version) + r"\*{0,2}\s*\|"
    if not re.search(row_re, vtext):
        die("no VERSIONS.md table row for version %s in %s" % (version, vpath))
    print("VERSIONS.md row:   found for %s (%s)"
          % (version, os.path.relpath(vpath, skill)))

    print("PASS: all four anchors agree on version %s" % version)
    sys.exit(0)


if __name__ == "__main__":
    main()