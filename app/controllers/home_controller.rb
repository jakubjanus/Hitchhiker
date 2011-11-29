class HomeController < ApplicationController
  def index
    unless current_user
      flash[:notice] = 'Nie jestes zalogowany.'
    end
  end

end
