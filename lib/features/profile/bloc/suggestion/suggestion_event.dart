abstract class SuggestionEvent {}

class SubmitSuggestion extends SuggestionEvent {
  final String suggestion;
  final String roleName;

  SubmitSuggestion({
    required this.suggestion,
    this.roleName = 'USER',
  });
}

