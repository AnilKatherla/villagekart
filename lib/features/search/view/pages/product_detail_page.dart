// features/product_detail/view/product_detail_page.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/core/widgets/app_image.dart';
import 'package:villag_kart/core/widgets/cart_bottom_bar.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/home/bloc/product_details_bloc/product_detail_bloc.dart';
import 'package:villag_kart/features/home/bloc/product_details_bloc/product_detail_event.dart';
import 'package:villag_kart/features/home/bloc/product_details_bloc/product_detail_state.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_bloc.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_event.dart';
import 'package:villag_kart/features/home/model/product_details_response.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/home/sections/Product_suggestions_section.dart';
import 'package:villag_kart/features/search/view/widgets/VariantBottomSheet.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.pincode,
  });

  final Product product;
  final String pincode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductDetailBloc()
            ..add(FetchProductDetail(productId: product.id, pincode: pincode)),
        ),
        // Use the global WishlistBloc instance from main.dart instead of creating a new one
        // This ensures wishlist state is shared across the app
        BlocProvider.value(value: context.read<WishlistBloc>()),
        BlocProvider(
          create: (context) => SuggestionsBloc()
            ..add(
              FetchSuggestions(
                pincode: pincode,
                query: product.name.split(' ').first,
              ),
            ),
        ),
      ],
      child: _ProductDetailContent(initialProduct: product),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({required this.initialProduct});
  final Product initialProduct;

  // Helper function to get wishlist status from state
  static bool? _getWishlistStatus(WishlistState state, String productId) {
    if (state is WishlistLoaded) {
      return state.wishlistItems.any((item) => item.productId == productId);
    } else if (state is WishlistItemToggled && state.productId == productId) {
      return state.isNowInWishlist;
    } else if (state is WishlistLoadingMore) {
      return state.wishlistItems.any((item) => item.productId == productId);
    } else if (state is WishlistRefreshing) {
      return state.wishlistItems.any((item) => item.productId == productId);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Sample products for "You might also like" section
    final List<Product> sampleProducts = [];

    return MultiBlocListener(
      listeners: [
        BlocListener<WishlistBloc, WishlistState>(
          listenWhen: (previous, current) {
            // Only listen to snackbar-triggering states to prevent duplicates
            // This ensures snackbar only shows once per action
            return current is WishlistItemAdded ||
                current is WishlistItemRemoved ||
                current is WishlistItemToggled ||
                current is WishlistError;
          },
          listener: (context, state) {
            // Only show snackbar if this route is currently active
            // This prevents duplicate snackbars when navigating from list screens
            final route = ModalRoute.of(context);
            if (route?.isCurrent != true) {
              return; // Don't show snackbar if route is not active
            }

            if (state is WishlistError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is WishlistItemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to wishlist'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is WishlistItemRemoved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removed from wishlist'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is WishlistItemToggled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isNowInWishlist
                        ? 'Added to wishlist'
                        : 'Removed from wishlist',
                  ),
                  backgroundColor: state.isNowInWishlist
                      ? Colors.green
                      : Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          // Use BLoC state if available, otherwise use initial product
          final Product product = state is ProductDetailLoaded
              ? state.product
              : initialProduct;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Scrollable content
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state is ProductDetailLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (state is ProductDetailError)
                        Center(
                          child: Text(
                            state.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Back button
                            // CircleAvatar(
                            //   backgroundColor: Colors.white,
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Icons.arrow_back_ios_new,
                            //       size: 18,
                            //     ),
                            //     onPressed: () => context.pop(context),
                            //   ),
                            // ),
                            // Wishlist button
                            // Note: Snackbar is handled by the top-level BlocListener to prevent duplicates
                            BlocBuilder<WishlistBloc, WishlistState>(
                              buildWhen: (previous, current) {
                                // Always rebuild on WishlistItemToggled for this product
                                if (current is WishlistItemToggled &&
                                    current.productId == product.id) {
                                  return true;
                                }

                                // Rebuild when transitioning to/from loaded states
                                if (current is WishlistLoaded ||
                                    current is WishlistLoadingMore ||
                                    current is WishlistRefreshing) {
                                  // Check if the status changed
                                  final bool? prevStatus =
                                      _ProductDetailContent._getWishlistStatus(
                                        previous,
                                        product.id,
                                      );
                                  final bool? currStatus =
                                      _ProductDetailContent._getWishlistStatus(
                                        current,
                                        product.id,
                                      );
                                  return prevStatus != currStatus;
                                }

                                return false;
                              },
                              builder: (context, wishlistState) {
                                // Get wishlist status - prioritize WishlistItemToggled state
                                // This ensures the icon updates immediately when toggled
                                bool isInWishlist = product.isFavorite;

                                // First, check if we have a toggled state for this product
                                // This takes priority because it's the most recent action
                                if (wishlistState is WishlistItemToggled &&
                                    wishlistState.productId == product.id) {
                                  isInWishlist = wishlistState.isNowInWishlist;
                                } else {
                                  // Otherwise, check loaded states for current status
                                  final status =
                                      _ProductDetailContent._getWishlistStatus(
                                        wishlistState,
                                        product.id,
                                      );
                                  if (status != null) {
                                    isInWishlist = status;
                                  }
                                }

                                return GestureDetector(
                                  onTap: () {
                                    context.read<WishlistBloc>().add(
                                      ToggleWishlist(
                                        productId: product.id,
                                        isCurrentlyInWishlist: isInWishlist,
                                        product: product,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 24,
                                      color: isInWishlist
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Image
                        Center(
                          child: SizedBox(
                            height: screenHeight * 0.25,
                            child: AppImage.network(
                              product.images.first,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/vegetables.png',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const SizedBox(height: 8),

                        // Price + Save info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// NAME + ADD BUTTON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// PRODUCT NAME + WEIGHT
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.measurement ?? 0} ${product.unit ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                 
                                /// ADD BUTTON
                                Flexible(
                                  flex: 0,
                                  child: BlocBuilder<CartBloc, CartState>(
                                    builder: (context, state) {
                                      final variants = product.variants ?? [];
                                      int count = 0;
                                      if (variants.isNotEmpty) {
                                        for (final v in variants) {
                                          count += state.quantities[v.id] ?? 0;
                                        }
                                      } else {
                                        count = state.quantities[product.id] ?? 0;
                                      }
                                  
                                      return AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: count == 0
                                            ? Container(
                                                key: const ValueKey('addBtn'),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.green,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: const Icon(
                                                      Icons.add,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                  onPressed: () {
                                    if (product.variants.isNotEmpty) {
                                      showVariantBottomSheet(product, context);
                                      return;
                                    }
                                  
                                    final int limit = product.stock < product.maxOrderQty
                                        ? product.stock
                                        : product.maxOrderQty;
                                  
                                    final cartState = context.read<CartBloc>().state;
                                    final int currentQty = cartState.quantities[product.id] ?? 0;
                                  
                                    if (currentQty >= limit) {
                                      GlobalSnackbar.show(
                                        'Maximum Quantity',
                                        'You can only order up to $limit units of this item.',
                                        isError: true,
                                        position: SnackPosition.bottom,
                                      );
                                      return; // no increment
                                    }
                                  
                                    context.read<CartBloc>().add(
                                      CartIncrement(
                                        id: product.id,
                                        productId: product.id,
                                        isVariant: false,
                                        quantity: product.minOrderQty,
                                        maxQty: limit,
                                      ),
                                    );
                                  },
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                key: const ValueKey('counter'),
                                                height: 35,
                                                width: 95,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (product
                                                            .variants
                                                            .isNotEmpty) {
                                                          showVariantBottomSheet(
                                                            product,
                                                            context,
                                                          );
                                                          return;
                                                        }
                                  
                                                        context
                                                            .read<CartBloc>()
                                                            .add(
                                                              CartDecrement(
                                                                id: product.id,
                                                                isVariant: false,
                                                              ),
                                                            );
                                                      },
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                          ),
                                                      child: Text(
                                                        '$count',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                    onTap: () {
                                    if (product.variants.isNotEmpty) {
                                      showVariantBottomSheet(product, context);
                                      return;
                                    }
                                  
                                    final int limit = product.stock < product.maxOrderQty
                                        ? product.stock
                                        : product.maxOrderQty;
                                  
                                    final cartState = context.read<CartBloc>().state;
                                    final int currentQty = cartState.quantities[product.id] ?? 0;
                                  
                                    if (currentQty >= limit) {
                                      GlobalSnackbar.show(
                                        'Maximum Quantity',
                                        'You can only order up to $limit units of this item.',
                                        isError: true,
                                        position: SnackPosition.bottom,
                                      );
                                      return; // no increment
                                    }
                                  
                                    context.read<CartBloc>().add(
                                      CartIncrement(
                                        id: product.id,
                                        productId: product.id,
                                        isVariant: false,
                                        quantity: product.minOrderQty,
                                        maxQty: limit,
                                      ),
                                    );
                                  },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// PRICE ROW
                            Row(
                              children: [
                                Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                if (product.mrp > product.price)
                                  Text(
                                    'Save ₹${(product.mrp - product.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (product.variants.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              showVariantBottomSheet(product, context);
                            },
                            child: Container(
                              height: 18,
                              width: double.infinity,
                              decoration:const BoxDecoration(
                                color: Color(0xFFDBFFD5),
                              ),
                              child: Center(
                                child: Text(
                                  '${product.variants.length} Options  >',
                                  style: const TextStyle(
                                    color: Color(0xFF00891D),
                                    fontWeight: FontWeight.w600,

                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Product Details
                        const Text(
                          'Product details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Html(
                          data:
                              product.description.toString() ??
                              'No description available',
                          style: {
                            'p': Style(
                              fontSize: FontSize(13),
                              color: Colors.black87,
                              lineHeight: const LineHeight(1.4),
                            ),
                          },
                        ),

                        const SizedBox(height: 16),

                        // Brand + Category + Unit
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _DetailTile(
                                title: 'Brand',
                                value: state is ProductDetailLoaded
                                    ? (state.product.brand?.name ?? 'N/A')
                                    : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _DetailTile(
                                title: 'Category',
                                value: state is ProductDetailLoaded
                                    ? state.product.category?.name ?? ''
                                    : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _DetailTile(
                                title: 'Units',
                                value:
                                    '${product.measurement ?? 0} ${product.unit ?? ''}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Rating Info
                        const Text(
                          'Product Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rating: ${state is ProductDetailLoaded ? state.product.rating.toStringAsFixed(1) : 'N/A'} ⭐ (${state is ProductDetailLoaded ? state.product.ratingCount : 0} reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stock Info
                        const Text(
                          'Stock Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state is ProductDetailLoaded
                              ? (state.product.inStock
                                    ? 'In Stock (${state.product.stock} available)'
                                    : 'Out of Stock')
                              : 'Stock info not available',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                state is ProductDetailLoaded &&
                                    state.product.inStock
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Warehouse
                        const Text(
                          'Warehouse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state is ProductDetailLoaded
                              ? state.warehouse.name
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 100),

                        ProductSuggestionsSection(
                          title: 'You might also like',
                          query: product.name,
                        ),
                      ],
                    ],
                  ),
                ),

                // Cart Bottom Bar
                const CartBottomBar(),

                // Back Button (moved inside the Stack for proper positioning)
                Positioned(
                  top: 36,
                  left: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => context.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
