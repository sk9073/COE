# frozen_string_literal: true

module Lists
  # Command object: destroy an existing list and invalidate the cached reads.
  #
  # Raises ActiveRecord::RecordNotFound when the id does not exist; the caller
  # translates that into its own not-found response.
  class DeleteList
    def initialize(cache: Cache.new)
      @cache = cache
    end

    def call(id:)
      list = List.find(id)
      list.destroy!
      @cache.invalidate_all
      list
    end
  end
end
