Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "chatbots#index"

  get "/scraped_data", to: "chatbots#scraped_data"

  resources :chatbot_creations, only: [ :update ]
end
