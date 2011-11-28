class HomeController < ApplicationController
  def index
    unless current_user
      flash[:notice] = 'Nie jesteś zalogowany.'
    end
  end

end
