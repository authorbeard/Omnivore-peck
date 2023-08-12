require 'net/http'

class FoodTruckClient
  BASE_ENDPOINT_URL = Rails.application.credentials.dig(:truck_api, :url).freeze

  class << self
    def get_all
      JSON.parse(Net::HTTP.get(base_uri))
    end

    def base_uri
      @base_uri ||= URI.parse(BASE_ENDPOINT_URL)
    end
  end
end
