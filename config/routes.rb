Hitchhiker::Application.routes.draw do
  devise_for :users

  get "home/index"
  get "home/profil"
  
  match 'home/profil/edit_user', :controller => 'home', :action => 'edit_user'
  match ':messages/:new/:sender_id/:recipient_id' => 'messages#new'
  match ':messages/:sender_id/:recipient_id' => 'messages#create', :via => :post

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
  
  #resources :messages, :only => [:new, :create]
  
  root :to => 'home#index'
end
