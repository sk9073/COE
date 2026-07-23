module Mutations
  class DeleteList < BaseMutation
    include ErrorTranslation

    # arguments passed to the `resolve` method
    argument :id, ID, required: true

    # return type from the mutation
    type Types::ListType

    def resolve(id:)
      translate_errors do
        Lists::DeleteList.new.call(id: id)
      end
    end
  end
end
