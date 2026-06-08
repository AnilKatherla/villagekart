abstract class SuggestionState {}

class SuggestionInitial extends SuggestionState {}

class SuggestionLoading extends SuggestionState {}

class SuggestionSuccess extends SuggestionState {
  final String message;
  SuggestionSuccess({required this.message});
}

class SuggestionError extends SuggestionState {
  final String errorMessage;
  SuggestionError({required this.errorMessage});
}