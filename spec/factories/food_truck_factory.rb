FactoryBot.define do
  factory :food_truck do
    external_location_id { Faker::Alphanumeric.alphanumeric(number: 7) }
    permit { Faker::Alphanumeric.alphanumeric(number: 7) }
    approved { DateTime.now }
    fooditems { Faker::Food.description }
    ## commenting out the other Food Truck attrs to save time; can
    ## uncomment and define as needed.
    # applicant
    # facilitytype
    # cnn
    # locationdescription
    # address
    # blocklot
    # block
    # lot
    # permit
    # status
    # schedule
    # received
    # priorpermit
    # expirationdate
    # latitude
    # longiude
    # x_coord
    # y_coord

    trait :active do
      status { 'APPROVED' }
      expirationdate { 1.year.from_now }
    end

    trait :expired do
      status { 'EXPIRED' }
      expirationdate { 1.month.ago }
    end

    trait :inactive do
      status { 'REQUESTED' }
    end

    trait :feature_dish do
      fooditems { Faker::Food.dish }
    end

    trait :sushi do
      sushi_types = []
      5.times { sushi_types << Faker::Food.sushi }

      fooditems { sushi_types.join(' ') }
    end

    trait :veggies do
      veggie_types = []
      5.times { veggie_types << Faker::Food.vegetables }

      fooditems { veggie_types.join(' ') }
    end
  end
end
