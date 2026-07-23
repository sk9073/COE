# frozen_string_literal: true

module Lists
  # Command object: persist a new list and invalidate the cached reads.
  #
  # It COMPOSES a Lists::Cache collaborator (injected, with a sensible default)
  # rather than inheriting cache behaviour from a base class. Business logic
  # lives here, not in the GraphQL mutation, so it can be reused and unit-tested
  # without the GraphQL layer. It raises ActiveRecord errors straight through;
  # translating them into a transport-specific shape is the caller's job.
  class CreateList
    def initialize(cache: Cache.new)
      @cache = cache
    end

    def call(title:, description:, status:)
      list = List.create!(title: title, description: description, status: status)
      @cache.invalidate_all
      list
    end
  end
end
