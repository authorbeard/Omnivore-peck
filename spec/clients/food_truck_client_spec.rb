require 'rails_helper'
include WebMock

RSpec.describe FoodTruckClient do
  let(:base_url) { Rails.application.credentials.dig(:truck_api, :url) }
  let(:all_trucks_response) { file_fixture('all_trucks.json').read }

  before do
    stub_request(:get, base_url).
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.example.com',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: all_trucks_response, headers: {})
  end

  it 'gets all food truck data, in JSON, from the endpoint' do
    resp = FoodTruckClient.get_all
    truck = resp.first

    expect(truck['objectid']).not_to be_nil
  end
end
