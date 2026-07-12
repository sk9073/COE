# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_list, null: false, mutation: Mutations::CreateList
  end
end
