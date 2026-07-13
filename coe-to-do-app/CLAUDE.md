# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Rails 8.1 API-only backend exposing a single GraphQL endpoint (`graphql` gem) for a to-do "lists" app. There is no REST controller layer beyond the GraphQL entry point — all reads/writes go through `POST /graphql`. See `day-4-rails-api-with-graphql.md` for the schema/query/mutation reference this app was built against.

## Environment

- Ruby version is pinned in `.ruby-version` (`ruby-3.2.10`). Gems are vendored to `vendor/bundle` (see `.bundle/config`).
- On this machine, Ruby/gem/rails/bundle are only on `PATH` after running `uru 3210`. Since each shell tool call is a fresh process, chain all ruby-related steps for a task into a single command with one leading `uru 3210;` rather than re-invoking it per call.

## Common commands

Run these behind `uru 3210;` in one chained command:

- Install deps: `bundle install`
- Start server: `bin/dev` (or `bin/rails server`)
- Console: `bin/rails console`
- Prepare/reset DB: `bin/rails db:prepare` / `bin/rails db:reset`
- Full CI suite (setup, rubocop, bundler-audit, brakeman, tests, seed replant): `bin/ci`
- Lint: `bin/rubocop`
- Security scans: `bin/bundler-audit`, `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`

### Tests

The project has migrated from Rails' built-in Minitest (`test/`) to RSpec (`spec/`); the old `test/` directory is gone. Test data uses FactoryBot factories under `spec/factories/` (e.g. `build(:list)`, `create(:list, title: "...")`) rather than fixtures. `spec/rails_helper.rb` starts SimpleCov (output in `coverage/`, gitignored) before loading Rails.

- Run full RSpec suite: `bundle exec rspec`
- Run a single spec file: `bundle exec rspec spec/models/list_spec.rb`
- Run a single example (by line number): `bundle exec rspec spec/models/list_spec.rb:21`

`bin/ci` (via `config/ci.rb`) runs `bundle exec rspec` as its test step.

For GraphQL-level specs, tag the example `type: :graphql` to pull in `spec/support/graphql_helpers.rb`'s `execute_graphql(query, variables:, context:)`, which executes against `CoeToDoAppSchema` directly and camelizes variable keys (so specs can pass `variables: { title: ... }` for a `$title` GraphQL variable).

## Architecture

**Model layer**: A single `List` model (`app/models/list.rb`) backed by the `lists` table (`id`, `title` unique, `description`, `status`). `status` is validated by inclusion against `%w[to_do in_progress done blocked]` at the model level — this is the sole source of truth for valid statuses (also mirrored in `Types::ListStatusEnum` for the GraphQL schema).

**GraphQL wiring** (`app/graphql/`):
- `CoeToDoAppSchema` (`coe_to_do_app_schema.rb`) is the schema root, wiring `Types::QueryType` and `Types::MutationType`.
- `Types::QueryType` exposes `all_lists` → `List.all`.
- `Types::MutationType` registers each mutation class as a field (`create_list`, `update_list`, `delete_list`).
- Mutations live in `app/graphql/mutations/` and subclass `Mutations::BaseMutation` (which is `GraphQL::Schema::RelayClassicMutation`). Each mutation's `resolve` method does the AR call directly (`List.create!` / `find` + `update!` / `destroy!`) and translates `ActiveRecord::RecordInvalid` / `RecordNotUnique` into `GraphQL::ExecutionError` — there is no separate service-object layer.
- `Types::ListType` defines the GraphQL-facing shape of `List`; `Types::ListStatusEnum` defines the allowed enum values for `status` in GraphQL inputs/outputs.
- Types under `app/graphql/types/base_*.rb` are the standard graphql-ruby generator scaffolding (base classes for object/enum/scalar/etc.) — extend these rather than `GraphQL::Schema::*` directly when adding new types.
- `GraphqlController#execute` (`app/controllers/graphql_controller.rb`) is the only controller action; it parses `query`/`variables`/`operationName` and executes them against `CoeToDoAppSchema`, rendering detailed error/backtrace JSON only in development.
- `/graphiql` (GraphiQL IDE) is mounted only in development (`config/routes.rb`).

**Adding a new mutation**: create a class under `app/graphql/mutations/` subclassing `BaseMutation`, declare `argument`s and a `type`, implement `resolve`, then register it as a field on `Types::MutationType`.

**Database**: SQLite for all environments (`config/database.yml`), files under `storage/`. Separate DBs are configured for cache and queue (`solid_cache` / `solid_queue`) in production only.
