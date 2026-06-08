// ============================================================================
// WISHLIST EVENTS (wishlist_events.dart)
// ============================================================================

abstract class WishlistEvent {}

class FetchWishlist extends WishlistEvent {}

class RefreshWishlist extends WishlistEvent {}

class RemoveFromWishlist extends WishlistEvent {
  final String productId;

  RemoveFromWishlist({required this.productId});
}

