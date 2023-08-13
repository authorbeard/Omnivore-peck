module Api
  module V1
    class FoodTrucksController < ApplicationController
      def index
        # trucks = FoodTruck.newest_ten

        render json: { data: trucks }
      end

      private

      def trucks
        FoodTruck.query(query_params)
      end

      def query_params
        params.permit(:q, :filters)
      end
    end
  end
end
