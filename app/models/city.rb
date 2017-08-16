class City < ApplicationRecord
  extend CitySearch.scope

  belongs_to :state
end
