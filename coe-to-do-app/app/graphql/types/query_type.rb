# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :all_lists, [ Types::ListType ], null: false

    def all_lists
      List.all
    end
  end
end
