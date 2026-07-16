## Context: GraphQL query — lists filtered by status

### Task
Add an optional `status` argument to the existing `all_lists` GraphQL query field. Returns all Lists when omitted, filtered by status when provided.

### Conventions found
- Mutations use `argument :name, Type, required: true/false` (no explicit `null:`) — e.g. `app/graphql/mutations/update_list.rb:4-7` has optional args pattern.
- Enum type reused directly as argument type: `Types::ListStatusEnum` used in `create_list.rb:6` and `update_list.rb:7`. Same enum should be used for the new `status` arg on `all_lists`.
- `app/graphql/types/query_type.rb:5-9` is the only query field today — `field :all_lists, [Types::ListType], null: false`, resolver body is `Rails.cache.fetch("all_lists", expires_in: 30.seconds) { List.all.to_a }`.
- Convention for adding the arg: `field :all_lists, [Types::ListType], null: false do; argument :status, Types::ListStatusEnum, required: false; end` and `def all_lists(status: nil)`.
- `Types::ListType` and `Types::ListStatusEnum` need no changes.

### CRITICAL: caching bug to fix as part of this change
- Current cache key is fixed: `"all_lists"` (`query_type.rb:8`). Once `status` becomes a filter arg, this key MUST vary by status (e.g. `"all_lists/#{status || 'all'}"`), otherwise the first call poisons the cache for every subsequent call regardless of filter, for up to 30s.
- Mutations invalidate with `Rails.cache.delete("all_lists")`: `create_list.rb:17`, `update_list.rb:17`, `delete_list.rb:13`. These must be updated too (e.g. delete all `all_lists/*` variants via `Rails.cache.delete_matched`, or a versioned key scheme) or they'll silently stop invalidating per-status cache entries.
- Test env uses `:null_store` (`config/environments/test.rb:23`) so this bug won't be caught by specs unless a spec explicitly exercises `Rails.cache`. Dev uses Redis, prod uses `solid_cache_store` — bug would manifest there.

### Testing patterns
- `spec/graphql/queries/all_lists_spec.rb:1-36` is the spec to extend, tagged `type: :graphql`, uses `execute_graphql(query, variables: {...})` — variables camelized automatically by `spec/support/graphql_helpers.rb:7`.
- FactoryBot: `spec/factories/lists.rb:17-23` — `factory :list` defaults `status { "to_do" }`, override via `create(:list, status: 'done')`.
- `spec/requests/graphql_spec.rb` is transport-layer only (stubbed schema) — no changes needed there for this feature.

### Tidy
No unrelated tidy needed — files are minimal/clean. The cache-key fix is in-scope (blocker), not a tidy item.
