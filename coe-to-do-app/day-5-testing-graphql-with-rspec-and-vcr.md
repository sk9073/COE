### Notes 

To test the logic of the ToDo app following were done

1. rspec-rails , factory_bot_rails , simplecov gem were installed
2. factory_bot_rails helps preventing DRY Code while creating objects for test cases
3. simplecov helps with code coverage
    1. This app has code coverage of 95%
    2. Run `bundle exec rspec`
4. GraphQL testing
    1. The integration specs for schema are tested on `coe-to-do-app\spec\graphql`

### VCR Gem

#### Benefits 

While traditional stubbing (like using RSpec’s allow(Service).to receive(:call)) definitely has its place, it comes with a major blind spot: you are testing your own assumptions, not the actual API.

If the external API changes its response payload tomorrow, your traditional stubs will keep passing happily in CI, while your production app breaks.

VCR gives you the best of both worlds—the speed of a local stub with the realism of an integration test

This app experiment to test VCR gem

#### How to test 

1. Run `bundle exec rspec spec/services/meow_fact_service_spec.rb`