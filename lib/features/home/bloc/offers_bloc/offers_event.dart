// offers_events.dart
abstract class OffersEvent {}

class FetchOffers extends OffersEvent {
  final String pincode;
  final int page;
  final int limit;

  FetchOffers({
    required this.pincode,
    this.page = 1,
    this.limit = 20,
  });
}

class RefreshOffers extends OffersEvent {
  final String pincode;
  final int limit;

  RefreshOffers({
    required this.pincode,
    this.limit = 20,
  });
}

// Add this new event
class LoadMoreOffers extends OffersEvent {
  final String pincode;
  final int limit;

  LoadMoreOffers({
    required this.pincode,
    this.limit = 20,
  });
}