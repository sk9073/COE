# Day 10 — OOP Principles: Refactoring the COE To-Do App

Applying the ideas from [`sandimetz-talks-summary.md`](./sandimetz-talks-summary.md) to the
`coe-to-do-app` Rails 8.1 GraphQL backend.

**Goal competencies:** identify code smells, apply SOLID, refactor a Rails model with OOP,
extract service objects, and prefer composition over inheritance.

**Constraint:** every step kept the RSpec suite green (35 → 50 examples, 97.4% line coverage;
no new rubocop or brakeman warnings).

---

## 1. Code smells identified (mapped to Sandi's 5 categories)

| Smell | Category | Location (before) | Evidence |
|---|---|---|---|
| Duplicated cache-key format `"all_lists/<status>"` | Change Preventer — *Shotgun Surgery* | `query_type.rb` + `base_mutation.rb` | Two unrelated files built the same key independently; changing the caching scheme meant editing both |
| Reaching into `Rails.cache` from many places | Coupler — *Inappropriate Intimacy* | `QueryType`, `BaseMutation` | Query and every mutation knew the raw cache API and the key layout |
| Identical `rescue RecordInvalid / RecordNotUnique` blocks | Change Preventer — *Shotgun Surgery* | `create_list.rb`, `update_list.rb` | A new error mapping meant editing every mutation |
| Cache behaviour shared *down* the inheritance tree | Tool Abuser — *inheritance used for code-sharing* | `BaseMutation#invalidate_all_lists_cache` | Sandi #11: inheritance is for specialization, not code reuse. `DeleteList` (and any future non-caching mutation) inherits cache code it may not want |
| `%w[to_do in_progress done blocked]` literal + mirrored in the enum | Bloater — *Primitive Obsession* + duplicated truth | `list.rb`, `list_status_enum.rb` | Adding a status touched ≥2 files; status was a bare string with no behaviour |
| Anemic model (validations only) | Dispensable — *Data Class* | `list.rb` | No domain behaviour lived with the data |
| `resolve` mixing persistence + caching + error formatting | Change Preventer — *Divergent Change* | each mutation | Three unrelated reasons to change one method |

> **Deliberately *not* acted on — the "anemic model".** A thin ActiveRecord model is only a
> Data Class smell once behaviour wants to live with the data. Right now none does, so adding
> methods to `List` would be Speculative Generality (see §3.1). Left as-is on purpose; revisit
> when a real behaviour appears.

---

## 2. What changed

### New structure
```
app/domain/list_status.rb                    # value object: single source of truth for statuses
app/services/lists/cache.rb                  # owns cache keys + read/invalidate (injectable store)
app/services/lists/create_list.rb            # command objects composing an injected Lists::Cache
app/services/lists/update_list.rb
app/services/lists/delete_list.rb
app/graphql/mutations/error_translation.rb   # shared AR -> GraphQL error mapping (mixin)
```

---

## 3. Refactoring, principle by principle

### 3.1 Refactor the model with OOP — extract the status concept

The status was a primitive string, and its set of valid values was duplicated between the
model and the GraphQL enum.

**Before**
```ruby
# app/models/list.rb
class List < ApplicationRecord
  validates :status, inclusion: { in: %w[to_do in_progress done blocked], message: "%{value} is not a valid status" }
  validates :title, uniqueness: true
end

# app/graphql/types/list_status_enum.rb
class ListStatusEnum < Types::BaseEnum
  value "to_do", value: "to_do"
  value "in_progress", value: "in_progress"
  value "done", value: "done"
  value "blocked", value: "blocked"
end
```

**After**
```ruby
# app/domain/list_status.rb — the ONLY place the status set is declared
module ListStatus
  ALL = %w[to_do in_progress done blocked].freeze
end

# app/models/list.rb — validates against the shared source of truth
class List < ApplicationRecord
  validates :status, inclusion: { in: ListStatus::ALL, message: "%{value} is not a valid status" }
  validates :title, uniqueness: true
end

# app/graphql/types/list_status_enum.rb — derived, can never drift
class ListStatusEnum < Types::BaseEnum
  ListStatus::ALL.each { |status| value status, value: status }
end
```

**Kills:** Primitive Obsession, duplicated truth.
**Wins:** OCP — adding a status is now a one-line change in `ListStatus::ALL`; the model
validation, the enum, and `Lists::Cache` all derive from it.

### 3.2 SOLID + composition — `Lists::Cache` with dependency injection

The cache key string was built independently in two places, and both reached straight into
`Rails.cache`.

**Before**
```ruby
# query_type.rb
Rails.cache.fetch("all_lists/#{status || 'all'}", expires_in: 30.seconds) { ... }

# base_mutation.rb (shared via inheritance)
def invalidate_all_lists_cache
  ([ "all_lists/all" ] + Types::ListStatusEnum.values.keys.map { |s| "all_lists/#{s}" })
    .each { |key| Rails.cache.delete(key) }
end
```

**After**
```ruby
# app/services/lists/cache.rb — the ONLY class that knows the key layout
module Lists
  class Cache
    NAMESPACE  = "all_lists"
    EXPIRES_IN = 30.seconds

    def initialize(store: Rails.cache)   # dependency injection with a sensible default
      @store = store
    end

    def fetch(status = nil, &block)
      @store.fetch(key_for(status), expires_in: EXPIRES_IN, &block)
    end

    def invalidate_all
      all_keys.each { |key| @store.delete(key) }
    end

    private

    def key_for(status) = "#{NAMESPACE}/#{status.presence || 'all'}"
    def all_keys = [ key_for(nil) ] + ListStatus::ALL.map { |s| key_for(s) }
  end
end
```

**Kills:** Shotgun Surgery on cache keys, Inappropriate Intimacy with `Rails.cache`.
**Wins:**
- **SRP** — one class owns the caching concern.
- **DIP** — callers depend on the `Lists::Cache` abstraction; the store is injected, so tests
  pass a fake and never touch a real backend.

### 3.3 Extract service objects — `Lists::CreateList / UpdateList / DeleteList`

Each mutation did the AR call, cache invalidation, and error translation inline.

**Before**
```ruby
# app/graphql/mutations/create_list.rb
def resolve(title: nil, description: nil, status: nil)
  list = List.create!(title: title, description: description, status: status)
  invalidate_all_lists_cache
  list
rescue ActiveRecord::RecordInvalid => e
  raise GraphQL::ExecutionError.new(e.record.errors.full_messages.join(", "))
rescue ActiveRecord::RecordNotUnique
  raise GraphQL::ExecutionError.new("Title has already been taken")
end
```

**After**
```ruby
# app/services/lists/create_list.rb — business logic, no GraphQL knowledge
module Lists
  class CreateList
    def initialize(cache: Cache.new)   # composes an injected collaborator
      @cache = cache
    end

    def call(title:, description:, status:)
      list = List.create!(title: title, description: description, status: status)
      @cache.invalidate_all
      list
    end
  end
end

# app/graphql/mutations/create_list.rb — thin adapter
class CreateList < BaseMutation
  include ErrorTranslation

  def resolve(title:, description:, status:)
    translate_errors do
      Lists::CreateList.new.call(title: title, description: description, status: status)
    end
  end
end
```

**Appropriately** — one command per operation, each with a single reason to change. I
deliberately did **not** build a generic `BaseService` / `Result`-monad framework: with three
commands, duplication is cheaper than the wrong abstraction (Sandi #10 — *"duplication is far
cheaper than the wrong abstraction"*).

### 3.4 Composition over inheritance — two moves

**Move 1 — cache behaviour.** `BaseMutation#invalidate_all_lists_cache` was the textbook smell:
sharing code through inheritance. It is gone. Command objects now **compose** a `Lists::Cache`
collaborator injected through the initializer — Sandi's "isolate the role and inject it"
(summary #11).

**Move 2 — error translation.** The duplicated rescue blocks became a `Mutations::ErrorTranslation`
module, **mixed in** only where a mutation needs it, rather than pushed onto every subclass via
the base class.

```ruby
# app/graphql/mutations/error_translation.rb
module Mutations
  module ErrorTranslation
    private
    def translate_errors
      yield
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "List not found"
    rescue ActiveRecord::RecordInvalid => e
      raise GraphQL::ExecutionError, e.record.errors.full_messages.join(", ")
    rescue ActiveRecord::RecordNotUnique
      raise GraphQL::ExecutionError, "Title has already been taken"
    end
  end
end
```

`BaseMutation` is now just framework configuration — no shared behaviour leaking downward.

---

## 4. Applying the Green Refactor Checklist (summary #5)

For each extracted class:

- **Is it DRY?** Cache keys and the status set each live in exactly one place now.
- **One responsibility?** `ListStatus` = status meaning; `Lists::Cache` = caching;
  each command = one write; each mutation = transport adapter.
- **Does everything change at the same rate?** Yes — caching changes don't touch mutations;
  status changes don't touch the enum; error mappings live in one module.
- **Depends on things that change less often?** Commands depend on the stable `Lists::Cache`
  abstraction, not the volatile `Rails.cache` key strings.

---

## 5. Testing approach (summary #9 — the unit testing grid)

New unit specs assert **outgoing command messages at the nearest boundary** using injected
fakes/spies, rather than asserting distant side effects:

```ruby
# spec/services/lists/create_list_spec.rb
let(:cache) { instance_double(Lists::Cache, invalidate_all: nil) }

it 'invalidates the cached reads after creating' do
  expect(cache).to receive(:invalidate_all)              # verify the message was sent
  described_class.new(cache: cache).call(title: '...', description: '...', status: 'to_do')
end
```

Injecting the cache is what makes this possible — a direct benefit of dependency injection.

---

## 6. Result

| Check | Before | After |
|---|---|---|
| RSpec examples | 35 | 50 (all green) |
| Line coverage | 96.15% | 97.39% |
| Rubocop offenses | 0 | 0 |
| New brakeman/audit warnings | — | 0 (only pre-existing Ruby-EOL / gem advisories remain) |

**Files a "new status" now touches:** 1 (`ListStatus::ALL`) — was 2.
**Files a "cache strategy change" now touches:** 1 (`Lists::Cache`) — was 2.
**Files a "new AR error mapping" now touches:** 1 (`ErrorTranslation`) — was 2.
