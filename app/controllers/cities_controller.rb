class CitiesController < ApplicationController
  def index
    @form   = CitySearch::Form.new(params[:q])
    @cities = City.includes(:state).order(:rank).search(@form)
  end
end
