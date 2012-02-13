 # -*- coding: utf-8 -*-
class MessagesController < ApplicationController
 
  before_filter :authenticate_user!, :only => [:create, :show, :destroy]
  
  def show
    message = Message.find(params[:id])
    if current_user.id == message.sender.id or current_user.id == message.recipient.id
      @is_sender = true if current_user.id == message.sender.id
      @sender = message.sender
      @recipient = message.recipient
      @title = message.title
      @contents = message.read_message
    else
      flash[:error] = 'Nie możesz przeglądać nie swoich wiadomości.'
      redirect_to root_path
    end
  end
  
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
  
  def destroy
    #if current_user.id == Message.find(params[:id])
    #else
    #  flash[:error] = 'Możesz usuwać tylko swoje wiadomości.'
    #end
  end
  
  private
  def check_required(params)
    params[:title] and params[:contents] and params[:sender_id] and params[:recipient_id]
  end
end