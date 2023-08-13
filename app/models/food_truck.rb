class FoodTruck < ApplicationRecord
  validates :permit, uniqueness: { scope: :external_location_id }

  scope :active, -> {
    where(status: 'APPROVED')
    .where.not('expirationdate < ?', DateTime.now)
  }
  scope :newest_ten, -> { active.order(approved: :desc).limit(10) }
end
