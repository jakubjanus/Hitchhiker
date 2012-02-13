 # -*- coding: utf-8 -*-
class ReservationsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:create, :remove]
  
  def create
    if check_required_params(params)
      if current_user.id == User.find(params[:user_id]).id
        current_user.make_reservation(Drive.find(params[:drive_id]))
        flash[:notice] = 'Złożono rezerwację.'
      else
        flash[:error] = 'Możesz składać rezerwacje tylko w swoim imieniu.'
      end
    else
      flash[:error] = 'Brakujace parametry użytkownika lub przejazdu.'
    end
    redirect_to root_path
  end
  
  def remove
    
  end
  
  private
  def check_required_params(params)
    params[:user_id] and params[:drive_id]
  end
end
