// features/home/bloc/suggestions_bloc/suggestions_bloc.dart

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/cart/services/cart_api_service.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestion_model.dart';
import 'Product_suggestions_event.dart';
import 'Product_suggestions_state.dart';

class SuggestionsBloc extends Bloc<SuggestionsEvent, SuggestionsState> {
  final NetworkService _networkService = ServiceLocator.networkService;
  final CartApiService _cartApiService = CartApiService(); // ✅ add

  SuggestionsBloc() : super(SuggestionsInitial()) {
    on<FetchSuggestions>(
      _onFetchSuggestions,
      transformer: droppable(),
    );
    on<SuggestionsReset>((_, emit) => emit(SuggestionsEmpty()));
    on<FetchSuggestionsFromCart>(_onFetchSuggestionsFromCart); // ✅ add
  }
  Future<void> _onFetchSuggestions(
    FetchSuggestions event,
    Emitter<SuggestionsState> emit,
  ) async {
    // Avoid duplicate fetches — same as PopularProductsBloc pattern
    if (state is SuggestionsLoading) return;

    emit(SuggestionsLoading());

    try {
      final response = await _networkService.get(
        'products/suggestions',
        queryParameters: {
          'pincode': event.pincode,
          'query': event.query,
        },
      );

      if (response.data['status'] != true) {
        emit(SuggestionsError(
          errorMessage: response.data['response'] ?? 'Unknown error',
        ));
        return;
      }

      final data = response.data['data'] as Map<String, dynamic>;
      final warehouseId = data['warehouse']?['id'] as String? ?? '';
      final List suggestionsJson = data['suggestions'] ?? [];

      if (suggestionsJson.isEmpty) {
        emit(SuggestionsEmpty());
        return;
      }

      final suggestions = suggestionsJson
          .map((e) => SuggestionProduct.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(SuggestionsLoaded(
        suggestions: suggestions,
        warehouseId: warehouseId,
      ));
    } catch (e) {
      emit(SuggestionsError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

 // ADD this method inside SuggestionsBloc

Future<void> _onFetchSuggestionsFromCart(
  FetchSuggestionsFromCart event,
  Emitter<SuggestionsState> emit,
) async {
  try {
    final warehouseId = await SharedPrefs.getWarehouseId();
    final cart = await _cartApiService.getCart(warehouseId);

    if (cart.items.isEmpty) {
      emit(SuggestionsEmpty());
      return;
    }
 String query = '';


  final item = cart.items.firstWhere(
    (item) => item.product?.name?.trim().isNotEmpty == true,
  
  );

  final name = item?.product?.name?.trim();

  if (name != null && name.isNotEmpty) {
    query = name.split(' ').first;
  }

  if (query.isNotEmpty) {
    add(FetchSuggestions(pincode: event.pincode, query: query));
  }
} catch (e) {
    emit(SuggestionsEmpty());
  }
}
}