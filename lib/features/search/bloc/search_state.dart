// lib/features/search/bloc/search_state.dart
// lib/features/search/bloc/search_state.dart
// lib/features/search/bloc/search_state.dart
// OPTION 1: If you're sure both Category types are the same

import 'package:equatable/equatable.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/features/home/model/category_model.dart'
    as home_category;
import 'package:villag_kart/features/home/model/product_response.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  SearchLoaded({
    this.recentSearches = const [],
    this.topMovingProducts = const [],
    this.browseGroups = const [],
  });
  final List<String> recentSearches;
  final List<Product> topMovingProducts;
  final List<home_category.CategoryModel> browseGroups;

  @override
  List<Object?> get props => [recentSearches, topMovingProducts, browseGroups];

  SearchLoaded copyWith({
    List<String>? recentSearches,
    List<Product>? topMovingProducts,
    List<home_category.CategoryModel>? browseGroups,
  }) {
    return SearchLoaded(
      recentSearches: recentSearches ?? this.recentSearches,
      topMovingProducts: topMovingProducts ?? this.topMovingProducts,
      browseGroups: browseGroups ?? this.browseGroups,
    );
  }
}

class SearchResultsState extends SearchState {
  SearchResultsState({
    required this.query,
    this.results = const [],
    this.isLoading = false,
  });
  final String query;
  final List<Product> results;
  final bool isLoading;

  @override
  List<Object?> get props => [query, results, isLoading];
}

class SearchError extends SearchState {
  SearchError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}


// import 'package:equatable/equatable.dart';
// import 'package:villag_kart/features/home/model/popular_product_model.dart';
// import '../../home/model/product_details_response.dart';

// abstract class SearchState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class SearchInitial extends SearchState {}

// class SearchLoading extends SearchState {}

// class SearchLoaded extends SearchState {

  
//   final List<String> recentSearches;
//   final List<Product> topMovingProducts;
//   final List<Category> browseGroups;
    
  
//   SearchLoaded({
//     this.recentSearches = const [],
//     this.topMovingProducts = const [],
//     this.browseGroups = const [],
//   });
  
//   @override
//   List<Object?> get props => [recentSearches, topMovingProducts, browseGroups];
  
//   SearchLoaded copyWith({
//     List<String>? recentSearches,
//     List<Product>? topMovingProducts,
//     List<Category>? browseGroups,
//   }) {
//     return SearchLoaded(
//       recentSearches: recentSearches ?? this.recentSearches,
//       topMovingProducts: topMovingProducts ?? this.topMovingProducts,
//     browseGroups: browseGroups ?? this.browseGroups,
//     );
//   }
// }

// class SearchResultsState extends SearchState {
//   final String query;
//   final List<Product> results;
//   final bool isLoading;
  
//   SearchResultsState({
//     required this.query,
//     this.results = const [],
//     this.isLoading = false,
//   });
  
//   @override
//   List<Object?> get props => [query, results, isLoading];
// }

// class SearchError extends SearchState {
//   final String message;
  
//   SearchError(this.message);
  
//   @override
//   List<Object?> get props => [message];
// }