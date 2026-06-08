

import '../../model/wishlist_model.dart';

abstract class WishlistState {}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> items;

  WishlistLoaded({required this.items});
}

class WishlistRefreshing extends WishlistState {
  final List<WishlistItem> items;

  WishlistRefreshing({required this.items});
}

class WishlistEmpty extends WishlistState {
  final String message;

  WishlistEmpty({required this.message});
}

class WishlistRemoving extends WishlistState {
  final List<WishlistItem> items;
  final String removingProductId;

  WishlistRemoving({
    required this.items,
    required this.removingProductId,
  });
}

class WishlistRemoved extends WishlistState {
  final List<WishlistItem> items;
  final String message;

  WishlistRemoved({
    required this.items,
    required this.message,
  });
}

class WishlistError extends WishlistState {
  final String errorMessage;

  WishlistError({required this.errorMessage});
}


