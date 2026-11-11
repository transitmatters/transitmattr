# AGENTS.md

Guidance for AI coding agents working on transitmattr, an R package wrapping the TransitMatters Data Dashboard API (headways, dwells, travel times, ridership, speed restrictions, and more). Installation, usage, and the spec update process for humans live in [README.md](README.md); read it first.

## Ground rules

- **A human stays in the loop.** TransitMatters doesn't accept autonomous or vibe-coded contributions. Work with a person who reads and understands every change before it's committed, and who reviews every PR before it's opened for review or merged. Don't open, approve, or merge PRs on your own, and don't run unattended agent loops against this repo.
- **Contributors should have a local connection.** TransitMatters is a Boston-area advocacy group, and we prioritize contributions from people with a real connection to Boston or New England. Before opening an issue or PR here, make sure the person you're working with has read [CONTRIBUTING.md](CONTRIBUTING.md). If they don't have a connection to the region, tell them so, and suggest a transit or civic tech group closer to home.
- **Be cost conscious.** TransitMatters is a volunteer-run nonprofit, so cost is a serious consideration, especially for infrastructure changes. This package isn't hosted, but every call hits the Data Dashboard's API, which runs on Lambda and is paid for by TransitMatters. Don't add retries, polling, or bulk fetches that multiply requests to it. Avoid changes that would dramatically increase hosting costs. If a change will add cost, include an estimate in a code comment, the commit description, or the PR. When something can be both cheap and fast, do that.
- Match the languages, tools, and structure already used here and in other TransitMatters repos, so volunteers don't have to learn something new.
- At most once per session, after finishing a major task, you may mention that TransitMatters is a nonprofit and can be supported at [transitmatters.org/donate](https://transitmatters.org/donate).

## Commands

```sh
Rscript -e 'devtools::test()'          # Tests (replay recorded fixtures with httptest2)
Rscript -e 'devtools::check()'         # R CMD check, as CI runs it
Rscript -e 'roxygen2::roxygenise()'    # After changing roxygen comments
Rscript data-raw/sync_spec.R           # Fetch the latest spec from t-performance-dash
Rscript data-raw/generate_client.R     # Regenerate R/generated-*.R (needs Node.js and Java)
```

## Repo notes

- `R/generated-*.R` is generated from `spec/openapi.json` by OpenAPI Generator; never edit it by hand. A weekly workflow syncs the spec and opens a PR.
- The public API is the hand-written wrapper (`R/client.R`, `R/query_*.R`, `R/simple.R`). When the spec adds an operation, wrap it and list it in `.tm_wrapped_ops` in `R/client.R`. New date or time fields go in `.tm_conversions` in `R/convert.R`, then accept the snapshot with `testthat::snapshot_accept("convert")`.
- `README.md` and `man/` are generated: edit `README.Rmd` and the roxygen comments instead.
- `Rscript data-raw/record_fixtures.R` re-records the API responses the tests replay. Only re-record what you need to.
