#!/usr/bin/env python3
"""
replay-filter.py — extract genuine dialogue from a Claude Code session transcript.

Reads a .jsonl transcript and emits only genuine human prompts and assistant
text replies. Excludes:
  - tool I/O (tool_use / tool_result blocks)
  - assistant thinking blocks
  - subagent / sidechain records (isSidechain)
  - harness-injected user-role records:
      * task notifications        (<task-notification ...>)
      * slash-command echoes       (<local-command...>, <command-name>, etc.)
      * interrupt markers          ([Request interrupted ...])
      * compaction summaries       (isCompactSummary flag, text-prefix fallback)
      * standalone image placeholders ([Image: ...] with no human text)

Usage:
    python3 replay-filter.py <transcript.jsonl> [--counts-only]

Writes filtered dialogue to stdout (### USER / ### ASSISTANT blocks) and a
one-line count summary to stderr.

Injection inventory empirically derived from a parallel sweep of ~7,800
transcripts across 11 projects (8,542 genuine prompts vs 288 injections).
See docs/decisions/2026-06-09-replay-filter-as-script.md for the rationale,
including why structural flags alone are insufficient (genuine prompts can
carry isMeta=True; injections can carry no flags) and why the interrupt
marker must match the full '[Request interrupted' prefix (genuine prompts
legitimately start with '[': '[Image #3]...', '[11:27:15] log...', etc.).
"""
import sys
import os
import re
import glob
import json

# Matches harness image placeholders anywhere in the text, e.g.
#   [Image #3]
#   [Image: original 3446x1168, displayed at 2000x678. ...]
#   [Image: source: /Users/.../image-cache/<uuid>/3.png]
IMG = re.compile(r"\[Image[^\]]*\]")

COMPACTION_PREFIX = "This session is being continued from a previous conversation"


def is_injected_user_text(s):
    """True if the stripped user-record text is a harness injection, not a human prompt."""
    if s.startswith("<task-notification"):
        return True
    if (
        s.startswith("<local-command")
        or s.startswith("<command-name>")
        or s.startswith("<command-message>")
        or s.startswith("<command-args>")
    ):
        return True
    # CRITICAL: full prefix only. Genuine prompts can start with '[' (logs, image tags).
    if s.startswith("[Request interrupted"):
        return True
    # Text fallback for compaction when the structural flag is absent.
    if s.startswith(COMPACTION_PREFIX):
        return True
    return False


def extract_text(content):
    """Join the text blocks of a content value (str or list); return '' if none."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = [
            b.get("text", "")
            for b in content
            if isinstance(b, dict) and b.get("type") == "text"
        ]
        return " ".join(parts)
    return ""


def has_tool_result(content):
    return isinstance(content, list) and any(
        isinstance(b, dict) and b.get("type") == "tool_result" for b in content
    )


def filter_transcript(path):
    """Yield (label, body) for each genuine turn, and return (gen_user, asst) counts."""
    gen_user = 0
    asst = 0
    out = []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
            except Exception:
                continue
            role = e.get("type")
            if role not in ("user", "assistant"):
                continue
            # Skip subagent / sidechain records — not the human<->main dialogue.
            if e.get("isSidechain") is True:
                continue
            content = (e.get("message") or {}).get("content")

            if role == "user":
                # Structural compaction-summary check (unspoofable, preferred).
                if e.get("isCompactSummary") is True:
                    continue
                # Drop tool-result-bearing user records structurally.
                if has_tool_result(content):
                    continue
                s = extract_text(content).strip()
                if not s:
                    continue
                if is_injected_user_text(s):
                    continue
                # Image placeholders: strip them; keep the record only if human text remains.
                stripped = IMG.sub("", s).strip()
                if not stripped:
                    continue  # standalone harness image placeholder
                gen_user += 1
                out.append(("USER", stripped))
            else:  # assistant
                txt = extract_text(content)
                # Normalize whitespace across multiple text blocks.
                txt = "\n".join(t.strip() for t in txt.split("\n") if t.strip())
                if not txt.strip():
                    continue
                asst += 1
                out.append(("ASSISTANT", txt.strip()))
    return out, gen_user, asst


def encode_cwd(path):
    """Encode a working directory to its Claude Code session-dir name.

    Convention: every non-alphanumeric character becomes '-'.
    e.g. /Users/me/proj -> -Users-me-proj
         /a/Personal Information (1)/x -> -a-Personal-Information--1--x
    """
    return re.sub(r"[^A-Za-z0-9]", "-", path)


def find_current_transcript(projects_root=None):
    """Locate the current session's transcript: newest *.jsonl in the
    encoded-cwd session dir under projects_root.

    Returns the path, or None if no transcript is found.
    """
    if projects_root is None:
        projects_root = os.environ.get("CHARTER_PROJECTS_ROOT") or os.path.expanduser(
            "~/.claude/projects"
        )
    session_dir = os.path.join(projects_root, encode_cwd(os.getcwd()))
    if not os.path.isdir(session_dir):
        return None
    candidates = glob.glob(os.path.join(session_dir, "*.jsonl"))
    if not candidates:
        return None
    return max(candidates, key=os.path.getmtime)


def main():
    argv = sys.argv[1:]
    counts_only = "--counts-only" in argv

    # --projects-root <dir> override (consumes the following token)
    projects_root = None
    cleaned = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "--projects-root":
            if i + 1 < len(argv):
                projects_root = argv[i + 1]
                i += 2
                continue
            sys.stderr.write("error: --projects-root requires a directory argument\n")
            sys.exit(2)
        cleaned.append(a)
        i += 1

    positional = [a for a in cleaned if not a.startswith("--")]

    if positional:
        path = positional[0]
    else:
        # No path given: find this session's transcript automatically.
        path = find_current_transcript(projects_root)
        if path is None:
            root = projects_root or os.environ.get("CHARTER_PROJECTS_ROOT") or "~/.claude/projects"
            sys.stderr.write(
                "error: no session transcript found for cwd "
                f"({os.getcwd()}) under {root}. "
                "Pass an explicit <transcript.jsonl> path, or run from the project directory.\n"
            )
            sys.exit(2)
        sys.stderr.write(f"[transcript] {path}\n")

    out, gen_user, asst = filter_transcript(path)
    if not counts_only:
        for label, body in out:
            print("### " + label)
            print(body)
            print()
    sys.stderr.write(
        f"[counts] genuine user prompts: {gen_user} | assistant text replies: {asst}\n"
    )


if __name__ == "__main__":
    main()
