class TruckImporter
  TRUCK_ATTRS = FoodTruck.attribute_names.freeze
  attr_accessor :raw_resp, :trucks

  def self.perform
    new.tap(&:import)
  end

  def import
    @raw_resp = client.get_all
    @trucks = convert_trucks
    persist
  end

  def convert_trucks
    converted = raw_resp.map do |raw_truck|
      truck_attrs = raw_truck.select { |attr| TRUCK_ATTRS.member?(attr) }
      temp = FoodTruck.new(truck_attrs)
      temp.x_coord = raw_truck['x']
      temp.y_coord = raw_truck['y']
      temp.save!
    end
  end

  def client
    @client ||= FoodTruckClient
  end
end
