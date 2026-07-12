# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_list, null: false, mutation: Mutations::CreateList
    field :delete_list, null: false, mutation: Mutations::DeleteList
    field :update_list, null: false, mutation: Mutations::UpdateList
  end
end
