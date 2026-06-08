// ============================================================================
// BLOC & EVENTS
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import 'suggestion_event.dart';
import 'suggestion_service.dart';
import 'suggestion_state.dart';

class SuggestionBloc extends Bloc<SuggestionEvent, SuggestionState> {
  SuggestionBloc() : super(SuggestionInitial()) {
    on<SubmitSuggestion>(_onSubmitSuggestion);
  }

  Future<void> _onSubmitSuggestion(
    SubmitSuggestion event,
    Emitter<SuggestionState> emit,
  ) async {
    emit(SuggestionLoading());
    try {
      final response = await SuggestionService.submitSuggestion(
        suggestion: event.suggestion,
        roleName: event.roleName,
      );
      emit(SuggestionSuccess(message: response.response));
    } catch (e) {
      emit(SuggestionError(errorMessage: e.toString()));
    }
  }
}


