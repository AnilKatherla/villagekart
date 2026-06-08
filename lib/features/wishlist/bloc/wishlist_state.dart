// features/wishlist/bloc/wishlist_state.dart
import 'package:villag_kart/features/wishlist/model/wishlist_model.dart';

abstract class WishlistState {}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> wishlistItems;
  final bool hasReachedMax;
  final int currentPage;

  WishlistLoaded({
    required this.wishlistItems,
    required this.hasReachedMax,
    required this.currentPage,
  });
  WishlistLoaded copyWith({
    List<WishlistItem>? wishlistItems,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WishlistLoaded(
      wishlistItems: wishlistItems ?? this.wishlistItems,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class WishlistRefreshing extends WishlistState {
  final List<WishlistItem> wishlistItems;
  final bool hasReachedMax;
  final int currentPage;

  WishlistRefreshing({
    required this.wishlistItems,
    required this.hasReachedMax,
    required this.currentPage,
  });
}

class WishlistLoadingMore extends WishlistState {
  final List<WishlistItem> wishlistItems;
  final bool hasReachedMax;
  final int currentPage;

  WishlistLoadingMore({
    required this.wishlistItems,
    required this.hasReachedMax,
    required this.currentPage,
  });
}

class WishlistEmpty extends WishlistState {
  final String message;

  WishlistEmpty({required this.message});
}

class WishlistError extends WishlistState {
  final String errorMessage;

  WishlistError({required this.errorMessage});
}

// Simplify these states since we don't need the full WishlistModel response
class WishlistItemAdded extends WishlistState {
  final String productId;

  WishlistItemAdded({required this.productId});
}

class WishlistItemRemoved extends WishlistState {
  final String productId;

  WishlistItemRemoved({required this.productId});
}

class WishlistItemToggled extends WishlistState {
  final String productId;
  final bool isNowInWishlist;

  WishlistItemToggled({
    required this.productId,
    required this.isNowInWishlist,
  });
}