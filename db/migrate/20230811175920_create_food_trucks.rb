class CreateFoodTrucks < ActiveRecord::Migration[7.0]
  def change
    create_table :food_trucks do |t|
      %i[external_location_id applicant facilitytype cnn locationdescription address permit status schedule priorpermit fooditems].each do |attr|
          t.string attr
        end
      t.datetime :approved
      t.datetime :received
      t.datetime :expirationdate
      t.float :longitude
      t.float :latitude
      t.timestamps
    end
  end
end
