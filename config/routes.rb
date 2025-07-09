Rails.application.routes.draw do
  root 'home#index'
  resources :topics, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get :search # /topics/search
    end
    member do
      get :posts # /topics/:id/posts
    end
  end
  resources :posts, only: [] do
    collection do
      get :fetch # /posts/fetch?topic_id=1
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
