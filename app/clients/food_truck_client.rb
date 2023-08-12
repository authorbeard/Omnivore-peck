require 'net/http'

class FoodTruckClient
  BASE_ENDPOINT_URL = Rails.application.credentials.dig(:truck_api, :url).freeze

  def self.get_all
    JSON.parse(Net::HTTP.get(base_uri))
  end

  def self.get_since(date: Time.zone.now - 1.day)
    url_string = "#{BASE_ENDPOINT_URL}?$where=:updated_at > '2023-05-04'"
    uri = URI.parse(url_string)
    uri.query = URI.encode_www_form()
    JSON.parse(Net::HTTP.get_response(uri))
  end

  def self.base_uri
    @base_uri ||= URI.parse(BASE_ENDPOINT_URL)
  end
end
