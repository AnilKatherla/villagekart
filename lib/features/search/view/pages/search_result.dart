import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';
import 'package:villag_kart/features/search/bloc/search_bloc.dart';
import 'package:villag_kart/features/search/bloc/search_event.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.products,
    required this.query,
  });

  final List<Product> products;
  final String query;

  @override
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per row
        crossAxisSpacing: 20,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80, // adjust card height
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          warehouseId: '', // pass your warehouseId here
          onTap: () async {
            context.read<SearchBloc>().add(AddRecentSearch(product.name));

            final savedLocation = await LocationService.getSavedLocation();
            final pincode = savedLocation?['pincode'] as String? ?? '';

            context.pushNamed(
              'proddetail',
              extra: {'prod': product, 'pincode': pincode},
            );
            context.read<SearchBloc>().add(ClearSearchResults());
          },
        );
      },
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () async {
        context.read<SearchBloc>().add(AddRecentSearch(product.name));

        final savedLocation = await LocationService.getSavedLocation();
        final pincode = savedLocation?['pincode'] as String? ?? '';

        // 👉 WAIT for navigation
        context.pushNamed(
          'proddetail',
          extra: {'prod': product, 'pincode': pincode},
        );

        // 🔥 RESET WHEN BACK
        context.read<SearchBloc>().add(ClearSearchResults());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.shopping_bag,
                            color: Colors.grey[400],
                            size: 32,
                          );
                        },
                      ),
                    )
                  : Icon(Icons.shopping_bag, color: Colors.grey[400], size: 32),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Product Unit
                  Text(
                    product.unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // Price Row
                  Row(
                    children: [
                      // Current Price
                      Text(
                        product.price.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // MRP (strikethrough)
                      if (product.discount > 0)
                        Text(
                          product.mrp.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),

                      // Add to Cart Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Discount Badge
                  if (product.discount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Save ${product.discount.toString()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
