import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_bloc.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_event.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_state.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';
import 'package:villag_kart/features/cart/widgets/cart_item_row.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/sections/Product_suggestions_section.dart';
import 'package:villag_kart/features/shop/view/shop_screen.dart';
import '../widgets/out_of_stock_banner.dart';
import '../widgets/savings_banner.dart';
import '../widgets/promocode_row.dart';
import '../widgets/bill_details_card.dart';

class ReviewItemsPage extends StatefulWidget {
  ReviewItemsPage({super.key, this.onBack});
  final VoidCallback? onBack;
  final TextEditingController _instruction = TextEditingController();

  @override
  State<ReviewItemsPage> createState() => _ReviewItemsPageState();
}

class _ReviewItemsPageState extends State<ReviewItemsPage> {
  final FocusNode _instructionFocus = FocusNode();
  // Promo code value (example)
  CouponModel? appliedCoupon;

  // Compute subtotal = items total - promo
  double promo = 0;

  bool showInstructions = false;

  ///  Calculate promo correctly
  double _calculatePromo(CouponModel coupon, double cartTotal) {
    if (coupon.type == 'FLAT') {
      return coupon.value.toDouble();
    }

    if (coupon.type == 'PERCENT') {
      final discount = (cartTotal * coupon.value) / 100;
      if (coupon.maxDiscount != null) {
        return discount > coupon.maxDiscount!
            ? coupon.maxDiscount!.toDouble()
            : discount;
      }
      return discount;
    }

    return 0;
  }

  double _computeSubTotal(double itemsTotal) {
    return itemsTotal - promo;
  }

  @override
  void dispose() {
    _instructionFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _instructionFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }
          ],
        ),
      ],
    );
  }
  @override
// void initState() {
//   super.initState();

//   final pincode =
//       context.read<HomeBloc>().state.pincode ?? '';

//   context.read<PromoCodeBloc>().add(
//         FetchCouponsEvent(pincode: pincode),
//       );
// }

  // Open Delivery Options Screen and pass subtotal & promo

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CartError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async =>
                        context.read<CartBloc>().add(FetchCartItemsEvent(warehouseId: await SharedPrefs.getWarehouseId())),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.cartItems.isEmpty) {
          return ShopScreen(
            onStartShopping: () {
              context.go('home', extra: {'tabIndex': 1});
            },
          );
        }

        final itemsTotal = state.totalPrice;

        /// ✅ Re-check promo eligibility
        if (appliedCoupon != null &&
            itemsTotal < appliedCoupon!.minOrderValue) {
          promo = 0;
          appliedCoupon = null;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Promo code removed due to cart value change'),
              ),
            );
          });
        }

        final cartItems = state.cartItems;
        final quantities = state.quantities;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: widget.onBack ?? () => context.pop(),
            ),
            title: const Text(
              'Review Items',
              style: TextStyle(color: Colors.black),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
           child: PrimaryButton(
             onPressed: cartItems.isEmpty
                  ? null
                  : () {
                      final String? couponCode = appliedCoupon?.code;
                      final double taxes = state.summary?.taxAmount ?? 0.0;
                      final instruction = widget._instruction.text.trim();
                      context.push(
                        '/deliveryOptions',
                        extra: {
                          'itemsTotal': itemsTotal,
                          'promo': promo,
                          'taxes': taxes,
                          'instruction': instruction,
                          'couponCode': couponCode,

                        },
                      );
                    },
                    label: 'Checkout',
            ),
          ),
          backgroundColor: AppColors.white,
          body: KeyboardActions(
            config: _buildConfig(context),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
              if (state.hasOutOfStock) const OutOfStockBanner(),
              const SavingsBanner(),
              const SizedBox(height: 12),

              if (state.totalItems > 0)
                ...cartItems.where((item) => item.quantity > 0).map((item) {
                  final key = item.productVariantId ?? item.product?.id ?? '';

                  return Column(
                    children: [
                      Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) {
                          context.read<CartBloc>().add(CartItemRemove(item.id));
                        },
                        child: CartItemTile(
                          cartItem: item,
                          quantity: item.quantity,
                          onIncrement: () {
                            context.read<CartBloc>().add(
                              CartIncrement(
                                id: key,
                                isVariant: item.productVariantId != null,
                                productId: item.product?.id,
                              ),
                            );
                          },
                          onDecrement: () {
                            context.read<CartBloc>().add(
                              CartDecrement(
                                id: key,
                                isVariant: item.productVariantId != null,
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 6),
                    ],
                  );
                }),

              const SizedBox(height: 12),

              /// PROMOCODE
             BlocBuilder<PromoCodeBloc, PromoCodeState>(
  builder: (context, promoState) {
    
    // Loading → hide or show shimmer (optional)
    if (promoState is PromoCodeLoading) {
      return const SizedBox();
    }

    // Empty → DO NOT SHOW
    if (promoState is PromoCodeEmpty) {
      return const SizedBox();
    }

    // Failure → DO NOT SHOW (or show retry if you want)
    if (promoState is PromoCodeFailure) {
      return const SizedBox();
    }

    // Success → SHOW ONLY IF DATA EXISTS
    if (promoState is PromoCodeSuccess) {
      if (promoState.allCoupons.isEmpty) {
        return const SizedBox();
      }

      return PromocodeRow(
        cartValue: itemsTotal,
        onCouponApplied: (coupon, discount) {
          setState(() {
            appliedCoupon = coupon;
            promo = discount;
          });
        },
      );
    }

    return const SizedBox();
  },
),

              const SizedBox(height: 12),
              const ProductSuggestionsSection(),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    showInstructions = !showInstructions;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      showInstructions ? Icons.close : Icons.add,
                      color: showInstructions
                          ? Colors.black
                          : Color(0xFF00891D),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Instructions',
                      style: TextStyle(
                        fontSize: 14,
                        color: showInstructions
                            ? Colors.black
                            : Color(0xFF00891D),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              if (showInstructions)
                SizedBox(
                  height: 94,
                  width: double.infinity,
                  child: TextField(
                    controller: widget._instruction,
                    focusNode: _instructionFocus,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF), // grey background

                      contentPadding: const EdgeInsets.all(12),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFEFEFEF),
                          width: 1,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFEFEFEF),
                          width: 1,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFEFEFEF),
                          width: 1,
                        ),
                      ),

                      hintText: 'Add instructions...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Bill Details (only items & promo)
              BillDetailsCard(
                itemsTotal: itemsTotal,
                promo: promo,
                delivery: 0,
                taxes: 0,
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
