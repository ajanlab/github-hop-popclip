#!/bin/bash
# GitHub Hop — Smoke Tests
# Usage: bash test.sh
# Verifies the script handles all input types without runtime errors.

PASS=0
FAIL=0

# Switch to script directory so tests work from any working directory
cd "$(dirname "$0")"

SCRIPT="github-hop.popclipext/Source/github-hop.sh"
# Verify the target exists before running tests
if [ ! -f "$SCRIPT" ]; then
  echo "❌ $SCRIPT not found — run tests from the project root"
  exit 1
fi

# Note: Tests 2-3 hit the live GitHub API (max 60 unauthenticated req/hr).
# Timeouts / rate limits are acceptable and still produce exit 0 (fallback).


pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1 (expected: $2, got: $3)"; }

# Test 1: owner/repo format
output=$(POPCLIP_TEXT="facebook/react" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "0" ] && pass "owner/repo → exit 0" || fail "owner/repo → exit 0" "0" "$code"

# Test 2: plain project name (API query; timeout is acceptable — falls back to search)
output=$(POPCLIP_TEXT="lodash" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
# Should be 0 (falls back to search on timeout, still a valid exit)
[ "$code" = "0" ] && pass "project name → exit 0" || fail "project name → exit 0" "0" "$code"

# Test 3: @username
output=$(POPCLIP_TEXT="@ajanlab" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "0" ] && pass "@username → exit 0" || fail "@username → exit 0" "0" "$code"

# Test 4: quoted empty text (trimmed to empty → exit 1, distinct from raw whitespace in test 5)
output=$(POPCLIP_TEXT='""' bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "1" ] && pass "empty quotes → exit 1" || fail "empty quotes → exit 1" "1" "$code"

# Test 5: pure whitespace
output=$(POPCLIP_TEXT="   " bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "1" ] && pass "whitespace only → exit 1" || fail "whitespace only → exit 1" "1" "$code"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
