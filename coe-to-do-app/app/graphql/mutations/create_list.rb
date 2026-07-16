module Mutations
  class CreateList < BaseMutation
    # arguments passed to the `resolve` method
    argument :title, String, required: true
    argument :description, String, required: true
    argument :status, Types::ListStatusEnum, required: true

    # return type from the mutation
    type Types::ListType

    def resolve(title: nil, description: nil, status: nil)
      list = List.create!(
        title: title,
        description: description,
        status: status,
      )
      Rails.cache.delete("all_lists")
      list
    rescue ActiveRecord::RecordInvalid => e
      raise GraphQL::ExecutionError.new(e.record.errors.full_messages.join(", "))
    rescue ActiveRecord::RecordNotUnique
      raise GraphQL::ExecutionError.new("Title has already been taken")
    end
  end
end
