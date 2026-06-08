import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/cart/model/VariantModel.dart';

void showVariantBottomSheet(Product product, BuildContext context) {
  final variants = product.variants;

  if (variants.isEmpty) {
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return BlocProvider.value(
        value: context.read<CartBloc>(), // 🔥 SAME INSTANCE
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Variants list
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: variants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final variant = variants[index];

                        return _VariantTile(product: product, variant: variant);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({required this.product, required this.variant});

  final Product product;
  final VariantModel variant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (previous, current) {
        if (previous is CartLoadedState && current is CartLoadedState) {
          return previous.getCount(variant.id) != current.getCount(variant.id);
        }
        return true;
      },
      builder: (context, state) {
        int qty = 0;
        if (state is CartLoadedState) {
          qty = state.getCount(variant.id);
        }

        final double price = variant.price;
        final double mrp = variant.mrp;
        final double save = (mrp > price) ? (mrp - price) : 0;

        final imageUrl = variant.images.isNotEmpty
            ? variant.images.first
            : (product.images.isNotEmpty ? product.images.first : '');

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              /// PRODUCT IMAGE
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 70,
                        width: 70,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/browse-group-1.png',
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// OFFER BADGE (Optional)
                  if (save > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Up to 10% off',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              /// DETAILS SECTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Variant Name (2 Kg)
                    Text(
                      variant.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Price Row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          '₹ $price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (save > 0)
                          Text(
                            '₹ $mrp',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),

                    /// Save Text
                    if (save > 0)
                      Text(
                        'Save ₹${save.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              /// ADD / STEPPER BUTTON
              qty == 0
                  ? Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add, color: Colors.green),
                       onPressed: () {
  final int minQty = variant.minOrderQty;
  final int maxQty = variant.maxOrderQty;
  final int stock = variant.stock;
  final int currentQty = qty;

  final int limit = stock < maxQty ? stock : maxQty;

  if (currentQty >= limit) {
        GlobalSnackbar.show('','Maximum quantity is $limit reached',position: SnackPosition.top,isError: true);
    return;
  }

  context.read<CartBloc>().add(
    CartIncrement(
      id: variant.id,
      isVariant: true,
      productId: product.id,
      quantity: minQty,
      maxQty: limit,
    ),
  );
},
                      ),
                    )
                  : Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {
                                context.read<CartBloc>().add(
                                  CartDecrement(
                                    id: variant.id,
                                    isVariant: true,
                                    productId: product.id,
                                    minQty: variant.minOrderQty,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              qty.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                             onPressed: () {
  final int currentQty = qty;
  final int limit = variant.stock < variant.maxOrderQty
      ? variant.stock
      : variant.maxOrderQty;

  if (currentQty >= limit) {
    GlobalSnackbar.show('','Maximum quantity is $limit reached',position: SnackPosition.top,isError: true);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'Maximum allowed quantity is $limit',
    //     ),
    //   ),
    // );
    return;
  }

  context.read<CartBloc>().add(
    CartIncrement(
      id: variant.id,
      isVariant: true,
      productId: product.id,
      quantity: variant.minOrderQty,
      maxQty: limit,
    ),
  );
},
                            ),
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
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              qty.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
