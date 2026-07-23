module Mutations
  class UpdateList < BaseMutation
    include ErrorTranslation

    # arguments passed to the `resolve` method
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :status, Types::ListStatusEnum, required: false

    # return type from the mutation
    type Types::ListType

    def resolve(id:, title: nil, description: nil, status: nil)
      translate_errors do
        Lists::UpdateList.new.call(id: id, title: title, description: description, status: status)
      end
    end
  end
end
