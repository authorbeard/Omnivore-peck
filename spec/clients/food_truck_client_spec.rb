require 'rails_helper'

RSpec.describe FoodTruckClient do
  let(:base_url) { Rails.application.credentials.dig(:truck_api, :url) }
  let(:all_trucks_response) { JSON.parse(file_fixture('all_trucks.json').read) }

  before do
    stub_request(:get, base_url).
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.example.com',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "", headers: {})
  end

  it 'requests JSON data from the endpoint' do
binding.break
    resp = FoodTruckClient.get_all

    expect(JSON.parse(resp)).not_to raise_error
  end
end
