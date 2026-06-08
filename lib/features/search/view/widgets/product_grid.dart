// features/search/view/widgets/product_grid.dart (Updated)
import 'package:flutter/material.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.warehouseId,
    this.onProductTap,
  });
  final List<Product> products;
  final String warehouseId;
  final void Function(Product)? onProductTap;

  @override
  Widget build(BuildContext context) {
    // Calculate responsive aspect ratio based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = 0.76;
    if (screenWidth < 360) {
      aspectRatio = 0.74;
    } else if (screenWidth > 400) {
      aspectRatio = 0.78;
    }

    return Stack(
      children: [
        if (products.isEmpty)
          const Center(
            child: Text(
              'No products found',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          )
        else
          GridView.builder(
            itemCount: products.length,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 12,
              childAspectRatio: 0.61,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                warehouseId: warehouseId,
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
      ],
    );
  }
}
