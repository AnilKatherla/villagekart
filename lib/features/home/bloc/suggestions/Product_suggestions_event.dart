abstract class SuggestionsEvent {}

class FetchSuggestions extends SuggestionsEvent {
  final String pincode;
  final String query;

  FetchSuggestions({required this.pincode, this.query = 'test'});
}
class SuggestionsReset extends SuggestionsEvent {} 
// ADD this new event
class FetchSuggestionsFromCart extends SuggestionsEvent {
  final String pincode;
   FetchSuggestionsFromCart({required this.pincode});
}