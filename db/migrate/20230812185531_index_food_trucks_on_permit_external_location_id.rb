class IndexFoodTrucksOnPermitExternalLocationId < ActiveRecord::Migration[7.0]
  def up
    remove_index :food_trucks, [:permit, :external_location_id], if_exists: true
    add_index :food_trucks, [:permit, :external_location_id], unique: true
  end

  def down
    remove_index :food_trucks, [:permit, :external_location_id], if_exists: true
  end
end
