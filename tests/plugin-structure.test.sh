#!/usr/bin/env bash
# Structural integrity tests for the plugin: JSON validity, file references,
# and required content in markdown command files.

# shellcheck source=lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- JSON validity ---

echo "  scenario: JSON files parse correctly"

for json_file in .claude-plugin/plugin.json package.json hooks/hooks.json; do
  if python3 -c "import json; json.load(open('$REPO_DIR/$json_file'))" 2>/dev/null; then
    assert_eq "valid" "valid" "$json_file is valid JSON"
  else
    assert_eq "valid" "invalid" "$json_file is valid JSON"
  fi
done

# --- hooks.json command paths exist ---

echo "  scenario: hooks.json command paths reference real files"

# Extract command strings, look for ${CLAUDE_PLUGIN_ROOT}/<path> references,
# substitute REPO_DIR for ${CLAUDE_PLUGIN_ROOT}, and confirm each file exists.
hook_paths=$(python3 <<PY
import json, re
with open("$REPO_DIR/hooks/hooks.json") as f:
    data = json.load(f)
paths = []
def walk(node):
    if isinstance(node, dict):
        for v in node.values(): walk(v)
    elif isinstance(node, list):
        for v in node: walk(v)
    elif isinstance(node, str):
        for m in re.findall(r'\\\${CLAUDE_PLUGIN_ROOT}/([^"\s]+)', node):
            paths.append(m)
walk(data)
print("\n".join(paths))
PY
)

while IFS= read -r p; do
  [[ -z "$p" ]] && continue
  if [[ -f "$REPO_DIR/$p" ]]; then
    assert_eq "exists" "exists" "hooks.json references existing file: $p"
  else
    assert_eq "exists" "missing" "hooks.json references existing file: $p"
  fi
done <<< "$hook_paths"

# --- Required content in command files ---

echo "  scenario: command files contain expected content"

if grep -q "Main Branch Flow" "$REPO_DIR/commands/charter-finish.md"; then
  assert_eq "present" "present" "charter-finish.md has Main Branch Flow section"
else
  assert_eq "present" "missing" "charter-finish.md has Main Branch Flow section"
fi

if grep -q "Feature Branch Flow" "$REPO_DIR/commands/charter-finish.md"; then
  assert_eq "present" "present" "charter-finish.md has Feature Branch Flow section"
else
  assert_eq "present" "missing" "charter-finish.md has Feature Branch Flow section"
fi

if grep -q "Convention: \`branches\`" "$REPO_DIR/commands/charter-adopt.md"; then
  assert_eq "present" "present" "charter-adopt.md has branches convention block"
else
  assert_eq "present" "missing" "charter-adopt.md has branches convention block"
fi

if grep -q "Convention: \`context\`" "$REPO_DIR/commands/charter-adopt.md"; then
  assert_eq "present" "present" "charter-adopt.md has context convention block"
else
  assert_eq "present" "missing" "charter-adopt.md has context convention block"
fi

if grep -q "categorize the content" "$REPO_DIR/commands/charter-remember.md" 2>/dev/null || grep -qi "Categorize" "$REPO_DIR/commands/charter-remember.md"; then
  assert_eq "present" "present" "charter-remember.md has categorization step"
else
  assert_eq "present" "missing" "charter-remember.md has categorization step"
fi

if grep -q "Do NOT read" "$REPO_DIR/commands/charter-recover.md"; then
  assert_eq "present" "present" "charter-recover.md forbids reading the transcript"
else
  assert_eq "present" "missing" "charter-recover.md forbids reading the transcript"
fi

if grep -q "CONTEXT.md" "$REPO_DIR/commands/charter-recover.md" && grep -q "STATUS.md" "$REPO_DIR/commands/charter-recover.md"; then
  assert_eq "present" "present" "charter-recover.md has the recovery read order"
else
  assert_eq "present" "missing" "charter-recover.md has the recovery read order"
fi

if [[ -f "$REPO_DIR/commands/charter-replay.md" ]]; then
  assert_eq "present" "present" "charter-replay.md exists"
else
  assert_eq "present" "missing" "charter-replay.md exists"
fi

if grep -q "session-dialog.txt" "$REPO_DIR/commands/charter-replay.md" 2>/dev/null; then
  assert_eq "present" "present" "charter-replay.md has the filter pipeline"
else
  assert_eq "present" "missing" "charter-replay.md has the filter pipeline"
fi

if grep -q "replace every \`/\` with \`-\`" "$REPO_DIR/commands/charter-replay.md" 2>/dev/null; then
  assert_eq "present" "present" "charter-replay.md explains session-dir encoding"
else
  assert_eq "present" "missing" "charter-replay.md explains session-dir encoding"
fi

if grep -q "charter-replay" "$REPO_DIR/commands/charter-recover.md" 2>/dev/null; then
  assert_eq "present" "present" "charter-recover.md mentions charter-replay as tier-2 fallback"
else
  assert_eq "present" "missing" "charter-recover.md mentions charter-replay as tier-2 fallback"
fi

if [[ -f "$REPO_DIR/commands/charter-preview.md" ]]; then
  assert_eq "present" "present" "charter-preview.md exists"
else
  assert_eq "present" "missing" "charter-preview.md exists"
fi

if grep -q "Never write a file" "$REPO_DIR/commands/charter-preview.md" 2>/dev/null; then
  assert_eq "present" "present" "charter-preview.md has the no-write hard rule"
else
  assert_eq "present" "missing" "charter-preview.md has the no-write hard rule"
fi

if grep -q "NEW" "$REPO_DIR/commands/charter-preview.md" && grep -q "EXISTS" "$REPO_DIR/commands/charter-preview.md"; then
  assert_eq "present" "present" "charter-preview.md uses NEW/EXISTS marking"
else
  assert_eq "present" "missing" "charter-preview.md uses NEW/EXISTS marking"
fi

if grep -q "CONTEXT.md edits ARE allowed on feature branches" "$REPO_DIR/.claude/rules/workflow.md" 2>/dev/null; then
  assert_eq "present" "present" "Charter's workflow.md states CONTEXT.md is allowed on branches"
else
  assert_eq "present" "missing" "Charter's workflow.md states CONTEXT.md is allowed on branches"
fi

if grep -q "CONTEXT.md edits ARE allowed on feature branches" "$REPO_DIR/template/.claude/rules/workflow.md" 2>/dev/null; then
  assert_eq "present" "present" "template workflow.md states CONTEXT.md is allowed on branches"
else
  assert_eq "present" "missing" "template workflow.md states CONTEXT.md is allowed on branches"
fi

if grep -q "CONTEXT.md.* updates ARE allowed" "$REPO_DIR/commands/charter-finish.md" 2>/dev/null; then
  assert_eq "present" "present" "charter-finish.md feature-branch flow permits CONTEXT.md updates"
else
  assert_eq "present" "missing" "charter-finish.md feature-branch flow permits CONTEXT.md updates"
fi

# --- Version sync (also checked by verify-plugin.sh, but cheap to assert here) ---

echo "  scenario: plugin and package versions match"

plugin_ver=$(python3 -c "import json; print(json.load(open('$REPO_DIR/.claude-plugin/plugin.json'))['version'])")
package_ver=$(python3 -c "import json; print(json.load(open('$REPO_DIR/package.json'))['version'])")
assert_eq "$plugin_ver" "$package_ver" "plugin.json and package.json versions match ($plugin_ver)"
