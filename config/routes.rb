Hitchhiker::Application.routes.draw do
  devise_for :users

  get "home/index"
  get "home/profil"
  
  match 'home/profil/edit_user', :controller => 'home', :action => 'edit_user'
  match ':messages/:new/:sender_id/:recipient_id' => 'messages#new'
  match ':messages/:sender_id/:recipient_id' => 'messages#create', :via => :post
  resources :messages, :only => [:show, :destroy]
  
  match ':reservations/:id/remove' => 'reservations#remove'
  match ':reservations/:id/accept' => 'reservations#accept'
  match ':reservations/:drive_id/:user_id' => 'reservations#create'
  

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
