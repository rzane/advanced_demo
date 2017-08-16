class StateSearch < Advanced::Search
  def search_name(name:, **)
    where('states.name like ?', "%#{name}%")
  end

  class Form < Advanced::SearchForm
    search StateSearch
  end
end
