# frozen_string_literal: true

module Mutations
  # Translates the ActiveRecord failures raised by the Lists command objects
  # into GraphQL::ExecutionErrors. Previously each mutation carried its own
  # identical rescue blocks (Shotgun Surgery: a new error mapping meant editing
  # every mutation). Mixed in via composition where a mutation needs it, rather
  # than pushed onto every subclass through BaseMutation.
  module ErrorTranslation
    private

    def translate_errors
      yield
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "List not found"
    rescue ActiveRecord::RecordInvalid => e
      raise GraphQL::ExecutionError, e.record.errors.full_messages.join(", ")
    rescue ActiveRecord::RecordNotUnique
      raise GraphQL::ExecutionError, "Title has already been taken"
    end
  end
end
