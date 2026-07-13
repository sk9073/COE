# spec/support/graphql_helpers.rb
module GraphqlHelpers
  def execute_graphql(query, variables: {}, context: {})
    # Use the actual class name in app/graphql/coe_to_do_app_schema.rb
    CoeToDoAppSchema.execute(
      query,
      variables: variables.deep_transform_keys { |key| key.to_s.camelize(:lower) },
      context: context
    ).as_json
  end
end

RSpec.configure do |config|
  config.include GraphqlHelpers, type: :graphql
end
