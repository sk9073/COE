# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is an Incubyte "Center of Excellence" (COE) onboarding workspace. It is not a single application — it's a mix of:

- **`day-N-*/` directories** — dated learning-journal folders (culture notes, TDD katas, testing-philosophy notes, OOP-refactor writeups). Mostly markdown; a few contain small standalone Ruby kata files with their own `CLAUDE.md` (e.g. `day-3-tdd-refreshed/`).
- **`coe-to-do-app/`** — the real backend project: a Rails 8.1 GraphQL API for a to-do "lists" app.
- **`coe-to-do-fe/`** — the real frontend project: a React + TypeScript + Vite SPA that consumes that GraphQL API via Apollo Client.

`coe-to-do-app` and `coe-to-do-fe` are developed as sibling directories on purpose: the frontend's GraphQL codegen (`coe-to-do-fe/codegen.ts`) reads `../coe-to-do-app/config/graphql/schema.graphql` directly, so both must be checked out side-by-side under this root for codegen to work.

**Each project directory has its own `CLAUDE.md` with the actual commands/architecture for that project — read `coe-to-do-app/CLAUDE.md` or `coe-to-do-fe/CLAUDE.md` before working inside them.** This root file only covers things that span the whole repo.

> Note: as of this writing both sub-project `CLAUDE.md` files lag the code somewhat — e.g. `coe-to-do-app` has since grown a `app/services/lists/` command-object layer and `app/domain/list_status.rb` (see `day-10-oop-principles/improvements-made.md` for the full before/after), and `coe-to-do-fe` has moved past the stock Vite template to a real `components/todos/` feature with MSW-mocked tests. Verify against the actual `app/`/`src/` contents rather than trusting the sub-CLAUDE.md descriptions verbatim.

## Ruby/Rails environment

Ruby is only on `PATH` after running `uru 3210`. Since each shell tool call is a fresh process, chain every ruby/gem/rails/bundle-related step for a task into one command behind a single leading `uru 3210;` rather than re-invoking it per call. This applies to `coe-to-do-app/` and any Ruby kata under `day-*/`.

## Git hooks

`core.hooksPath` is set to `.githooks` (repo-level, not the default `.git/hooks`). `.githooks/pre-commit` runs RuboCop on any staged `*.rb`/`*.gemspec`/`Gemfile`/`Rakefile`/`config.ru` files under `coe-to-do-app/`, executed via `cd coe-to-do-app && bundle exec rubocop` — so RuboCop must be runnable there (behind `uru 3210`) for commits touching Ruby files to succeed.

## Working in the two sub-projects

- Backend (`coe-to-do-app/`): Rails 8.1, `graphql` gem, RSpec + FactoryBot + SimpleCov, RuboCop (omakase), Brakeman, bundler-audit. See its `CLAUDE.md` for exact commands (`bin/ci`, `bundle exec rspec`, etc.) and the GraphQL/service-object architecture.
- Frontend (`coe-to-do-fe/`): React 19 + TypeScript + Vite, Apollo Client, GraphQL Code Generator (client-preset, fragment masking — never hand-edit `src/__generated__/`), Vitest + Testing Library + MSW. See its `CLAUDE.md` for exact commands (`npm run dev`, `npm test`, `npm run codegen`, etc.).
