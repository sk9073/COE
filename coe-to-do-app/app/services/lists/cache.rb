# frozen_string_literal: true

module Lists
  # Owns everything about how the "all lists" query is cached: the key format,
  # reads, and invalidation.
  #
  # Before this existed, the key string "all_lists/<status>" was built
  # independently in QueryType and in BaseMutation (Shotgun Surgery: change the
  # caching scheme, edit two unrelated files). This is now the ONLY class that
  # knows the key structure. The store is injected (defaulting to Rails.cache)
  # so callers depend on this abstraction rather than reaching into Rails.cache
  # directly (DIP), and tests can pass a fake store.
  class Cache
    NAMESPACE = "all_lists"
    EXPIRES_IN = 30.seconds

    def initialize(store: Rails.cache)
      @store = store
    end

    def fetch(status = nil, &block)
      @store.fetch(key_for(status), expires_in: EXPIRES_IN, &block)
    end

    def invalidate_all
      all_keys.each { |key| @store.delete(key) }
    end

    private

    def key_for(status)
      "#{NAMESPACE}/#{status.presence || 'all'}"
    end

    def all_keys
      [ key_for(nil) ] + ListStatus::ALL.map { |status| key_for(status) }
    end
  end
end
