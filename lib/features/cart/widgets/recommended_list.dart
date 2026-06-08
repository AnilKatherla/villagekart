import 'package:flutter/material.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import '../../../../core/widgets/app_image.dart';

class RecommendedList extends StatelessWidget {
  const RecommendedList({super.key, this.recommendations = const []});
  final List<Product> recommendations;

  @override
  Widget build(BuildContext context) {
    final List items = [];

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = items[i];

          return Container(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Center(
                      child: SizedBox(
                        height: 60,
                        child: p.assetPath != null
                            ? AppImage.asset(p.assetPath!)
                            : const Icon(Icons.local_grocery_store, size: 50),
                      ),
                    ),

                    const SizedBox(height: 8),

                    
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      p.weight ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    
                    Row(
                      children: [
                        Text(
                          '₹${p.price.truncate()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${p.oldPrice?.truncate()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Save ₹${p.discount.truncate()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

               
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.green),
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
