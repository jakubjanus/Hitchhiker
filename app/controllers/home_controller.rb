class HomeController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:edit_user]
  
  def index
    unless current_user
      flash.now[:notice] = 'Nie jestes zalogowany.'
    end
  end
  
  def profil
    if current_user
      @user = current_user
    else
      flash.now[:error] = 'Nie jestes zalogowany.'
    end
  end
  
  def edit_user
    if current_user
      puts "---------------------OK---------------------------"
      puts params
      
      #  current_user.set_user_data(params)
      
      respond_to do |format|
        format.json do
          render :json => {:status => "OK"}
        end
      end
    end
  end

end
