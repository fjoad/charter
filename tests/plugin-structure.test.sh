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

# --- Version sync (also checked by verify-plugin.sh, but cheap to assert here) ---

echo "  scenario: plugin and package versions match"

plugin_ver=$(python3 -c "import json; print(json.load(open('$REPO_DIR/.claude-plugin/plugin.json'))['version'])")
package_ver=$(python3 -c "import json; print(json.load(open('$REPO_DIR/package.json'))['version'])")
assert_eq "$plugin_ver" "$package_ver" "plugin.json and package.json versions match ($plugin_ver)"
