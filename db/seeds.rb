require 'json'

file   = Rails.root.join('db', 'cities.json')
data   = JSON.parse(file.read, symbolize_names: true)
states = data.group_by { |data| data[:state] }

ActiveRecord::Base.transaction do
  states.each do |name, cities_data|
    state = State.create!(name: name)

    cities_data.each do |datum|
      state.cities.create!(
        name:       datum.fetch(:city),
        rank:       datum.fetch(:rank).to_i,
        population: datum.fetch(:population).to_i
      )
    end
  end
end
