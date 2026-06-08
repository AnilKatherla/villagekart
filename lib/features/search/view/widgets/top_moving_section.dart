// lib/features/search/widgets/top_moving_section.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';

class TopMovingSection extends StatefulWidget {
  const TopMovingSection({super.key, required this.products});
  final List<Product> products;
  @override
  State<TopMovingSection> createState() => _TopMovingSectionState();
}

class _TopMovingSectionState extends State<TopMovingSection> {
  final ScrollController _scrollController = ScrollController();
  double progress = 1;
  int totalItems = 1;

  @override
  void initState() {
    super.initState();

    totalItems = widget.products.length > 10 ? 10 : widget.products.length;

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      const double itemWidth = 93; // 81 card + 12 spacing
      final currentIndex = (_scrollController.offset / itemWidth).round();

      if (totalItems == 0) return;

      setState(() {
        progress = ((currentIndex + 1) / totalItems).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top moving',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Container(
              width: 44,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: totalItems == 1 ? 1 : progress.clamp(0.1, 1.0),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Show loading state or products
        widget.products.isEmpty
            ? const SizedBox.shrink()
            : _buildProductsList(context, widget.products),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 81,
            height: 91,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: products.length > 10 ? 10 : products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () async {
        // Navigate to product detail
        final savedLocation = await LocationService.getSavedLocation();
        final pincode = savedLocation?['pincode'] as String? ?? '';

        context.pushNamed(
          'proddetail',
          extra: {'product': product, 'pincode': pincode}
        );
        
      },
      child: Container(
        width: 81,
        height: 91,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey, width: 2),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.01),
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Product Image
            product.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.images.first,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                    placeholder: (context, url) {
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
            const SizedBox(height: 8),
            // Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,

                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:villag_kart/core/theme/colors.dart';
// import 'package:villag_kart/features/search/view/widgets/top_moving_card.dart';

// class TopMovingSection extends StatefulWidget {
//   const TopMovingSection({super.key});

//   @override
//   State<TopMovingSection> createState() => _TopMovingSectionState();
// }

// class _TopMovingSectionState extends State<TopMovingSection> {
//   final List<Map<String, dynamic>> _topMoving = const [
//     {'name': 'Onions', 'color': AppColors.white, 'icon': 'assets/images/onion.png'},
//     {'name': 'Fenugreek', 'color': AppColors.white, 'icon': 'assets/images/beetroot.png'},
//     {'name': 'Beetroot', 'color': AppColors.white, 'icon': 'assets/images/fenugreek.png'},
//     {'name': 'Brinjal', 'color': AppColors.white, 'icon': 'assets/images/brinjal.png'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Top moving',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//             ),
//             Container(
//               width: 80,
//               height: 8,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEEF2FF),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Container(
//                   width: 28,
//                   height: 4,
//                   margin: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: AppColors.green,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 120,
//           child: ListView.separated(
//             physics: const AlwaysScrollableScrollPhysics(),
//             scrollDirection: Axis.horizontal,
//             itemCount: _topMoving.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               final item = _topMoving[index];
//               return TopMovingCard(
//                 name: item['name'],
//                 bgColor: item['color'],
//                 icon: item['icon']
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
