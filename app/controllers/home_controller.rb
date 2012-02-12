class HomeController < ApplicationController
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

end
