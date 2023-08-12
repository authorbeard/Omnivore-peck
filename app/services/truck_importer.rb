class TruckImporter
  TRUCK_ATTRS = FoodTruck.attribute_names.freeze
  attr_accessor :raw_resp, :trucks

  def self.perform
    new.tap(&:import)
  end

  def import
    @raw_resp = client.get_all
    @trucks = convert_and_save
  end

  private

  def convert_and_save
    trucks = raw_resp.map do |raw_truck|
      truck = FoodTruck.where(
        external_location_id: raw_truck['external_location_id'],
        permit: raw_truck['permit']
      ).first_or_initialize.tap do |t|
        t.assign_attributes(raw_truck)
        t.save!
      end
    end

  rescue => e
    Rails.logger.error("#{e.message} | #{e.instance_attributes}")
  end

  def client
    @client ||= FoodTruckClient
  end
end
