import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/app_typography.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/core/widgets/cart_bottom_bar.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/cart/model/create_order_pickup_model.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';
import 'package:villag_kart/features/wishlist/model/wishlist_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String warehouseId = '';
  @override
  void initState() {
    super.initState();
    // Fetch wishlist when screen loads using global bloc
    context.read<WishlistBloc>().add(FetchWishlist());

    SharedPrefs.getWarehouseId().then((id) {
      setState(() {
        warehouseId = id ?? '';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(context),
        ),
        title: const Text('Wishlist', style: AppTypography.heading),
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocBuilder<WishlistBloc, WishlistState>(
                  builder: (context, state) {
                    if (state is WishlistLoading) {
                      return _buildLoadingState();
                    }

                    if (state is WishlistError) {
                      return _buildErrorState(state.errorMessage);
                    }

                    if (state is WishlistEmpty) {
                      return Expanded(child: _buildEmptyState());
                    }

                    if (state is WishlistLoaded ||
                        state is WishlistRefreshing ||
                        state is WishlistLoadingMore) {
                      // Extract items from different state types
                      List<WishlistItem> items = [];
                      String? removingProductId;

                      if (state is WishlistLoaded) {
                        items = state.wishlistItems;
                      } else if (state is WishlistRefreshing) {
                        items = state.wishlistItems;
                      } else if (state is WishlistLoadingMore) {
                        items = state.wishlistItems;
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<WishlistBloc>().add(RefreshWishlist());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 0.58,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return ProductCard(
                                product: item.product,
                                warehouseId: warehouseId,
                                onTap: () {
                                  final pincode =
                                      context.read<HomeBloc>().state.pincode ??
                                      '';

                                  context.pushNamed(
                                    'proddetail',
                                    extra: {
                                      'prod': item.product,
                                      'pincode': pincode,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }

                    return Center(child: _buildEmptyState());
                  },
                ),
              ),
            ],
          ),
          const CartBottomBar(),
        ],
      ),
    );
  }

  // ============================= LOADING STATE =============================
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================= EMPTY STATE =============================
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 60),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/empty_wishlist.svg',
              width: 240,
              height: 190,
            ),
            const SizedBox(height: 42),
            Text(
              'Your Wishlist is Empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Save Items that you like in your wishlist\n And Move them to your Cart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              onPressed: () {
                final homeState = context.read<HomeBloc>().state;
                final pincode = homeState.pincode!;

                final categoryState = context.read<CategoryBloc>().state;
                final List<CategoryModel> allCategories = [
                  if (categoryState is CategoryLoaded)
                    ...categoryState.categories,
                ];

                if (allCategories.isNotEmpty) {
                  final firstCategory = allCategories.first;
                  context.pushNamed(
                    'searchrail',
                    extra: {
                      'categoryId': firstCategory.id,
                      'categoryName': firstCategory.name,
                      'pincode': pincode,
                      'allCategories': allCategories,
                    },
                  );
                } else {
                  debugPrint('Categories not loaded yet');
                }
              },
              label: 'Start Shopping',
            ),
          ],
        ),
      ),
    );
  }

  // ============================= ERROR STATE =============================
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<WishlistBloc>().add(FetchWishlist());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================= WISHLIST CARD =============================
  Widget _buildWishlistCard({
    required WishlistItem item,
    required bool isRemoving,
    required VoidCallback onRemove,
  }) {
    final bool outOfStock =
        item.product.stock == 0; // change if stock path different

    return GestureDetector(
      onTap: outOfStock
          ? null
          : () {
              final pincode = context.read<HomeBloc>().state.pincode ?? '';
              context.pushNamed(
                'proddetail',
                extra: {'prod': item.product, 'pincode': pincode},
              );
            },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// OFFER TAG
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.discountOffer,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// PRODUCT IMAGE
                      Expanded(
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: item.productImage,
                            fit: BoxFit.cover,
                            height: 45,
                            placeholder: (context, url) => const SizedBox(
                              height: 45,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                'assets/images/vegetables.png',
                                fit: BoxFit.cover,
                                height: 45,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// PRODUCT NAME
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        item.unit,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 2),

                      /// PRICE ROW
                      Row(
                        children: [
                          Text(
                            item.formattedPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 3),
                          if (item.isOnSale)
                            Text(
                              item.formattedOriginalPrice,
                              style: const TextStyle(
                                color: AppColors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      if (item.isOnSale)
                        Text(
                          item.formattedSavings,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                /// ADD / COUNTER BUTTON
                Positioned(
                  top: 4,
                  right: 4,
                  child: Column(
                    children: [
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, state) {
                          final int count =
                              state.quantities[item.productId] ?? 0;

                          /// OUT OF STOCK BUTTON
                          if (outOfStock) {
                            return Container(
                              height: 26,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  'Out',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }

                          /// NORMAL ADD BUTTON
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: count == 0
                                ? Container(
                                    key: const ValueKey('addBtn'),
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.green,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.white,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        context.read<CartBloc>().add(
                                          CartIncrement(id: item.productId),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.green,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('counter'),
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            context.read<CartBloc>().add(
                                              CartDecrement(
                                                id: item.productId,
                                                isVariant: false,
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            context.read<CartBloc>().add(
                                              CartIncrement(id: item.productId),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// OUT OF STOCK OVERLAY
          /// OUT OF STOCK UI (IMAGE STYLE)
          if (outOfStock)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// OUT OF STOCK BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

          /// ❤️ REMOVE FROM WISHLIST
          Positioned(
            top: 34,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.favorite,
                color: AppColors.orange,
                size: 18,
              ),
            ),
          ),

          /// REMOVING LOADER
          if (isRemoving)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
