require 'rails_helper'

RSpec.describe FoodTruck do
  before do
    create_list(:food_truck, 25, :active)
    create_list(:food_truck, 5, :inactive)
    create_list(:food_truck, 10, :expired)
  end

  describe 'validations' do
    it 'validates the uniqueness of the permit, scoped to external_location_id' do
      truck1 = create(:food_truck)
      truck2 = build(:food_truck, permit: truck1.permit)

      expect(truck2).to be_valid
      truck2.external_location_id = truck1.external_location_id
      expect(truck2).not_to be_valid
    end
  end

  describe '.query' do
    it 'returns the 10 most recently approved trucks if no terms are given' do
      new_10 = FoodTruck.newest_ten
      results = FoodTruck.query

      expect(results).to match_array(new_10)
      expect(results.all? { |t| t.active? }).to be true
    end

    it 'applies filters if any are given' do
      pending = FoodTruck.pending
      expired = FoodTruck.expired
      results = FoodTruck.query(filters: 'pending')

      expect(results).to match_array(pending)
      expect(results).not_to match_array(expired)
    end

    it 'applies multiple filters in the order they are given' do
      expired, pending, active = FoodTruck.expired.first, FoodTruck.pending.first, FoodTruck.active.first
      [expired, pending, active].each { |t| t.update(fooditems: 'vegetarian') }
      active_veg = active.reload
      expired_veg = expired.reload
      pending_veg = pending.reload

      results = FoodTruck.query(filters: 'pending,vegetarian')
      expect(results).to include(pending_veg)
      expect(results).not_to include(active_veg, expired_veg)
    end

    it 'searches truck food items for query terms if included' do
      sushi_truck = create(:food_truck, :sushi)
      veggie_truck = create(:food_truck, :veggies)
      qterm = sushi_truck.fooditems.split(' ').last

      results = FoodTruck.query(q: qterm)
      expect(results).to include(sushi_truck)
      expect(results).not_to include(veggie_truck)
    end

    it 'looks for matches of all query terms' do
      sushi_truck = create(:food_truck, :sushi)
      veggie_truck = create(:food_truck, :veggies)
      first_sushi = sushi_truck.fooditems.split(' ').first
      first_veg = veggie_truck.fooditems.split(' ').first
      both_truck = create(:food_truck, fooditems: "#{sushi_truck.fooditems} #{veggie_truck.fooditems}")
      qterm = "#{first_veg},#{first_sushi}"

      results = FoodTruck.query(q: qterm)
      expect(results).to include(both_truck)
      expect(results).not_to include(sushi_truck)
      expect(results).not_to include(veggie_truck)
    end

    it 'applies filters before querying if both are supplied' do
      expired = FoodTruck.expired.first
      active = FoodTruck.active.first
      active.update(fooditems: expired.fooditems)
      qterm = expired.fooditems.split(' ').first

      results = FoodTruck.query({filters: 'active', q: qterm})
      expect(results).not_to include(expired)
      expect(results).to include(active)
    end

    it 'only returns a random truck if that is included in filters' do
      allow(FoodTruck).to receive(:chain_filters).and_call_original
      allow(FoodTruck).to receive(:search).and_call_original
      allow(FoodTruck).to receive(:random).and_call_original

      FoodTruck.query({filters: 'active,random', q: 'whatever'})
      # .random is recursive; it keeps calling until it gets a result,
      # so need to adjust expectations accordingly here.
      expect(FoodTruck).to have_received(:random).at_least(:once)
      expect(FoodTruck).not_to have_received(:chain_filters)
      expect(FoodTruck).not_to have_received(:search)
    end

    it 'returns a single-item array when random is requested' do
      rando = FoodTruck.random

      expect(rando.class).to eq(Array)
    end
  end

  describe '.random' do
    it 'never returns an empty result' do
      results = []
      100.times { results << 'nope' unless FoodTruck.random.presence }

      expect(results).to be_empty
    end

    it 'returns an unpredictable result, even if not a truly random one' do
      first_passes = []
      5.times { first_passes << FoodTruck.random }

      second_passes = []
      5.times { second_passes << FoodTruck.random }

      expect(first_passes).not_to match_array(second_passes)
    end
  end
end
