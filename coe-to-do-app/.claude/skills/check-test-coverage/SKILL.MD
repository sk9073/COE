---
name: check-test-coverage
description: Check or improve the test coverage of the Rails app. Use when the user asks to check, view, or improve test coverage.
---

## How to read coverage

Coverage data from the last test run is available at:
- `coverage/.resultset.json` — machine-readable per-file line hit counts
- `coverage/index.html` — human-readable SimpleCov report

Parse `.resultset.json` to compute per-file coverage: coverage % = (lines hit / total relevant lines) × 100.
Ignore `null` entries (non-executable lines). Only count lines with integer values.

## Running tests (if fresh data needed)

Only run tests if `coverage/.resultset.json` is missing or the user explicitly asks for fresh results.
Always prefix Ruby commands with `uru 3210;` on this machine.

To run the full suite:
```
uru 3210; bundle exec rspec
```

To run a single spec file:
```
uru 3210; bundle exec rspec spec/path/to/file_spec.rb
```

## Instructions

1. **Report current coverage** — show per-file % and overall % in a table, sorted by % ascending.
2. **Flag files below 80%** — focus on business logic files (`app/models/`, `app/graphql/mutations/`, `app/services/`). Ignore boilerplate (`app/graphql/types/base_*.rb`).
3. **For each under-covered file**, propose specific RSpec tests to add:
   - No need to make any file edits