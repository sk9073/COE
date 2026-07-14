# lib/tasks/graphql.rake
require "graphql/rake_task"

# Replace 'AppSchema' with the actual class name configured in app/graphql/
GraphQL::RakeTask.new(
  schema_name: "CoeToDoAppSchema", 
  directory: "./config/graphql", # Or direct to your FE directory if mono-repo
  idl_outfile: "schema.graphql"
)