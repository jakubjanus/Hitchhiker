 # -*- coding: utf-8 -*-
class MessagesController < ApplicationController
 
  before_filter :authenticate_user!, :only => [:create]
 
  def new
    @sender = User.find(params[:sender_id])
    @recipient = User.find(params[:recipient_id])
  end
  
  def create    
    if check_required(params)
      if User.find(params[:sender_id]) and User.find(params[:recipient_id])
        User.find(params[:sender_id]).send_message(User.find(params[:recipient_id]), params[:title], params[:contents])
        flash[:notice] = 'Wysłano wiadomość'
        redirect_to root_path
      end
    end
  end
  
  private
  def check_required(params)
    params[:title] and params[:contents] and params[:sender_id] and params[:recipient_id]
  end
end