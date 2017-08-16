class CitySearch < Advanced::Search
  def search_name(name:, **)
    where('cities.name like ?', "%#{name}%")
  end

  def search_population_gteq(population_gteq:, **)
    where('cities.population >= ?', population_gteq)
  end

  def search_population_lteq(population_lteq:, **)
    where('cities.population <= ?', population_lteq)
  end

  def search_rank_gteq(rank_gteq:, **)
    where('cities.rank >= ?', rank_gteq)
  end

  def search_rank_lteq(rank_lteq:, **)
    where('cities.rank <= ?', rank_lteq)
  end

  def search_state(state:, **)
    joins(:state).merge State.search(state)
  end

  class Form < Advanced::SearchForm
    search CitySearch
    nested :state, StateSearch::Form
  end
end
