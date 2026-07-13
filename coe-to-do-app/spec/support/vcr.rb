# spec/support/vcr.rb
require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  # Where the recorded YAML files will live
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  # Hook into webmock to intercept HTTP requests
  config.hook_into :webmock
  # Crucial: Disables real HTTP connections if a cassette isn't present,
  # preventing unexpected external calls.
  config.configure_rspec_metadata!
end
