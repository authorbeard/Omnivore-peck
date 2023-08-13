module Api
  module V1
    class FoodTrucksController < ApplicationController
      def index
        trucks = FoodTruck.newest_ten

        render json: { data: trucks }
      end

      private

      def query_paramse
        params.permit(:query, :filters)
      end
    end
  end
end
