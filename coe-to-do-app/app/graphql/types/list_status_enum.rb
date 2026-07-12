# frozen_string_literal: true

module Types
  class ListStatusEnum < Types::BaseEnum
    value "to_do", value: "to_do"
    value "in_progress", value: "in_progress"
    value "done", value: "done"
    value "blocked", value: "blocked"
  end
end
