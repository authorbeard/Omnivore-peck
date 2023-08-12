class FoodTruck < ApplicationRecord
  validates_uniqueness_of :permit

  scope :active, -> {
    where(status: 'APPROVED')
    .where.not('expirationdate < ?', DateTime.now)
  }
end
