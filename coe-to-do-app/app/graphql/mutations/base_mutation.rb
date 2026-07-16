# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    private

    def invalidate_all_lists_cache
      all_lists_cache_keys.each { |key| Rails.cache.delete(key) }
    end

    def all_lists_cache_keys
      [ "all_lists/all" ] + Types::ListStatusEnum.values.keys.map { |status| "all_lists/#{status}" }
    end
  end
end
