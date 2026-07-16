# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :all_lists, [ Types::ListType ], null: false do
      argument :status, Types::ListStatusEnum, required: false
    end

    def all_lists(status: nil)
      Rails.cache.fetch(all_lists_cache_key(status), expires_in: 30.seconds) do
        status.present? ? List.where(status: status).to_a : List.all.to_a
      end
    end

    private

    def all_lists_cache_key(status)
      "all_lists/#{status || 'all'}"
    end
  end
end
