require 'rails_helper'

RSpec.describe "Food Truck Queries" do
  before do
    active = JSON.parse(file_fixture('active_trucks.json').read)
    active.each { |t| create(:food_truck, t) }
  end

  it 'returns the 10 most recently approved trucks by default' do
    newest = FoodTruck.order(approved: :desc).limit(10)
    oldest = FoodTruck.order(:approved).first.to_json

    get api_v1_food_trucks_path

    data = JSON.parse(response.body)['data']

    expect(data).to match_array(newest.as_json)
    expect(data).not_to include(oldest)
  end

  it 'queries FoodTrucks using query params' do
    allow(FoodTruck).to receive(:query).and_call_original
    search_params = {filters: 'active', q: 'querystring'}
    get api_v1_food_trucks_path, params: search_params

    expect(FoodTruck)
      .to have_received(:query)
      .with(ActionController::Parameters.new(search_params).permit!)
  end
end
