class CreateFoodTrucks < ActiveRecord::Migration[7.0]
  def change
    create_table :food_trucks do |t|
      %i[objectid applicatn facilitytype cnn locationdescription address blocklot block lot permit status schedule approved received priorpermit expirtiondate].each do |attr|
          t.string attr
        end


      t.timestamps
    end
  end
end
