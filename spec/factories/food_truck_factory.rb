FactoryBot.define do
  factory :food_truck do
    objectid { Faker::Alphanumeric.alphanumeric(number: 7) }
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
    # approved
    # received
    # priorpermit
    # expirationdate
    # fooditems
    # latitude
    # longiude
    # x_coord
    # y_coord
  end
end
