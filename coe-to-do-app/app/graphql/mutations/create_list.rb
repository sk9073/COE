module Mutations
  class CreateList < BaseMutation
    include ErrorTranslation

    # arguments passed to the `resolve` method
    argument :title, String, required: true
    argument :description, String, required: true
    argument :status, Types::ListStatusEnum, required: true

    # return type from the mutation
    type Types::ListType

    def resolve(title:, description:, status:)
      translate_errors do
        Lists::CreateList.new.call(title: title, description: description, status: status)
      end
    end
  end
end
