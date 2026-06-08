import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/app_image.dart';
import 'package:villag_kart/features/cart/model/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel cartItem;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final outOfStock = cartItem.isOutOfStock ?? false;
    final unitPrice = cartItem.product?.price ?? 0;
    final totalForThisItem = unitPrice * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage.network(
                cartItem.product?.images.first ?? '',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Product name, price, weight
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product?.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      '₹${unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),

                    if ((cartItem.product?.mrp ?? 0) > unitPrice)
                      Text(
                        '₹${cartItem.product?.mrp.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  cartItem.product?.unit ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Quantity control + item total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!outOfStock)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          debugPrint('Decrement tapped');
                          onDecrement();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      InkWell(
                        onTap: onIncrement,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              Text(
                '₹${totalForThisItem.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
