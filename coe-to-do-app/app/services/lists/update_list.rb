# frozen_string_literal: true

module Lists
  # Command object: apply the provided attributes to an existing list and
  # invalidate the cached reads. Only the attributes actually supplied are
  # written, and the cache is only invalidated when something changed.
  #
  # Raises ActiveRecord::RecordNotFound when the id does not exist; the caller
  # translates that into its own not-found response.
  class UpdateList
    def initialize(cache: Cache.new)
      @cache = cache
    end

    def call(id:, **attributes)
      list = List.find(id)
      changes = attributes.compact
      return list if changes.empty?

      list.update!(changes)
      @cache.invalidate_all
      list
    end
  end
end
