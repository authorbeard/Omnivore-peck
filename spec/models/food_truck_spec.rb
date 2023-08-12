require 'rails_helper'

RSpec.describe FoodTruck do

  describe 'validations' do
    it 'validates the uniqueness of the permit, scoped to external_location_id' do
      truck1 = create(:food_truck)
      truck2 = build(:food_truck, permit: truck1.permit)

      expect(truck2).to be_valid
      truck2.external_location_id = truck1.external_location_id
      expect(truck2).not_to be_valid
    end
  end
end
