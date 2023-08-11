class FoodTruck < ApplicationRecord
  validates_uniqueness_of :objectid

  scope :active, -> {
    where(status: 'APPROVED')
    .where.not('expirationdate < ?', DateTime.now)
  }
end
