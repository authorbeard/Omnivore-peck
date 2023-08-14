require 'net/http'

class FoodTruckClient
  BASE_ENDPOINT_URL = 'https://data.sfgov.org/resource/rqzj-sfat.json'.freeze
  DEFAULT_SELECTS = "objectid AS external_location_id,applicant,facilitytype,cnn,"\
      "locationdescription,address,permit,status,schedule,priorpermit,fooditems,approved,received,"\
      "expirationdate,longitude,latitude".freeze
  class << self
    def get_all
      JSON.parse(Net::HTTP.get(base_uri))
    end

    private

    def base_uri
      url = "#{BASE_ENDPOINT_URL}?$select=#{DEFAULT_SELECTS}"
      @base_uri ||= URI.parse(url)
    end
  end
end
