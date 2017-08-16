class State < ApplicationRecord
  extend StateSearch.scope

  has_many :cities
end
