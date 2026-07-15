#!/bin/bash
# GitHub Hop — selected text → GitHub repo page
# 1. "owner/repo" → direct jump (no API, instant)
# 2. plain text → API query; auto-jump ONLY if exactly 1 repo has this name
# 3. ambiguous (0 or 2+ exact matches) / API failure → GitHub search page

set -euo pipefail

readonly CURL="/usr/bin/curl"

# Python 3 — macOS does not ship python3 by default.
# Requires Xcode Command Line Tools (installed via xcode-select --install)
# or Homebrew. If unavailable, skip API and open search page directly.
PYTHON=""
command -v python3 >/dev/null 2>&1 && PYTHON="python3"
[ -z "$PYTHON" ] && [ -x /usr/bin/python3 ] && PYTHON="/usr/bin/python3"

if [ -z "$PYTHON" ]; then
    # No python3 — fast path: open search page for any input
    # (No text cleaning, no owner/repo detection — just raw search)
    raw_text=$(printf '%s\n' "${POPCLIP_TEXT:-}")
    [ -z "$raw_text" ] && exit 1
    nohup /usr/bin/open "https://github.com/search?q=$raw_text" >/dev/null 2>&1 &
    exit 0
fi
readonly PYTHON

# Step 1: clean selected text
raw_text=$(printf '%s\n' "${POPCLIP_TEXT:-}" | $PYTHON -c "
import sys
text = sys.stdin.read().strip().strip('\"').strip(\"'\").strip()
if text.startswith('@'): text = text[1:]
print(text)
")

[ -z "$raw_text" ] && exit 1

# Step 2: URL-encode
encoded=$(printf '%s\n' "$raw_text" | $PYTHON -c "
import urllib.parse, sys
print(urllib.parse.quote(sys.stdin.read().strip(), safe=''))
")

# Step 3: owner/repo → direct jump (no API)
if printf '%s\n' "$raw_text" | grep -qE '^[a-zA-Z0-9][a-zA-Z0-9_.-]*/[a-zA-Z0-9_][a-zA-Z0-9_.-]*$'; then
    # nohup: PopClip sends SIGHUP to child processes; without it the browser never opens
    nohup /usr/bin/open "https://github.com/$raw_text" >/dev/null 2>&1 &
    exit 0
fi

# Step 4: try GitHub API — only auto-jump if unambiguous
response=$($CURL -sf --connect-timeout 3 --max-time 5 \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: github-hop-popclip/1.0" \
    "https://api.github.com/search/repositories?q=${encoded}+in:name&per_page=10&sort=stars&order=desc" 2>/dev/null || true)

# Step 5: parse API response
#   Auto-jump ONLY if exactly 1 repo has this exact name (unambiguous).
#   0 matches → no such repo exists → search page
#   2+ matches → ambiguous → search page (let user pick)
target="FALLBACK"
if [ -n "$response" ]; then
    target=$(echo "$response" | $PYTHON -c "
import json, sys
try:
    data = json.loads(sys.stdin.read())
    items = data.get('items', [])
    if 'rate limit' in data.get('message', '').lower() or not items:
        print('FALLBACK'); sys.exit(0)
    txt = sys.argv[1].strip().lower() if len(sys.argv) > 1 else ''
    exact = [r for r in items if r['name'].lower() == txt]
    # Only auto-jump when exactly one repo has this exact name
    print(exact[0]['full_name'] if len(exact) == 1 else 'FALLBACK')
except Exception:
    print('FALLBACK')
" "$raw_text" 2>/dev/null || echo "FALLBACK")
fi

# Step 6: open in browser
if [ "$target" = "FALLBACK" ] || [ -z "$target" ]; then
    nohup /usr/bin/open "https://github.com/search?q=$encoded" >/dev/null 2>&1 &
else
    nohup /usr/bin/open "https://github.com/$target" >/dev/null 2>&1 &
fi
