import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/search/view/widgets/VariantBottomSheet.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    required this.warehouseId,
    this.shrinkText = false,
  });

  final Product product;
  final VoidCallback? onTap;
  final String warehouseId;
  final bool shrinkText;

  @override
  Widget build(BuildContext context) {
    final bool outOfStock = product.stock == 0;

    final double oldPrice = product.mrp;
    final double newPrice = product.price;
    final double discountPercent = (oldPrice > 0 && oldPrice > newPrice)
        ? ((oldPrice - newPrice) / oldPrice * 100)
        : product.discount;

    return InkWell(
      onTap: outOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // ✅ Main Product Layout
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product image
                  Expanded(flex: 4, child: _buildProductImage()),

                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        product.variants.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  showVariantBottomSheet(product, context);
                                },
                                child: Container(
                                  height: 18,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${product.variants.length} '
                                      '${product.variants.length == 1 ? 'Option' : 'Options'} >',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const Spacer(),
                        // Name + Favorite icon
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductNameAndFavorite(),
                              _buildMeasurementInfo(),
                              SizedBox(height: 2.h),
                              _buildPriceRow(oldPrice, newPrice),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Discount badge
            if (discountPercent > 0) _buildDiscountBadge(discountPercent),
            const SizedBox(height: 6),

            // ✅ Right-side + Button / Counter
            if (!outOfStock) _buildAddCounterButton(),

            // ✅ Out of Stock overlay
            if (outOfStock) _buildOutOfStockOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(double discountPercent) {
    return Align(
      alignment: Alignment.topLeft,
      child: AppBadge(
        label: (() {
          if (discountPercent % 1 == 0) {
            return '${discountPercent.toInt()}% off';
          }
          return '${discountPercent.toStringAsFixed(2)}% off';
        })(),
        backgroundColor: AppColors.orange,
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.images.isNotEmpty
              ? AppImage.network(
                  product.images.first,
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset(
                        'assets/images/villagekart_logo.svg',
                        fit: BoxFit.cover,
                      ),
                )
              : SvgPicture.asset(
                  'assets/images/villagekart_logo.svg',
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildProductNameAndFavorite() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _WishlistIconButton(
          productId: product.id,
          initialWishlistStatus: product.isFavorite,
          product: product, // Pass the full product for wishlist toggling
        ),
      ],
    );
  }

  Widget _buildMeasurementInfo() {
    if (product.measurement == null) {
      return const SizedBox.shrink();
    }
    return Text(
      '${product.measurement.toString() ?? '0'} ${product.unit ?? ''}',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: const TextStyle(fontSize: 12, color: Color(0xFF8B8B8B)),
    );
  }

  String _formatPrice(double price) {
    return price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
  }

  Widget _buildPriceRow(double oldPrice, double newPrice) {
    return Column(
      children: [
        Row(
          children: [
            if (oldPrice > newPrice) ...[
              Text(
                'Rs.${_formatPrice(newPrice)}',
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              AutoSizeText(
                _formatPrice(oldPrice),
                maxLines: 1,
                minFontSize: 6,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ] else ...[
              Flexible(
                child: AutoSizeText(
                  'Rs.${_formatPrice(newPrice)}',
                  maxLines: 1,
                  minFontSize: 8,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            minFontSize: 9,

            'Save ₹${product.savedAmount.toStringAsFixed(2)}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 10, color: AppColors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCounterButton() {
    return Positioned(
      top: 7,
      right: 3,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int count = 0;
          if (state is CartLoadedState) {
            count = _getProductCartCount(product, state);
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: count == 0
                ? GestureDetector(
                    key: const ValueKey('addBtn'),
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
      'Max Limit',
      'You reached max limit to $limit units of this item.',
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(shrinkText ? 4 : 6),
                        border: Border.all(color: AppColors.green),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.add,
                        color: AppColors.green,
                        size: shrinkText ? 16 : 18,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('counter'),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(shrinkText ? 12 : 20),
                    ),
                    padding: shrinkText
                        ? const EdgeInsets.symmetric(horizontal: 2)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: shrinkText ? 28 : 32,
                          height: shrinkText ? 28 : 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: shrinkText ? 16 : 18,
                            ),
                            onPressed: () {
                              if (product.variants.isNotEmpty) {
                                showVariantBottomSheet(product, context);
                                return;
                              }

                              context.read<CartBloc>().add(
                                CartDecrement(id: product.id, isVariant: false),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: shrinkText ? 4 : 6,
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: shrinkText ? 14 : 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: shrinkText ? 28 : 32,
                          height: shrinkText ? 28 : 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: shrinkText ? 16 : 18,
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
      'Max Limit',
      'You reached max limit $limit units of this item.',
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
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildOutOfStockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: AppChip(
                label: 'Out of Stock',
                backgroundColor: Colors.white,
                onTap: () {},
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                'Notify Me',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getProductCartCount(Product product, CartLoadedState state) {
    int total = 0;

    /// No variants → product itself
    if (product.variants.isEmpty) {
      return state.quantities[product.id] ?? 0;
    }

    /// Sum all variant counts
    for (final variant in product.variants) {
      total += state.quantities[variant.id] ?? 0;
    }

    return total;
  }
}

/// Isolated wishlist icon button that only rebuilds itself when wishlist state changes
/// This prevents all product cards from rebuilding when one wishlist item changes
class _WishlistIconButton extends StatelessWidget {
  const _WishlistIconButton({
    required this.productId,
    this.initialWishlistStatus = false,
    required this.product,
  });

  final String productId;
  final bool initialWishlistStatus;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        bool isInWishlist = false; // <-- IMPORTANT FIX

        // First, check if we have a toggled state for this product
        // This takes priority because it's the most recent action
        if (wishlistState is WishlistItemToggled &&
            wishlistState.productId == productId) {
          isInWishlist = wishlistState.isNowInWishlist;
        } else {
          // Otherwise, check loaded states for current status
          if (wishlistState is WishlistLoaded) {
            isInWishlist = wishlistState.wishlistItems.any(
              (item) => item.productId == productId,
            );
          } else if (wishlistState is WishlistRefreshing) {
            isInWishlist = wishlistState.wishlistItems.any(
              (item) => item.productId == productId,
            );
          } else if (wishlistState is WishlistLoadingMore) {
            // During loading, maintain wishlist status from items
            isInWishlist = wishlistState.wishlistItems.any(
              (item) => item.productId == productId,
            );
          }
        }

        return GestureDetector(
          onTap: () {
            context.read<WishlistBloc>().add(
              ToggleWishlist(
                productId: productId,
                isCurrentlyInWishlist: isInWishlist,
                product: product,
              ),
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              //  borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border_outlined,
              size: 20,
              color: isInWishlist ? Colors.red : const Color(0xFF292D32),
            ),
          ),
        );
      },
    );
  }
}

// Helper class (add this if not exists)
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
