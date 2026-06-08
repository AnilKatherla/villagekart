// features/wishlist/bloc/wishlist_bloc.dart
//
// Wishlist API Usage Strategy:
// - Full wishlist fetch (v1/wishlist GET) only happens on:
//   1. Initial load (LoadWishlist/FetchWishlist events)
//   2. Manual refresh (RefreshWishlist event - e.g., pull-to-refresh)
//   3. When wishlist screen is opened (should trigger FetchWishlist)
//
// - Add/Remove operations use optimistic updates:
//   - Remove: Immediately removes item from local state (no API fetch)
//   - Add: Updates local state without fetching (item appears on next explicit fetch)
//   - This reduces unnecessary API calls and improves UX responsiveness
//
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/wishlist/model/wishlist_model.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_service.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<FetchWishlist>(_onFetchWishlist);
    on<RefreshWishlist>(_onRefreshWishlist);
    on<AddToWishlist>(_onAddToWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
    on<ToggleWishlist>(_onToggleWishlist);
  }

  // Load wishlist (for initialization)
  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    await _onFetchWishlist(FetchWishlist(), emit);
  }

  Future<void> _onFetchWishlist(
    FetchWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());

    try {
      final wishlistModel = await WishlistService.getWishlist();

      if (wishlistModel.data.items.isEmpty) {
        emit(WishlistEmpty(message: 'Your wishlist is empty'));
      } else {
        emit(
          WishlistLoaded(
            wishlistItems: wishlistModel.data.items,
            hasReachedMax: true, // No pagination support
            currentPage: 1,
          ),
        );
      }
    } catch (e) {
      emit(
        WishlistError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onRefreshWishlist(
    RefreshWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    if (state is WishlistLoaded) {
      final currentState = state as WishlistLoaded;
      emit(
        WishlistRefreshing(
          wishlistItems: currentState.wishlistItems,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
        ),
      );

      try {
        final wishlistModel = await WishlistService.getWishlist();

        emit(
          WishlistLoaded(
            wishlistItems: wishlistModel.data.items,
            hasReachedMax: true,
            currentPage: 1,
          ),
        );
      } catch (e) {
        emit(
          WishlistError(
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    }
  }

  Future<void> _onAddToWishlist(
    AddToWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Save previous state for rollback on error
    final previousState = state;

    try {
      // Optimistically update UI if we have a loaded state
      if (state is WishlistLoaded) {
        final currentState = state as WishlistLoaded;
        emit(
          WishlistLoadingMore(
            wishlistItems: currentState.wishlistItems,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage,
          ),
        );
      }

      final success = await WishlistService.addToWishlist(
        productId: event.productId,
      );

      if (success) {
        // Emit success state for UI feedback (e.g., snackbar)
        emit(WishlistItemAdded(productId: event.productId));

        // Update local state optimistically if we have a loaded state
        // Note: We don't have full product details here, so we only update
        // the state if we're already in a loaded state. Full sync happens
        // on explicit refresh or when wishlist screen is opened.
        if (previousState is WishlistLoaded) {
          // Keep the current state - the item will appear on next fetch
          // This avoids unnecessary API call while maintaining UI consistency
          emit(previousState);
        }
        // If state was not loaded, we don't need to update anything
        // The wishlist will be fetched when needed (e.g., opening wishlist screen)
      }
    } catch (e) {
      // Restore previous state on error
      if (previousState is WishlistLoaded) {
        emit(previousState);
      }
      emit(
        WishlistError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Save previous state for rollback on error
    final previousState = state;

    try {
      // Optimistically update UI if we have a loaded state
      if (state is WishlistLoaded) {
        final currentState = state as WishlistLoaded;
        emit(
          WishlistLoadingMore(
            wishlistItems: currentState.wishlistItems,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage,
          ),
        );
      }

      final success = await WishlistService.removeFromWishlist(
        productId: event.productId,
      );

      if (success) {
        // Emit success state for UI feedback (e.g., snackbar)
        emit(WishlistItemRemoved(productId: event.productId));

        // Optimistically update local state - remove item from list
        if (previousState is WishlistLoaded) {
          final updatedItems = previousState.wishlistItems
              .where((item) => item.productId != event.productId)
              .toList();

          if (updatedItems.isEmpty) {
            emit(WishlistEmpty(message: 'Your wishlist is empty'));
          } else {
            emit(
              WishlistLoaded(
                wishlistItems: updatedItems,
                hasReachedMax: previousState.hasReachedMax,
                currentPage: previousState.currentPage,
              ),
            );
          }
        }
        // If state was not loaded, no need to update
        // The wishlist will be fetched when needed
      }
    } catch (e) {
      // Restore previous state on error
      if (previousState is WishlistLoaded) {
        emit(previousState);
      }
      emit(
        WishlistError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // features/wishlist/bloc/wishlist_bloc.dart
 Future<void> _onToggleWishlist(
  ToggleWishlist event,
  Emitter<WishlistState> emit,
) async {
  final currentState = state;
  if (currentState is! WishlistLoaded) {
    // If not loaded, just do the API call and fetch fresh
    await WishlistService.addToWishlist(productId: event.productId);
    add(FetchWishlist());
    return;
  }

  // 1. Prepare optimistic state
  List<WishlistItem> updatedItems = List.from(currentState.wishlistItems);
  
  if (event.isCurrentlyInWishlist) {
    updatedItems.removeWhere((i) => i.productId == event.productId);
  } else {
    // Note: Ideally, pass the 'Product' object via the event to avoid empty data
    updatedItems.add(WishlistItem(
      productId: event.productId,
      product: event.product, // Pass this from the UI!
      createdAt: DateTime.now(), status: '', updatedAt: null, warehouseId: '',
      // ... other fields
    ));
  }

  // 2. Emit optimistic state immediately
 emit(currentState.copyWith(wishlistItems: updatedItems));

  try {
    bool success;
    if (event.isCurrentlyInWishlist) {
      success = await WishlistService.removeFromWishlist(productId: event.productId);
    } else {
      success = await WishlistService.addToWishlist(productId: event.productId);
    }

    if (!success) throw Exception("Failed to update");
    
    // 3. Optional: Emit a 'Side Effect' state using a Mixin or separate Stream
    // emit(WishlistActionSuccess(message: "...")); 
    
  } catch (e) {
    // 4. Rollback on failure
    emit(currentState); 
    emit(WishlistError(errorMessage: "Sync failed. Please try again."));
  }
}
}
