class CitiesController < ApplicationController
  
  def getMatchedCities
    @cities = []
    @cities = City.where("name LIKE ?", params[:name]+'%').select('name').limit(10) if params[:name]
    respond_to do |format|
      format.json{}
    end
  end
  
end