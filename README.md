# GitHub Hop

[中文](./README.zh-CN.md) | English

Select any text → instantly jump to its GitHub repo homepage.

## Features

- **`owner/repo`** (e.g. `facebook/react`) → instant jump, zero latency
- **Project name** (e.g. `lodash`) → GitHub Search API resolves to the best matching repo
- **Author name** (e.g. `@ajanlab`) → auto-strip `@`, search GitHub
- **Fallback** → API failure / rate limit / timeout → gracefully degrades to GitHub search

## Installation

1. Download `github-hop.popclipextz`
2. Double-click to install into PopClip
3. Select any text → click the GitHub icon in PopClip's toolbar

System requirements: macOS 10.15+, PopClip 2023+

## How It Works

```
Selected text → clean (strip quotes/@) → owner/repo? ─yes→ direct jump (0ms)
                                           └no→ API request (5s timeout)
                                                 ├─ exact match → repo page
                                                 ├─ smart match → repo page
                                                 └─ failure/limit → search page
```

## Privacy

- **No data uploaded** — only sends text you explicitly selected to the public GitHub API
- **No analytics** — no telemetry, no third-party endpoints
- **No storage** — no cache files, no logs, no state
- **No permissions needed** — no API keys, no login, no network authorization (handled by PopClip)
- **Zero external dependencies** — only macOS built-in tools (bash, python3, curl, open)

## Verification

Test from the command line (no PopClip needed):

```bash
# 1. Test owner/repo direct jump (zero latency)
export POPCLIP_TEXT="facebook/react"
./github-hop.popclipext/Source/github-hop.sh
# Expected: opens https://github.com/facebook/react directly

# 2. Test project name API resolution
export POPCLIP_TEXT="lodash"
./github-hop.popclipext/Source/github-hop.sh
# Expected: API resolves to https://github.com/lodash/lodash

# 3. Test @username handling
export POPCLIP_TEXT="@ajanlab"
./github-hop.popclipext/Source/github-hop.sh
# Expected: strips @, searches "ajanlab"

# 4. Test nonexistent project (fallback)
export POPCLIP_TEXT="this-project-does-not-exist-12345"
./github-hop.popclipext/Source/github-hop.sh
# Expected: API returns no results, opens GitHub search page

# 5. Test empty input
export POPCLIP_TEXT=""
./github-hop.popclipext/Source/github-hop.sh
# Expected: exit code 1, no browser action

# 6. Run automated test suite
chmod +x test.sh && ./test.sh
```

## Environment Variables

| Variable | Source | Description |
|---|---|---|
| `POPCLIP_TEXT` | PopClip | Selected text (required) |

No API keys required. Zero configuration.

## License

MIT License — free to use, modify, and distribute.
