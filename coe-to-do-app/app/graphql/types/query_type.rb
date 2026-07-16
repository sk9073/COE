# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :all_lists, [ Types::ListType ], null: false

    def all_lists
      Rails.cache.fetch("all_lists", expires_in: 30.seconds) { List.all.to_a }
    end
  end
end
