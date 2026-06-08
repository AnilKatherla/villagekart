// lib/features/search/bloc/search_bloc.dart

// lib/features/search/bloc/search_bloc.dart
// QUICK FIX: Add type casting where needed

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';
import 'search_event.dart';
import 'search_service.dart';
import 'search_state.dart';
import 'search_storage.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchLocalStorage localStorage;
  final SearchRepository repository;

  SearchBloc({required this.localStorage, required this.repository})
    : super(SearchInitial()) {
    on<FetchRecentSearches>(_onFetchRecentSearches);
    on<FetchTopMovingProducts>(_onFetchTopMovingProducts);
    on<FetchBrowseGroups>(_onFetchBrowseGroups);
    on<AddRecentSearch>(_onAddRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
    on<SearchProducts>(_onSearchProducts);
    on<ClearSearchResults>(_onClearSearchResults);
  }

  Future<void> _onFetchRecentSearches(
    FetchRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final recentSearches = await localStorage.getRecentSearches();

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(recentSearches: recentSearches));
      } else {
        emit(SearchLoaded(recentSearches: recentSearches));
      }
    } catch (e) {
      debugPrint('❌ Error fetching recent searches: $e');
    }
  }

  Future<void> _onFetchTopMovingProducts(
    FetchTopMovingProducts event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final savedLocation = await LocationService.getSavedLocation();
      if (savedLocation == null) {
        debugPrint('⚠️ No saved location found');
        return;
      }

      final pincode = savedLocation['pincode'] as String? ?? '';
      if (pincode.isEmpty) {
        debugPrint('⚠️ Invalid pincode');
        return;
      }

      final products = await repository.getTopMovingProducts(
        pincode: pincode,
        limit: 10,
      );

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(topMovingProducts: products));
      } else {
        emit(SearchLoaded(topMovingProducts: products));
      }
    } catch (e) {
      debugPrint('❌ Error fetching top moving products: $e');
      if (state is! SearchLoaded) {
        emit(SearchError(e.toString()));
      }
    }
  }

  Future<void> _onFetchBrowseGroups(
    FetchBrowseGroups event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final savedLocation = await LocationService.getSavedLocation();
      final userId = await LocationService.getUserId();

      if (savedLocation == null) {
        debugPrint('⚠️ No saved location found');
        return;
      }

      final pincode = savedLocation['pincode'] as String? ?? '';
      final latitude = (savedLocation['latitude'] as num?)?.toDouble() ?? 0.0;
      final longitude = (savedLocation['longitude'] as num?)?.toDouble() ?? 0.0;

      if (pincode.isEmpty) {
        debugPrint('⚠️ Invalid location data');
        return;
      }

      final categories = await repository.getBrowseGroups(
        pincode: pincode,
        latitude: latitude,
        longitude: longitude,
        userId: userId ?? '',
      );

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        // Fix: Cast to the correct type
        emit(currentState.copyWith(browseGroups: categories.cast()));
      } else {
        emit(SearchLoaded(browseGroups: categories));
      }
    } catch (e) {
      debugPrint('❌ Error fetching browse groups: $e');
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onAddRecentSearch(
    AddRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      debugPrint('⚠️ Empty query, skipping recent search storage');
      return;
    }

    try {
      debugPrint('💾 Storing recent search: ${event.query}');
      await localStorage.addRecentSearch(event.query);

      // ✅ Refresh recent searches so UI updates when user goes back
      final updated = await localStorage.getRecentSearches();
      if (state is SearchLoaded) {
        emit((state as SearchLoaded).copyWith(recentSearches: updated));
      }
    } catch (e) {
      debugPrint('❌ Error adding recent search: $e');
    }
  }

  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await localStorage.clearRecentSearches();

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(recentSearches: []));
      }
    } catch (e) {
      debugPrint('❌ Error clearing recent searches: $e');
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    // ✅ HARD RULE: Only search if 3+ characters
    if (event.query.trim().length < 3) {
      emit(SearchLoaded()); // reset to default search UI
      return;
    }

    try {
      debugPrint('🔍 Starting search for: ${event.query}');
      emit(
        SearchResultsState(query: event.query, isLoading: true, results: []),
      );

      final savedLocation = await LocationService.getSavedLocation();
      final pincode = savedLocation?['pincode'] as String? ?? '';

      debugPrint('📍 Pincode: $pincode');

      if (pincode.isEmpty) {
        debugPrint('❌ Location not available');
        emit(
          SearchResultsState(query: event.query, results: [], isLoading: false),
        );
        emit(SearchError('Location not available'));
        return;
      }

      final results = await repository.searchProducts(
        query: event.query,
        pincode: pincode,
      );

      debugPrint('✅ Search results found: ${results.length} products');
      emit(
        SearchResultsState(
          query: event.query,
          results: results,
          isLoading: false,
        ),
      );

      // // Add to recent searches
      // add(AddRecentSearch(event.query));
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      emit(
        SearchResultsState(query: event.query, results: [], isLoading: false),
      );
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onClearSearchResults(
    ClearSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoaded());
    add(FetchRecentSearches());
    add(FetchTopMovingProducts());
    add(FetchBrowseGroups());
  }
}





// // lib/features/search/bloc/search_bloc.dart

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:villag_kart/features/location/bloc/location_service.dart';
// import 'search_event.dart';
// import 'search_service.dart';
// import 'search_state.dart';
// import 'search_storage.dart';
// import 'package:villag_kart/features/home/bloc/category_bloc/category_service.dart';
// import 'package:villag_kart/features/home/bloc/popular_products_bloc/products_service.dart';
// import 'package:villag_kart/features/home/model/category_model.dart';


// class SearchBloc extends Bloc<SearchEvent, SearchState> {
//   final SearchLocalStorage localStorage;
//   final SearchRepository repository;
  
  
//   SearchBloc({
//     required this.localStorage,
//     required this.repository,
//   }) : super(SearchInitial()) {
//     on<FetchRecentSearches>(_onFetchRecentSearches);
//     on<FetchTopMovingProducts>(_onFetchTopMovingProducts);
//     on<FetchBrowseGroups>(_onFetchBrowseGroups);
//     on<AddRecentSearch>(_onAddRecentSearch);
//     on<ClearRecentSearches>(_onClearRecentSearches);
//     on<SearchProducts>(_onSearchProducts);
//     on<ClearSearchResults>(_onClearSearchResults);
//   }
  
//   Future<void> _onFetchRecentSearches(
//     FetchRecentSearches event,
//     Emitter<SearchState> emit,
//   ) async {
//     try {
//       final recentSearches = await localStorage.getRecentSearches();
      
//       if (state is SearchLoaded) {
//         final currentState = state as SearchLoaded;
//         emit(currentState.copyWith(recentSearches: recentSearches));
//       } else {
//         emit(SearchLoaded(recentSearches: recentSearches));
//       }
//     } catch (e) {
//       debugPrint('❌ Error fetching recent searches: $e');
//     }
//   }
  
//   Future<void> _onFetchTopMovingProducts(
//     FetchTopMovingProducts event,
//     Emitter<SearchState> emit,
//   ) async {
//     try {
//       // Get saved location
//       final savedLocation = await LocationService.getSavedLocation();
//       if (savedLocation == null) {
//         debugPrint('⚠️ No saved location found');
//         return;
//       }

//       final pincode = savedLocation['pincode'] as String? ?? '';
//       if (pincode.isEmpty) {
//         debugPrint('⚠️ Invalid pincode');
//         return;
//       }

//       // Fetch popular products using existing repository
//       final products = await repository.getTopMovingProducts(
//         pincode: pincode,
//         limit: 10,
//       );
      
//       if (state is SearchLoaded) {
//         final currentState = state as SearchLoaded;
//         emit(currentState.copyWith(topMovingProducts: products));
//       } else {
//         emit(SearchLoaded(topMovingProducts: products));
//       }
//     } catch (e) {
//       debugPrint('❌ Error fetching top moving products: $e');
//       if (state is! SearchLoaded) {
//         emit(SearchError(e.toString()));
//       }
//     }
//   }
  
//   Future<void> _onFetchBrowseGroups(
//     FetchBrowseGroups event,
//     Emitter<SearchState> emit,
//   ) async {
//     try {
//       // Get saved location and user ID
//       final savedLocation = await LocationService.getSavedLocation();
//       final userId = await LocationService.getUserId();
      
//       if (savedLocation == null) {
//         debugPrint('⚠️ No saved location found');
//         return;
//       }

//       final pincode = savedLocation['pincode'] as String? ?? '';
//       final latitude = (savedLocation['latitude'] as num?)?.toDouble() ?? 0.0;
//       final longitude = (savedLocation['longitude'] as num?)?.toDouble() ?? 0.0;

//       if (pincode.isEmpty || latitude == 0.0 || longitude == 0.0) {
//         debugPrint('⚠️ Invalid location data');
//         return;
//       }

//       //  List<Category>? categories = [];

//       // Fetch categories using existing repository
//      final categories = await repository.getBrowseGroups(
//         pincode: pincode,
//         latitude: latitude,
//         longitude: longitude,
//         userId: userId ?? '',
//       );
      
//       if (state is SearchLoaded)
//       {
//         final currentState = state as SearchLoaded;
//         // emit(currentState.copyWith( browseGroups: categories ));
//       } else {
//         // emit( SearchLoaded(browseGroups: categories ));
//       }

//     } 
//     catch (e) 
//     {
//       debugPrint('❌ Error fetching browse groups: $e');
//       emit(SearchError(e.toString()));
//     }
//   }
  
//   Future<void> _onAddRecentSearch(
//     AddRecentSearch event,
//     Emitter<SearchState> emit,
//   ) async {
//     if (event.query.trim().isEmpty) return;
    
//     try {
//       await localStorage.addRecentSearch(event.query);
//       add(FetchRecentSearches());
//     } catch (e) {
//       debugPrint('❌ Error adding recent search: $e');
//     }
//   }
  
//   Future<void> _onClearRecentSearches(
//     ClearRecentSearches event,
//     Emitter<SearchState> emit,
//   ) async {
//     try {
//       await localStorage.clearRecentSearches();
      
//       if (state is SearchLoaded) {
//         final currentState = state as SearchLoaded;
//         emit(currentState.copyWith(recentSearches: []));
//       }
//     } catch (e) {
//       debugPrint('❌ Error clearing recent searches: $e');
//     }
//   }
  
//   Future<void> _onSearchProducts(
//     SearchProducts event,
//     Emitter<SearchState> emit,
//   ) async {
//     try {
//       emit(SearchResultsState(query: event.query, isLoading: true));
      
//       // Get pincode for search
//       final savedLocation = await LocationService.getSavedLocation();
//       final pincode = savedLocation?['pincode'] as String? ?? '';
      
//       if (pincode.isEmpty) {
//         emit(SearchError('Location not available'));
//         return;
//       }

//       // Call search API
//       final results = await repository.searchProducts(
//         query: event.query,
//         pincode: pincode,
//       );
      
//       emit(SearchResultsState(query: event.query, results: results));
      
//       // Add to recent searches
//       add(AddRecentSearch(event.query));
//     } catch (e) {
//       debugPrint('❌ Error searching products: $e');
//       emit(SearchError(e.toString()));
//     }
//   }
  
//   Future<void> _onClearSearchResults(
//     ClearSearchResults event,
//     Emitter<SearchState> emit,
//   ) async {
//     // Return to initial search screen
//     emit(SearchLoaded());
//     add(FetchRecentSearches());
//     add(FetchTopMovingProducts());
//     add(FetchBrowseGroups());
//   }
// }