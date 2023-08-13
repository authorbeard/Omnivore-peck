require 'rails_helper'

RSpec.describe "Food Truck Queries" do
  before do
    active = JSON.parse(file_fixture('active_trucks.json').read)
    active.each { |t| create(:food_truck, t) }
  end

  describe 'default request' do
    it 'returns the 10 most recently approved trucks by default' do
      newest = FoodTruck.order(approved: :desc).limit(10)
      oldest = FoodTruck.order(:approved).first.to_json

      get api_v1_food_trucks_path

      data = JSON.parse(response.body)['data']

      expect(data).to match_array(newest.as_json)
      expect(data).not_to include(oldest)
    end
  end

  describe 'requests with filters' do
    it 'returns inactive trucks when that filter is requested' do

    end

    it 'returns a random truck when that filte is included' do

    end
  end

  describe 'requests with queries' do
    it 'returns trucks whose food items, titles or descriptions include the query' do

    end

    it 'applies filters first before the query when both are present' do

    end
  end
end
