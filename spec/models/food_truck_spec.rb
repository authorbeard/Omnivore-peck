require 'rails_helper'

RSpec.describe FoodTruck do

  describe 'validations' do
    it 'validates the uniqueness of objectid' do
      truck1 = create(:food_truck)
      truck2 = build(:food_truck, objectid: truck1.objectid)

      expect(truck2).not_to be_valid
    end

  end
end
