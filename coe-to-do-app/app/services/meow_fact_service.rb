# app/services/meow_fact_service.rb
require "net/http"
require "json"

class MeowFactService
  URL = "https://meowfacts.herokuapp.com/"

  def self.fetch_fact
    uri = URI(URL)
    response = Net::HTTP.get(uri)
    parsed = JSON.parse(response)

    # The API returns an array wrapped in a 'data' key: { "data": ["Cat fact..."] }
    parsed["data"]&.first
  rescue StandardError => e
    "Could not fetch fact: #{e.message}"
  end
end
