class HomeController < ApplicationController
  def index
    unless current_user
      flash.now[:notice] = 'Nie jestes zalogowany.'
    end
  end

end
