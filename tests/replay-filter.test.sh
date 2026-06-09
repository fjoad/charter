#!/usr/bin/env bash
# Behavioral tests for scripts/replay-filter.py against a fixture transcript
# with one record of every known injection category + edge case.

# shellcheck source=lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILTER="$REPO_DIR/scripts/replay-filter.py"
FIXTURE="$REPO_DIR/tests/fixtures/replay-sample.jsonl"

# Capture stdout (dialogue) and stderr (counts) separately.
OUT=$(python3 "$FILTER" "$FIXTURE" 2>/tmp/replay-counts.txt)
COUNTS=$(cat /tmp/replay-counts.txt)

echo "  counts line: $COUNTS"

# The fixture has exactly 4 genuine prompts and 1 assistant text reply.
assert_contains "$COUNTS" "genuine user prompts: 4" "counts 4 genuine prompts (excludes 6 injected user records)"
assert_contains "$COUNTS" "assistant text replies: 1" "counts 1 assistant text (excludes tool_use, thinking, sidechain)"

# Genuine content survives.
assert_contains "$OUT" "first genuine prompt" "first genuine prompt kept"
assert_contains "$OUT" "final genuine prompt" "final genuine prompt kept"

# Edge case: a prompt starting with '[' that is NOT an interrupt marker must survive.
assert_contains "$OUT" "Log Level: 2" "log-line prompt starting with '[' is kept (not treated as interrupt)"

# Edge case: image placeholder is stripped but the human text after it is kept.
assert_contains "$OUT" "what is shown in this screenshot" "human text after [Image #3] is kept"
assert_not_contains "$OUT" "Image #3" "the [Image #3] placeholder itself is stripped"

# Injections are excluded.
assert_not_contains "$OUT" "task-notification" "task-notification excluded"
assert_not_contains "$OUT" "command-name" "slash-command echo excluded"
assert_not_contains "$OUT" "Request interrupted" "interrupt marker excluded"
assert_not_contains "$OUT" "session is being continued" "compaction summary excluded"
assert_not_contains "$OUT" "source: /Users/x" "standalone image placeholder excluded"

# Tool I/O, thinking, sidechain excluded.
assert_not_contains "$OUT" "file1" "tool_result content excluded"
assert_not_contains "$OUT" "internal reasoning" "assistant thinking excluded"
assert_not_contains "$OUT" "subagent internal text" "sidechain record excluded"

# --counts-only suppresses dialogue but still reports counts.
CO_OUT=$(python3 "$FILTER" "$FIXTURE" --counts-only 2>/dev/null)
assert_eq "" "$CO_OUT" "--counts-only writes no dialogue to stdout"

# --- Auto-find mode (no path arg): script locates the transcript itself ---

# Build a fake projects-root whose encoded-cwd dir matches THIS shell's cwd,
# so the script's getcwd-encoding lands on it. Drop the fixture as the newest.
AF_ROOT=$(mktemp -d)
ENC=$(python3 -c "import re,os;print(re.sub(r'[^A-Za-z0-9]','-',os.getcwd()))")
mkdir -p "$AF_ROOT/$ENC"
cp "$FIXTURE" "$AF_ROOT/$ENC/older.jsonl"
sleep 1
cp "$FIXTURE" "$AF_ROOT/$ENC/newest.jsonl"   # newest by mtime — should be chosen

echo "  scenario: auto-find via --projects-root picks newest transcript"
AF_COUNTS=$(python3 "$FILTER" --projects-root "$AF_ROOT" --counts-only 2>&1)
assert_contains "$AF_COUNTS" "genuine user prompts: 4" "auto-find produces the right genuine count"
assert_contains "$AF_COUNTS" "newest.jsonl" "auto-find reports it used the newest transcript"

echo "  scenario: auto-find via CHARTER_PROJECTS_ROOT env var"
ENV_COUNTS=$(CHARTER_PROJECTS_ROOT="$AF_ROOT" python3 "$FILTER" --counts-only 2>&1)
assert_contains "$ENV_COUNTS" "genuine user prompts: 4" "env-var projects-root override works"

echo "  scenario: auto-find with no transcript present errors cleanly"
EMPTY_ROOT=$(mktemp -d)
python3 "$FILTER" --projects-root "$EMPTY_ROOT" >/dev/null 2>/tmp/af-err.txt
AF_RC=$?
AF_ERR=$(cat /tmp/af-err.txt)
assert_eq "2" "$AF_RC" "no-transcript-found exits non-zero (2)"
assert_contains "$AF_ERR" "no session transcript" "error explains no transcript was found"

rm -rf "$AF_ROOT" "$EMPTY_ROOT"
