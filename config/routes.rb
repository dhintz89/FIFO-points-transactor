Rails.application.routes.draw do
  scope defaults: {format: :json} do
    devise_for :users, controllers: {registrations: :registrations, sessions: :sessions}
    resource :user, only: [:show, :update]
    
    resources :users do
      resources :transactions, except: [:create, :index] do
        collection do
          get 'points_balance'
          post 'add_points'
          post 'deduct_points'
        end
      end
    end

  end
end
