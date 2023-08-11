class CreateFoodTrucks < ActiveRecord::Migration[7.0]
  def change
    create_table :food_trucks do |t|
      %i[objectid applicant facilitytype cnn locationdescription address blocklot block lot permit status schedule approved received priorpermit expirationdate fooditems].each do |attr|
          t.string attr
        end
      t.float :longitude
      t.float :latitude
      t.float :x_coord
      t.float :y_coord
      t.timestamps
    end
  end
end
