Rails.application.routes.draw do
  resources :products do
    collection do
      post :import
      post :map_fields
    end
  end

  root 'products#index'
end
