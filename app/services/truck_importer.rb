class TruckImporter
  attr_accessor :raw_resp

  def self.perform
    new.tap(&:import)
  end

  def initialize
    #really not sure about this.
    @raw_resp = client.get_all
  end

  def import
    # raw_resp = client.get_all
    convert_trucks
    # persist
  end

  def convert_trucks
    converted = raw_resp.map do |raw_truck|
      base = truck_attrs.map { |a| raw_truck[a] }.compact
    end
  end

  def temp_truck
    Struct.new(truck_attrs)
  end

  def truck_attrs
    @truck_attrs ||= FoodTruck.attribute_names.map(&:to_sym)
  end

  def client
    @client ||= FoodTruckClient
  end
end
