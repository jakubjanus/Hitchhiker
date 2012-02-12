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
      
      puts "first_name"
      puts params['first_name']
      
      puts "current user"
      puts current_user
      puts current_user.name
      
      current_user.set_user_data(params)
      flash[:notice] = 'Wprowadzono pomyslnie zmiany.'
      
      respond_to do |format|
        format.json do
          render :json => {:status => "redirect", :path => "/home/profil"}
        end
      end
      #redirect_to '/home/profil'
    end
  end

  private
  def build_date(value)
    date = nil
    if value =~ %r{(\d\d)-(\d\d)-(\d\d\d\d)}
      date = Date.new($3.to_i,$2.to_i,$1.to_i)
    end
    date
  end
end
