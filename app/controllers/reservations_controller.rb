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
    reservation = Reservation.find(params[:id])
    if current_user.id == reservation.user.id
      reservation.destroy
      flash[:notice] = 'Usunięto rezerwację.'
    else
      flash[:error] = 'Możesz usuwać tylko swoje rezerwacje.'
    end
    redirect_to root_path
  end
  
  def accept
    reservation = Reservation.find(params[:id])
    if current_user.id == reservation.user.id
      current_user.accept_reservation(reservation)
      flash[:notice] = 'Zaakceptowano rezerwację.'
    else
      flash[:error] = 'Możesz akceptować tylko swoje rezerwacje.'
    end
    redirect_to root_path
  end
  
  private
  def check_required_params(params)
    params[:user_id] and params[:drive_id]
  end
end
