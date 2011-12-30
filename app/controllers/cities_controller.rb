class CitiesController < ApplicationController
  
  def getMatchedCities
    respond_to do |format|
      format.json do
        render :json => { :cities => City.where("name LIKE ?", params[:name]+'%').select('name').limit(10) }
      end
    end
  end
  
end