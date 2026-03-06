Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root "search#index"

  resources :appointment_requests, only: [ :create ]

  # Nutritionist flow
  resources :nutritionists, only: [ :index ] do
    member do
      get :pending_requests
    end
  end

  # Nutritionist dashboard - React page
  namespace :api do
    resources :nutritionists, only: [] do
      resources :appointment_requests, only: [ :index ]
    end

    resources :appointment_requests, only: [] do
      patch :decide, on: :member
    end
  end
end
