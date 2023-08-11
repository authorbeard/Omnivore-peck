class FoodTruck < ApplicationRecord
  validates_uniqueness_of :objectid
end
