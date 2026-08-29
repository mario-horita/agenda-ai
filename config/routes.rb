Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for users
  devise_for :users

  # Landing page principal do SaaS
  root to: "pages#landing"
  resources :onboarding, only: [ :new, :create ]

  # Rotas com escopo de tenant (ex: /salao-demo/...)
  scope "/:tenant_slug" do
    # Área pública do tenant (sem autenticação)
    namespace :public do
      resource :tenant_page, only: [ :show ]
      resources :slots, only: [ :index ]
      resources :bookings, only: [ :index, :new, :create, :show ]
      resources :appointments, only: [ :show ] do
        member do
          patch :cancel
          get :reschedule
          patch :reschedule
        end
      end
    end

    # Painel administrativo do tenant (autenticação obrigatória)
    namespace :admin do
      root to: "dashboard#index"

      resources :professionals do
        resources :availabilities, only: [ :index, :create, :destroy ]
        resources :time_blocks, only: [ :index, :create, :destroy ]
      end

      resources :services

      resources :appointments, only: [ :index, :show ] do
        member do
          patch :cancel
          patch :complete
          patch :no_show
        end
      end

      resource :setting, only: [ :edit, :update ]
      resource :subscription, only: [ :show, :create ] do
        collection do
          get :success
          get :cancel
          post :portal
        end
      end
    end
  end

  # Stripe Webhooks (sem scoping de tenant)
  post "/webhooks/stripe", to: "webhooks/stripe#create"
end
