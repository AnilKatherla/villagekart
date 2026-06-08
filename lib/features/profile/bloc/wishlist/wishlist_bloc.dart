// ============================================================================
// WISHLIST BLOC (wishlist_bloc.dart)
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import 'wishlist_event.dart';
import 'wishlist_service.dart';
import 'wishlist_state.dart';


class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistInitial()) {
    on<FetchWishlist>(_onFetchWishlist);
    on<RefreshWishlist>(_onRefreshWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
  }

  /// Handle initial fetch of wishlist
  Future<void> _onFetchWishlist(
    FetchWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());

    try {
      final wishlistResponse = await WishlistService.fetchWishlist();

      if (wishlistResponse.data.isEmpty) {
        emit(WishlistEmpty(message: 'Your wishlist is empty'));
      } else {
        emit(WishlistLoaded(items: wishlistResponse.data));
      }
    } catch (e) {
      emit(WishlistError(errorMessage: e.toString()));
    }
  }

  /// Handle refresh of wishlist
  Future<void> _onRefreshWishlist(
    RefreshWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is WishlistLoaded) {
      emit(WishlistRefreshing(items: currentState.items));
    }

    try {
      final wishlistResponse = await WishlistService.fetchWishlist();

      if (wishlistResponse.data.isEmpty) {
        emit(WishlistEmpty(message: 'Your wishlist is empty'));
      } else {
        emit(WishlistLoaded(items: wishlistResponse.data));
      }
    } catch (e) {
      if (currentState is WishlistLoaded) {
        emit(currentState); // Revert to previous state
      }
      emit(WishlistError(errorMessage: e.toString()));
    }
  }

  /// Handle remove from wishlist
  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;

    if (currentState is WishlistLoaded) {
      emit(WishlistRemoving(
        items: currentState.items,
        removingProductId: event.productId,
      ));

      try {
        await WishlistService.removeFromWishlist(
          productId: event.productId,
        );

        // Remove the item from list
        final updatedItems = currentState.items
            .where((item) => item.productId != event.productId)
            .toList();

        if (updatedItems.isEmpty) {
          emit(WishlistEmpty(message: 'Your wishlist is empty'));
        } else {
          // emit(WishlistRemoved(
          //   items: updatedItems,
          //   message: 'Item removed from wishlist',
          // ));
          // Emit loaded state after showing removal message
          emit(WishlistLoaded(items: updatedItems));
        }
      } catch (e) {
        emit(currentState); // Revert to previous state
        emit(WishlistError(errorMessage: e.toString()));
      }
    }
  }
}