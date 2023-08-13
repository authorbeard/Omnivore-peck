module Api
  module V1
    class FoodTrucksController < ApplicationController
      def index
        render json: :ok
      end
    end
  end
end
