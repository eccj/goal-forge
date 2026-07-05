#!/usr/bin/env python3
# test_xref_anchors.py — CROSS-REFERENCE / dangling-anchor integrity regression test.
#
# Class guarded (the 1.6-S2 prosecutor finding): a "§Name" reference in SKILL.md
# or TEMPLATE.md whose target "## §Name" heading does not exist (a dangling anchor).
#
# For every §Name reference in SKILL.md / TEMPLATE.md this asserts a matching
# "## §Name" heading (or a documented anchor) resolves:
#   - SKILL "[STACKS.md](STACKS.md) §Firing" -> STACKS.md "## §Firing rule ..."
#   - SKILL "[RECIPES.md](RECIPES.md) §Notation" -> RECIPES.md "## §Notation standard ..."
#   - SKILL/TEMPLATE "TEMPLATE §Fallback" -> TEMPLATE.md "## §Fallback ..."
#
# Deps: python3 stdlib ONLY (no shasum needed here). Deterministic. READ-ONLY:
# it never writes to or mutates any skill file. Point it at a scratch COPY to
# test a break. Exit 0 = all references resolve; non-zero = a dangling anchor.
#
# Usage:  python3 test_xref_anchors.py [SKILL_DIR]
#   SKILL_DIR defaults to argv[1], else $GOAL_FORGE_DIR, else the cwd if it holds
#   SKILL.md, else the installed skill path.

import os
import re
import sys

# ---- locate the skill dir (read-only target) -------------------------------
INSTALLED = "/Users/emrew/.claude/skills/goal-forge"
if len(sys.argv) > 1:
    ROOT = sys.argv[1]
elif os.environ.get("GOAL_FORGE_DIR"):
    ROOT = os.environ["GOAL_FORGE_DIR"]
elif os.path.exists(os.path.join(os.getcwd(), "SKILL.md")):
    ROOT = os.getcwd()
else:
    ROOT = INSTALLED

# Files whose §refs we audit (task scope).
REF_FILES = ["SKILL.md", "TEMPLATE.md"]

# Documented anchors that legitimately have NO "## §Name" heading in the skill
# (they point at an external maintainer-private record). Matched on first word,
# case-insensitively. Kept deliberately tiny so it can't mask a real regression.
KNOWN_EXTERNAL = {"incident"}  # "the maintainer-private tournament record §Incident"

# Known skill basenames used as inline file markers ("TEMPLATE §X", "[STACKS.md]...").
FILE_BASENAMES = ["SKILL", "TEMPLATE", "RECIPES", "STACKS", "LINT",
                  "CAMPAIGN", "README", "CONTRIBUTING", "QUICKSTART"]
FILE_RE = re.compile(r"\b(" + "|".join(FILE_BASENAMES) + r")(?:\.md)?\b")

# Chars that terminate a §Name (space is NOT a terminator: names can be multiword,
# e.g. "Light mode", "Notation standard"). Prose after the name is cut here.
DELIMS = set('.,()[]{}·—:;"`?!<>≤≥*/\n\t‘’“”')
STRIP = ' .,;:"`\'()[]'


def read(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def is_heading(line):
    return re.match(r"\s*#{1,6}\s+", line) is not None


def is_anchor_def(line):
    # "## §Name ..." heading -> an anchor DEFINITION.
    return re.match(r"\s*#{1,6}\s+§", line) is not None


def numbered_heading(line):
    # "## 1. Scan ..." or "## 0. ..." -> returns the int, else None.
    m = re.match(r"\s*#{1,6}\s+§?\s*(\d+)[.):\s]", line)
    return int(m.group(1)) if m else None


def name_words(name):
    """Tokenize a §name into lowercased word tokens (split on whitespace only;
    hyphens kept so '§RED-HOLD' / 'No-external-dependency' stay single tokens)."""
    out = []
    for tok in name.split():
        tok = tok.strip(STRIP)
        if tok:
            out.append(tok.lower())
    return out


def extract_name(after):
    """From the text immediately after a '§', return ('num', n) for a numbered
    section reference, or ('named', words) for a named anchor reference."""
    m = re.match(r"\d+", after)
    if m:
        return ("num", int(m.group(0)))
    buf = []
    for ch in after:
        if ch in DELIMS:
            break
        buf.append(ch)
    return ("named", name_words("".join(buf)))


def word_prefix_match(a, b):
    """True if one word list is a (case-insensitive) word-prefix of the other.
    Handles both directions: short ref -> long anchor ('Notation' vs
    'Notation standard') AND long ref-in-prose -> short anchor ('§RED-HOLD terminal
    HOLD' vs '§RED-HOLD')."""
    n = min(len(a), len(b))
    if n == 0:
        return False
    return a[:n] == b[:n]


def build_universe():
    """Scan every *.md in ROOT for anchor DEFINITIONS and numbered sections."""
    anchors_by_file = {}   # basename.md -> [word-list, ...]
    numbered_by_file = {}  # basename.md -> set(int)
    all_anchor_words = []  # flat list of every anchor word-list (global universe)
    md_files = sorted(f for f in os.listdir(ROOT) if f.endswith(".md"))
    for fname in md_files:
        anchors_by_file.setdefault(fname, [])
        numbered_by_file.setdefault(fname, set())
        for line in read(os.path.join(ROOT, fname)).splitlines():
            if is_anchor_def(line):
                after = line.split("§", 1)[1]
                _, words = extract_name(after)
                if words:
                    anchors_by_file[fname].append(words)
                    all_anchor_words.append(words)
            n = numbered_heading(line)
            if n is not None:
                numbered_by_file[fname].add(n)
    return anchors_by_file, numbered_by_file, all_anchor_words


def collect_refs():
    """Scan REF_FILES for §references (skipping anchor-definition heading lines)."""
    refs = []  # dict per reference
    for fname in REF_FILES:
        path = os.path.join(ROOT, fname)
        if not os.path.exists(path):
            continue
        for lineno, line in enumerate(read(path).splitlines(), 1):
            if is_anchor_def(line):
                continue  # a "## §Name" heading defines, does not reference
            for m in re.finditer("§", line):
                idx = m.start()
                after = line[idx + 1:]
                kind, val = extract_name(after)
                if kind == "named" and not val:
                    continue  # a bare "§" with no name (e.g. RECIPES' "§X" placeholder)
                # inline file marker = last skill basename before the § on this line
                marker = None
                for fm in FILE_RE.finditer(line[:idx]):
                    marker = fm.group(1) + ".md"
                refs.append({
                    "src": fname, "line": lineno, "kind": kind,
                    "val": val, "marker": marker,
                    "text": line[idx:idx + 40].rstrip(),
                })
    return refs


def resolve(ref, anchors_by_file, numbered_by_file, all_anchor_words):
    """Return (ok: bool, target_desc: str, reason: str)."""
    if ref["kind"] == "num":
        n = ref["val"]
        src = ref["src"]
        if n in numbered_by_file.get(src, set()):
            return True, "%s ## %d." % (src, n), "numbered section present"
        return False, "%s ## %d." % (src, n), "no '## %d.' section in %s" % (n, src)

    words = ref["val"]
    # documented external anchor (no heading by design)
    if words and words[0] in KNOWN_EXTERNAL:
        return True, "external", "documented external anchor (allowlisted)"

    if ref["marker"]:
        target = ref["marker"]
        pool = anchors_by_file.get(target, [])
        if any(word_prefix_match(words, a) for a in pool):
            return True, target, "anchor present in target file"
        # not in the named target -> dangling (even if it exists elsewhere)
        elsewhere = any(word_prefix_match(words, a) for a in all_anchor_words)
        why = ("anchor exists but NOT in target %s (found elsewhere)" % target
               if elsewhere else "no matching '## §%s' anywhere" % " ".join(words))
        return False, target, why

    # no inline marker -> cross-doc concept ref: require it in the global universe
    if any(word_prefix_match(words, a) for a in all_anchor_words):
        return True, "global", "anchor present in skill universe"
    return False, "global", "no matching '## §%s' in any skill file" % " ".join(words)


def main():
    if not os.path.exists(os.path.join(ROOT, "SKILL.md")):
        print("FATAL: no SKILL.md under %s" % ROOT)
        return 2

    anchors_by_file, numbered_by_file, all_anchor_words = build_universe()
    refs = collect_refs()

    # anti-vacuous-green guard: the parse must actually find references. If the
    # §-notation ever changes and the scanner silently matches nothing, that is
    # itself a regression, not a pass.
    MIN_REFS = 6
    print("skill dir: %s" % ROOT)
    print("anchors in universe: %d  |  §references scanned: %d\n"
          % (len(all_anchor_words), len(refs)))

    dangling = []
    for r in refs:
        ok, target, reason = resolve(r, anchors_by_file, numbered_by_file,
                                     all_anchor_words)
        tag = "OK    " if ok else "DANGLE"
        label = ("§%d" % r["val"]) if r["kind"] == "num" else ("§" + " ".join(r["val"]))
        print("[%s] %-11s %-18s -> %-14s  %s"
              % (tag, "%s:%d" % (r["src"], r["line"]), label, target, reason))
        if not ok:
            dangling.append((r, target, reason))

    print()
    if len(refs) < MIN_REFS:
        print("FAIL: only %d references scanned (< %d) — parser found too few; "
              "the §-reference notation may have changed." % (len(refs), MIN_REFS))
        return 3
    if dangling:
        print("FAIL: %d dangling anchor reference(s):" % len(dangling))
        for r, target, reason in dangling:
            lbl = ("§%d" % r["val"]) if r["kind"] == "num" else ("§" + " ".join(r["val"]))
            print("  - %s:%d  %s  (target %s) — %s"
                  % (r["src"], r["line"], lbl, target, reason))
        return 1
    print("PASS: all %d §references resolve to an existing anchor." % len(refs))
    return 0


if __name__ == "__main__":
    sys.exit(main())