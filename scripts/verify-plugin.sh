#!/usr/bin/env bash
# verify-plugin.sh — pre-release sanity check for the Charter plugin.
# Run before any commit touching commands/, skills/, or .claude-plugin/.
# Exits non-zero on the first failure.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

ok()   { echo "  ✓ $*"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $*"; FAIL=$((FAIL + 1)); }

echo "Charter plugin verification"
echo "==========================="

# Check 1: Every file in commands/ is a .md file
echo ""
echo "1. commands/ contains only .md files"
for f in "$REPO_DIR"/commands/*; do
  [[ -f "$f" ]] || continue
  if [[ "$f" == *.md ]]; then
    ok "$(basename "$f")"
  else
    fail "$(basename "$f") — expected .md, got ${f##*.}"
  fi
done

# Check 2: Every commands/*.md starts with YAML frontmatter (--- on line 1)
echo ""
echo "2. commands/*.md have YAML frontmatter"
for f in "$REPO_DIR"/commands/*.md; do
  [[ -f "$f" ]] || continue
  first_line=$(head -1 "$f")
  if [[ "$first_line" == "---" ]]; then
    ok "$(basename "$f")"
  else
    fail "$(basename "$f") — line 1 is not '---'"
  fi
done

# Check 3: No file in commands/ or skills/**/SKILL.md contains {{args}}
echo ""
echo "3. No {{args}} placeholder in commands/ or skills/"
found_args=0
while IFS= read -r -d '' f; do
  if grep -q '{{args}}' "$f"; then
    fail "$f — contains {{args}} (use \$ARGUMENTS instead)"
    found_args=1
  fi
done < <(find "$REPO_DIR/commands" "$REPO_DIR/skills" -type f -print0 2>/dev/null)
if [[ $found_args -eq 0 ]]; then
  ok "no {{args}} found"
fi

# Check 4: plugin.json version matches package.json version
echo ""
echo "4. plugin.json version matches package.json version"
plugin_ver=$(grep '"version"' "$REPO_DIR/.claude-plugin/plugin.json" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
package_ver=$(grep '"version"' "$REPO_DIR/package.json" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
if [[ "$plugin_ver" == "$package_ver" ]]; then
  ok "both at $plugin_ver"
else
  fail "plugin.json=$plugin_ver, package.json=$package_ver — must match"
fi

# Check 5: Every skills/*/SKILL.md has name: and description: frontmatter keys
echo ""
echo "5. skills/*/SKILL.md have name: and description: keys"
for f in "$REPO_DIR"/skills/*/SKILL.md; do
  [[ -f "$f" ]] || continue
  skill_name=$(basename "$(dirname "$f")")
  missing=""
  grep -q '^name:' "$f" || missing="${missing}name "
  grep -q '^description:' "$f" || missing="${missing}description"
  if [[ -z "$missing" ]]; then
    ok "$skill_name/SKILL.md"
  else
    fail "$skill_name/SKILL.md — missing frontmatter key(s): $missing"
  fi
done

# Summary
echo ""
echo "==========================="
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  echo "FAIL — fix the errors above before releasing"
  exit 1
fi
echo "PASS — plugin structure looks good"
exit 0
