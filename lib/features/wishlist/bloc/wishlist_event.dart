// features/wishlist/bloc/wishlist_event.dart


import 'package:villag_kart/features/home/model/product_response.dart';

abstract class WishlistEvent {}

class FetchWishlist extends WishlistEvent {
  final int page;
  final int limit;

  FetchWishlist({
    this.page = 1,
    this.limit = 20,
  });
}

class RefreshWishlist extends WishlistEvent {
  final int limit;

  RefreshWishlist({
    this.limit = 20,
  });
}

class LoadMoreWishlist extends WishlistEvent {
  final int limit;

  LoadMoreWishlist({
    this.limit = 20,
  });
}

// Add this missing event class
class LoadWishlist extends WishlistEvent {
   LoadWishlist();
}

class AddToWishlist extends WishlistEvent {
  final String productId;

  AddToWishlist({
    required this.productId,
  });
}

class RemoveFromWishlist extends WishlistEvent {
  final String productId;

  RemoveFromWishlist({
    required this.productId,
  });
}

class ToggleWishlist extends WishlistEvent {
  final String productId;
  final bool isCurrentlyInWishlist;
  final Product product;

  ToggleWishlist({
    required this.productId,
    required this.isCurrentlyInWishlist,
    required this.product,
  });
}