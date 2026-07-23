# frozen_string_literal: true

module Types
  class ListStatusEnum < Types::BaseEnum
    # Derived from the domain so the enum can never drift from the model's
    # notion of a valid status.
    ListStatus::ALL.each do |status|
      value status, value: status
    end
  end
end
