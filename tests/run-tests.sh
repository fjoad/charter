#!/usr/bin/env bash
# Charter test runner. Executes every tests/*.test.sh and reports totals.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0

echo "Charter test suite"
echo "=================="

for test_file in "$REPO_DIR"/tests/*.test.sh; do
  [[ -f "$test_file" ]] || continue
  echo ""
  echo "▸ $(basename "$test_file")"
  ASSERT_PASS=0
  ASSERT_FAIL=0
  # shellcheck disable=SC1090
  source "$test_file"
  TOTAL_PASS=$((TOTAL_PASS + ASSERT_PASS))
  TOTAL_FAIL=$((TOTAL_FAIL + ASSERT_FAIL))
done

echo ""
echo "=================="
echo "Results: $TOTAL_PASS passed, $TOTAL_FAIL failed"
if [[ $TOTAL_FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
