class IndexFoodTrucksOnObjectId < ActiveRecord::Migration[7.0]
  def up
    remove_index :food_trucks, :objectid, if_exists: true
    add_index :food_trucks, :objectid, unique: true
  end

  def down
    remove_index :food_trucks, :objectid, if_exists: true
  end
end
