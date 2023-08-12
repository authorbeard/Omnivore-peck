require 'rails_helper'

RSpec.describe 'TruckImporter' do
  class MockClient
    def self.get_all
      JSON.parse(File.read('./spec/fixtures/files/all_trucks.json'))
    end
  end

  before do
    stub_const('FoodTruckClient', MockClient)
  end

  describe '.import' do
    it 'queries the endpoint for food truck data' do
      allow(MockClient).to receive(:get_all).and_call_original

      TruckImporter.perform

      expect(MockClient).to have_received(:get_all)
    end

    it 'creates new FoodTruck objects and saves them to the database' do
      all_trucks_fixture = JSON.parse(file_fixture('all_trucks.json').read)
      expect do
        TruckImporter.perform
      end.to change(FoodTruck, :count).by(all_trucks_fixture.length)
    end
  end
end
