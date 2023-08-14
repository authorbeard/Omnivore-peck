class FoodTruck < ApplicationRecord
  validates :permit, uniqueness: { scope: :external_location_id }

  scope :active, ->{
    where(status: 'APPROVED')
    .where.not('expirationdate < ?', DateTime.now)
  }
  scope :expired, ->{
    where(status: 'EXPIRED')
    .or(where('expirationdate < ?', DateTime.now))
  }
  scope :suspended, ->{
    where(status: 'SUSPEND')
  }
  scope :pending, ->{
    where(status: 'REQUESTED')
  }
  scope :inactive, ->{
    where.not(status: 'APPROVED')
    .or(where('expirationdate < ?', DateTime.now))
  }
  scope :newest_ten, ->{ active.order(approved: :desc).limit(10) }
  scope :search, ->(keyword_array) {
    likes = keyword_array.map { |w| "fooditems ilike '%#{w}%'" }.join(' AND ')
    where(likes)
  }

  ## temporary scope for use in testing filter chaining
  scope :vegetarian, ->{
    search(['vegetarian'])
  }

  class << self
    def query(opts={})
      return newest_ten if opts.empty?
      return random if opts[:filters]&.include?('random')

      trucks = chain_filters(opts[:filters] || '', all)
      trucks = opts[:q] ? trucks.search(opts[:q].split(',')) : trucks
    end

    def chain_filters(filters, target = active)
      return target if filters.empty?
      filters.split(',').inject(target, &:public_send)
    end

    def random
      # This can go into an infinite loop if there are no trucks.
      # Not putting in a guard clause for that, because this app should
      # never run without data; if it is, that's a much larger problem
      # and this method shouldn't have to account for that possibility
      r = find_by_sql('select * from food_trucks tablesample system(10) limit 1')
      r.presence ? r : random
    end
  end

  def active?
    # consider replacing with enum methods
    status == 'APPROVED' && expirationdate.future?
  end
end
