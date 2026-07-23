# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :all_lists, [ Types::ListType ], null: false do
      argument :status, Types::ListStatusEnum, required: false
    end

    def all_lists(status: nil)
      lists_cache.fetch(status) do
        scope = status.present? ? List.where(status: status) : List.all
        scope.to_a
      end
    end

    private

    def lists_cache
      Lists::Cache.new
    end
  end
end
