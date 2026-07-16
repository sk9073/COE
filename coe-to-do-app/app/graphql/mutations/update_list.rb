module Mutations
  class UpdateList < BaseMutation
    # arguments passed to the `resolve` method
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :status, Types::ListStatusEnum, required: false

    # return type from the mutation
    type Types::ListType

    def resolve(id: nil, title: nil, description: nil, status: nil)
      list = List.find_by(id: id)
      if list
        attributes = { title: title, description: description, status: status }.compact
        list.update!(attributes) unless attributes.empty?
        invalidate_all_lists_cache unless attributes.empty?
        list
      else
        raise GraphQL::ExecutionError.new("List not found")
      end
    rescue ActiveRecord::RecordInvalid => e
      raise GraphQL::ExecutionError.new(e.record.errors.full_messages.join(", "))
    rescue ActiveRecord::RecordNotUnique
      raise GraphQL::ExecutionError.new("Title has already been taken")
    end
  end
end
