class IndexFoodTrucksOnPermit < ActiveRecord::Migration[7.0]
  def up
    remove_index :food_trucks, :permit, if_exists: true
    add_index :food_trucks, :permit, unique: true
  end

  def down
    remove_index :food_trucks, :permit, if_exists: true
  end
end
