Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'tools#index'
  resources :tools do
    get :update_translation, on: :member
  end
end
