# spec/services/meow_fact_service_spec.rb
require 'rails_helper'

RSpec.describe MeowFactService do
  describe '.fetch_fact' do
    it 'fetches a cat fact from the API' do
      # We give the recorded file a descriptive name
      VCR.use_cassette('meow_facts/random_fact') do
        fact = MeowFactService.fetch_fact

        expect(fact).to be_a(String)
        expect(fact).not_to be_empty
      end
    end

    it 'returns an error message if the API call fails' do
      # This forces the HTTP request to fail (e.g., by disconnecting the internet)
      # VCR will still record the failure (called a "failed cassette")
      VCR.use_cassette('meow_facts/failed_fetch') do
        allow(Net::HTTP).to receive(:get).and_raise(Errno::ECONNREFUSED)

        fact = MeowFactService.fetch_fact

        # We expect the service to handle the error gracefully and return a message
        expect(fact).to include('Could not fetch fact')
      end
    end
  end
end
