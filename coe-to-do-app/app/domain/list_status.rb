# frozen_string_literal: true

# Single source of truth for the set of valid list statuses.
#
# Before this existed, the literal %w[to_do in_progress done blocked] was
# duplicated across the model and the GraphQL enum (Primitive Obsession +
# duplicated truth). The model validation, the GraphQL enum, and Lists::Cache
# all derive from ListStatus::ALL, so adding a status is a one-line change here.
module ListStatus
  ALL = %w[to_do in_progress done blocked].freeze
end
