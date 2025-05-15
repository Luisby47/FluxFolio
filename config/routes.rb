# This file defines the routing configuration for the Fluxfolio application
# It maps URLs to controller actions and establishes the application's URL structure

Rails.application.routes.draw do
  # Progressive Web App (PWA) routes
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  resource :session                   # Login/logout functionality
  resources :passwords, param: :token # Password reset functionality
  resource :signup, only: [ :new, :create ] # User registration

  # Main application routes
  resources :portfolios do
    member do
      # Route to refresh investment prices from external sources
      post :refresh_investment_prices
    end
    
    # Note draft routes for portfolios
    resource :note_draft, only: [ :show, :create, :update, :destroy ]
    
    # Transaction creation for portfolios
    resources :transactions, only: [ :new, :create ]
    
    # Nested routes for investments within portfolios
    resources :investments, except: [ :index ] do
      # Transaction management for specific investments
      resources :transactions do
        collection do
          # Export transactions to CSV/JSON
          get :export
        end
      end
      
      # Note draft routes for investments
      resource :note_draft, only: [ :show, :create, :update, :destroy ]
      
      # Note management for investments
      resources :notes, except: [ :index, :show ]
    end
    
    # Note management for portfolios
    resources :notes, except: [ :index, :show ]
  end

  # User settings management
  resource :settings, only: [ :show ] do
    # Routes for user account management
    patch :update_password, on: :collection
    patch :disable_user, on: :collection
  end

  # Health check route for monitoring application status
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route - the application's landing page
  root "home#index"
end
