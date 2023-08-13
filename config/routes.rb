Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :food_trucks, only: :index
    end
  end
end
