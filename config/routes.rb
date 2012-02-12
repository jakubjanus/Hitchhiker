Hitchhiker::Application.routes.draw do
  devise_for :users

  get "home/index"
  get "home/profil"

  resources :drives do
    collection do
      get 'search'
      get 'searchSite'
    end
  end
  resources :cities do
    collection do
      get 'getMatchedCities'
    end
  end
  
  root :to => 'home#index'
end
