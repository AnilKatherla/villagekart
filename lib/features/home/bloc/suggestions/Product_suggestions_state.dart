// features/home/bloc/suggestions_bloc/suggestions_state.dart

import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestion_model.dart';


abstract class SuggestionsState {}

class SuggestionsInitial extends SuggestionsState {}

class SuggestionsLoading extends SuggestionsState {}

class SuggestionsLoaded extends SuggestionsState {
  final List<SuggestionProduct> suggestions;
  final String warehouseId; // extracted from data.warehouse.id

  SuggestionsLoaded({
    required this.suggestions,
    required this.warehouseId,
  });
}

class SuggestionsEmpty extends SuggestionsState {}

class SuggestionsError extends SuggestionsState {
  final String errorMessage;
  SuggestionsError({required this.errorMessage});
}