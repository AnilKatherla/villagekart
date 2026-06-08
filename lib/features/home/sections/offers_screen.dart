// offers_screen.dart (Updated with favorite icon below add cart icon)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/widgets/cart_bottom_bar.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_event.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_event.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_state.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/core/widgets/custom_appbar/custom_app_bar.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/wishlist/bloc/wishlist_state.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key, required this.pincode});
  final String pincode;

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final ScrollController _scrollController = ScrollController();
 

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final bloc = context.read<OffersBloc>();

    if (bloc.state is! OffersLoaded) {
      bloc.add(FetchOffers(pincode: widget.pincode));
    }
  });

  _scrollController.addListener(_onScroll);
}

  @override
  void dispose() {
    _scrollController.dispose();
   
    super.dispose();
  }

 void _onScroll() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    context.read<OffersBloc>().add(
      LoadMoreOffers(pincode: widget.pincode),
    );
  }
}

 @override
Widget build(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: context.read<OffersBloc>()),
      BlocProvider.value(value: context.read<WishlistBloc>()),
    ],
    child: _OffersScreenContent(
      scrollController: _scrollController,
      pincode: widget.pincode,
    ),
  );
}
}

class _OffersScreenContent extends StatefulWidget {
  const _OffersScreenContent({
    required this.scrollController,
    required this.pincode,
  });
  final ScrollController scrollController;
  final String pincode;

  @override
  State<_OffersScreenContent> createState() => _OffersScreenContentState();
}

class _OffersScreenContentState extends State<_OffersScreenContent> {
  @override
  void initState() {
    super.initState();
    // Refresh wishlist when screen is first built to get latest state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WishlistBloc>().add(RefreshWishlist());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh wishlist when returning to this screen (e.g., from product detail)
    // This ensures UI is updated with latest wishlist state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final wishlistState = context.read<WishlistBloc>().state;
        // Only refresh if we don't have a loaded state or if it's been a while
        if (wishlistState is! WishlistLoaded &&
            wishlistState is! WishlistEmpty) {
          context.read<WishlistBloc>().add(RefreshWishlist());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistBloc, WishlistState>(
      listenWhen: (previous, current) {
        // Listen to snackbar-triggering states and loaded states
        return current is WishlistItemAdded ||
            current is WishlistItemRemoved ||
            current is WishlistItemToggled ||
            current is WishlistError ||
            current is WishlistLoaded ||
            current is WishlistEmpty;
      },
      listener: (context, wishlistState) {
        // Only show snackbar if this screen is currently active (visible)
        // This prevents duplicate snackbars when navigating to product detail
        final route = ModalRoute.of(context);
        final isRouteActive = route?.isCurrent ?? false;
        final isRoutePopped = route?.isActive == false;

        // Don't show snackbar if route is not active or has been popped
        if (!isRouteActive || isRoutePopped) {
          // Screen is not active, only update state without showing snackbar
          if (wishlistState is WishlistLoaded ||
              wishlistState is WishlistEmpty ||
              wishlistState is WishlistItemToggled) {
            if (mounted) {
              setState(() {});
            }
          }
          return;
        }

        // Show snackbar for wishlist actions (only when screen is active)
        if (wishlistState is WishlistItemAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to wishlist'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (wishlistState is WishlistItemRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from wishlist'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (wishlistState is WishlistItemToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wishlistState.isNowInWishlist
                    ? 'Added to wishlist'
                    : 'Removed from wishlist',
              ),
              backgroundColor: wishlistState.isNowInWishlist
                  ? Colors.green
                  : Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (wishlistState is WishlistError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(wishlistState.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Trigger rebuild when wishlist state changes to update UI
        if (wishlistState is WishlistLoaded ||
            wishlistState is WishlistEmpty ||
            wishlistState is WishlistItemToggled) {
          // This will trigger a rebuild with updated wishlist status
          setState(() {});
        }
      },
      child: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Exclusive Offers',
              showBackButton: true,
            ),
            body: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, OffersState state) {
    if (state is OffersLoading) {
      return _buildLoading();
    }

    if (state is OffersError) {
      return _buildError(state.errorMessage);
    }

    if (state is OffersEmpty) {
      return _buildEmpty(state.message);
    }

    List<Product> products = [];
    bool isLoadingMore = false;
    bool hasReachedMax = false;
    String warehouseId = ''; // Add this

    if (state is OffersLoaded) {
      products = state.products;
      hasReachedMax = state.hasReachedMax;
      warehouseId = state.warehouse.id; // Get warehouse ID
    } else if (state is OffersRefreshing) {
      products = state.products;
      hasReachedMax = state.hasReachedMax;
      warehouseId = state.warehouse.id; // Get warehouse ID
    } else if (state is OffersLoadingMore) {
      products = state.products;
      isLoadingMore = true;
      hasReachedMax = state.hasReachedMax;
      warehouseId = state.warehouse.id; // Get warehouse ID
    }

    return Stack(
      children: [
        _buildProductGrid(
          context,
          products,
          warehouseId,
          hasReachedMax,
        ), // Pass warehouseId
      ],
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    List<Product> products,
    String warehouseId,
    bool hasReachedMax,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final position = widget.scrollController.position;
          if (position.pixels == position.maxScrollExtent && !hasReachedMax) {
            context.read<OffersBloc>().add(
              LoadMoreOffers(pincode: widget.pincode),
            );
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.55,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                product: product,
                warehouseId:warehouseId,
                onTap: () => _navigateToProductDetail(context, product),
                shrinkText: true,
              );// Pass warehouseId
                },
              ),
              // if (hasReachedMax && products.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 20),
              //     child: Text(
              //       'No more offers',
              //       style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              //     ),
              //   ),
             // const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      
    );
  }


  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, color: Colors.grey.shade200),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
                      width: 50,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 35,
                          color: Colors.grey.shade200,
                        ),
                        const Spacer(),
                        Container(
                          height: 8,
                          width: 25,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
          const SizedBox(height: 16),
          Text(
            'Failed to load offers',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.red.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<OffersBloc>().add(
                FetchOffers(pincode: widget.pincode),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            color: Colors.grey.shade400,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'No Offers Available',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
 void _navigateToProductDetail(BuildContext context, Product product) {
  final pincode = context.read<HomeBloc>().state.pincode ?? '';

  context.pushNamed(
    'proddetail',
    extra: {
      'prod': product,
      'pincode': pincode,
    },
  );
}
}
