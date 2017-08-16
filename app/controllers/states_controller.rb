class StatesController < ApplicationController
  def index
    # Take the incoming form params and initialize our form object
    @form   = StateSearch::Form.new(params[:q])

    # Call our search with the form object.
    @states = State.order(:name).search(@form)
  end
end
