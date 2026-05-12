#!/usr/bin/env bash
# Minimal assertion helpers for shell tests.
# Each assertion increments PASS or FAIL and prints a result line.

ASSERT_PASS=0
ASSERT_FAIL=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-assertion}"
  if [[ "$expected" == "$actual" ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-contains check}"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected to contain: $needle"
    echo "    actual:              $haystack"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-not-contains check}"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected NOT to contain: $needle"
    echo "    actual:                  $haystack"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}
