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
      debugger;
      truck = FoodTruck.where(
        external_location_id: raw_truck['external_location_id'],
        permit: raw_truck['permit']
      ).first_or_initialize
       .assign_attributes(raw_truck)
       .save!
    end

  rescue => e
    logger.error("#{e.message} | #{e.instance_attributes}")
  end

  def client
    @client ||= FoodTruckClient
  end
end
