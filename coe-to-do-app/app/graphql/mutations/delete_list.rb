module Mutations
  class DeleteList < BaseMutation
    # arguments passed to the `resolve` method
    argument :id, ID, required: true

    # return type from the mutation
    type Types::ListType

    def resolve(id: nil)
      list = List.find_by(id: id)
      if list
        list.destroy!
      else
        raise GraphQL::ExecutionError.new("List not found")
      end
    end
  end
end
