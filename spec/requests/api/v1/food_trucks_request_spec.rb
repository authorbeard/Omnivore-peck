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
      expired = create(:food_truck, :expired)
      not_yet_active = create(:food_truck, :inactive)
      expired_marked_active = create(:food_truck, :active, expirationdate: 1.month.ago )

      get api_v1_food_trucks_path, params: { filters: 'active' }
      data = JSON.parse(response.body)['data']
      statuses = data.map { |t| t['status'] }.uniq

      expect(data).not_to include(expired_marked_active)
      expect(data).to match_array([expired, not_yet_active])
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
