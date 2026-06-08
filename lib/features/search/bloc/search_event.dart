// lib/features/search/bloc/search_event.dart

abstract class SearchEvent {}

/// Event to fetch recent searches from local storage
class FetchRecentSearches extends SearchEvent {}

/// Event to fetch top moving/popular products
class FetchTopMovingProducts extends SearchEvent {}

/// Event to fetch browse groups/categories
class FetchBrowseGroups extends SearchEvent {}

/// Event to add a search query to recent searches
class AddRecentSearch extends SearchEvent {
  final String query;
  
  AddRecentSearch(this.query);
}

/// Event to clear all recent searches
class ClearRecentSearches extends SearchEvent {}

/// Event to search for products by query
class SearchProducts extends SearchEvent {
  final String query;
  
  SearchProducts(this.query);
}

/// Event to clear search results and return to main screen
class ClearSearchResults extends SearchEvent {}
