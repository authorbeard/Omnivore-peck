require 'rails_helper'
include WebMock

RSpec.describe FoodTruckClient do
  let(:all_trucks_response) { file_fixture('all_trucks.json').read }
  let(:base_url) { Rails.application.credentials.dig(:truck_api, :url) }
  let(:default_req) do
    "#{base_url}?$select=objectid AS external_location_id,applicant,facilitytype,"\
    "cnn,locationdescription,address,permit,status,schedule,priorpermit,fooditems,"\
    "approved,received,expirationdate,longitude,latitude"
  end

  before do
    stub_request(:get, default_req).
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.example.com',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: all_trucks_response, headers: {})
  end

  it 'returns an array of truck objects in JSON' do
    truck = FoodTruckClient.get_all.first
debugger;
    expect(truck.class).to be(Hash)
    expect(truck['external_location_id']).to be_present
  end

  it 'selects only FoodTruck attrs by default' do
    allow(Net::HTTP).to receive(:get).and_call_original

    FoodTruckClient.get_all

    expect(Net::HTTP).to have_received(:get).with(URI.parse(default_req))
  end
end
