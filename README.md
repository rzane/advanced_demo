# Advanced Demo

This is a demo of the (Advanced)[https://github.com/rzane/advanced] gem.

It shows the largest 1,000 cities in the United States.

# Basic Example

## [StateSearch](app/searches/state_search.rb)

The `StateSearch`. This object is responsible for querying the states table.

```ruby
class StateSearch < Advanced::Search
  def search_name(name:, **)
    where('states.name like ?', "%#{name}%")
  end
end
```

We can use our `StateSearch` like this:

```ruby
StateSearch.call(State.all, name: 'New')
# => SELECT * FROM states WHERE states.name like '%New%'
```

## [State](app/models/state.rb)

By extending the scope in our `State` model, we can shorten this a bit.

```ruby
class State < ApplicationRecord
  extend StateSearch.scope
end

State.search(name: 'New')
```

## [StateSearch::Form](app/searches/state_search.rb)

Within the `StateSearch` class, we'll also define a form object, `StateSearch::Form`.

```ruby
class StateSearch < Advanced::Search
  # ...
  class Form < Advanced::SearchForm
    search StateSearch
  end
end
```

It's basically a hash, except that it's compatible with Rails' form builder.

```ruby
form = StateSearch::Form.new(name: 'New')
form.name #=> 'New'
State.search(form)
# => SELECT * FROM states WHERE states.name like '%New%'
```

## [StatesController](app/controllers/states_controller.rb)

In our controller, we're going to initialize a form from the incoming params hash and query for `States`.

```ruby
class StatesController < ApplicationController
  def index
    @form   = StateSearch::Form.new(params[:q])
    @states = State.order(:name).search(@form)
  end
end
```

## [states/index.html.erb](app/views/states/index.html.erb)

In this file, we'll wire everything up. There's no magic here. We're just using Rails built-in functionality to create our form.

```erb
<h1 class="page-header">
  States
</h1>

<div class="row">
  <div class="col-md-8">
    <table class="table table-striped table-bordered">
      <thead>
        <tr>
          <th>Name</th>
        </tr>
      </thead>

      <tbody>
        <% @states.each do |state| %>
          <tr>
            <td><%= state.name %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>

  <div class="col-md-4">
    <%= form_for @form, method: :get, url: states_path, as: :q do |f| %>
      <div class="form-group">
        <%= f.label :name, class: 'control-label' %>
        <%= f.text_field :name, class: 'form-control' %>
      </div>

      <%= f.submit 'Search', class: 'btn btn-primary' %>
      <%= link_to 'Reset', states_path, class: 'btn btn-default' %>
    <% end %>
  </div>
</div>
```

# A More Complicated Example

## [CitySearch](app/searches/city_search.rb)

For listing cities, we'll do a more complicated query. Advanced is designed to be composable, so we can take advantage of the `StateSearch` that we already built.

```ruby
class CitySearch < Advanced::Search
  def search_name(name:, **)
    where('cities.name like ?', "%#{name}%")
  end

  def search_state(state:, **)
    joins(:state).merge State.search(state)
  end
end
```

We can use our `CitySearch` like this:

```ruby
CitySearch.call(City.all, name: 'New York')
#=> SELECT  "cities".* FROM "cities" WHERE (cities.name like '%New York%')

CitySearch.call(City.all, state: { name: 'New York' })
#=> SELECT  "cities".* FROM "cities"
#=> INNER JOIN "states" ON "states"."id" = "cities"."state_id"
#=> WHERE (states.name like '%New York%')
```

## [City](app/models/city.rb)

Again, we can abbreviate this by adding the scope to our model:

```ruby
class City < ApplicationRecord
  extend CitySearch.scope
end
```

```ruby
City.search(name: 'New York')
```

## [CitySearch::Form](app/searches/city_search.rb)

We can also implement nested forms. Doing so will allow us to take advantage of Rails' `fields_for`.

```ruby
class CitySearch < Advanced::Search
  # ...
  class Form < Advanced::SearchForm
    search CitySearch
    nested :state, StateSearch::Form
  end
end
```

We can use the `CitySearch::Form` like this:

```ruby
form = CitySearch::Form.new(name: 'New York', state: { name: 'New York' })
form.name #=> 'New York'
form.state.name #=> 'New York'

City.search(form)
#=> SELECT  "cities".* FROM "cities"
#=> INNER JOIN "states" ON "states"."id" = "cities"."state_id"
#=> WHERE (cities.name like '%New York%') AND (states.name like '%New York%')
```

## [CitiesController](app/controllers/cities_controller.rb)

As before, we'll wire up our controller:

```ruby
class CitiesController < ApplicationController
  def index
    @form   = CitySearch::Form.new(params[:q])
    @cities = City.includes(:state).order(:rank).search(@form)
  end
end
```

## [cities/index.html.erb](app/views/cities/index.html.erb)

This file is very similar to the states example, except that in order to query the states table, we'll use Rails `fields_for`.

```erb
<%= form_for @form, method: :get, url: cities_path, as: :q do |f| %>
  ...

  <%= f.fields_for :state do |state| %>
    <div class="form-group">
      <%= state.label :name, 'State', class: 'control-label' %>
      <%= state.text_field :name, class: 'form-control' %>
    </div>
  <% end %>
<% end %>
```
