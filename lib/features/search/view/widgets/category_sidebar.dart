import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/widgets/custom_appbar/custom_app_bar.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import '../../../../core/theme/colors.dart';
import '../../controller/search_controller.dart';

class CategorySidebar extends StatelessWidget {
  // Add callback

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.pincode,
    required this.selectedCategoryId, // Make it required
    required this.onCategorySelected, // Make it required
  });
  final List<CategoryModel> categories;
  final String pincode;
  final String? selectedCategoryId; // Add selected category parameter
  final Function(String, String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchViewController, void>(
      builder: (context, state) {
        final controller = context.read<SearchViewController>();

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            // Use both controller state and local state for selection
            final isSelected =
                selectedCategoryId == category.id ||
                controller.selectedCategory == category.id;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () {
                  // Use the callback instead of directly handling the logic
                  onCategorySelected(category.id, category.name);
                  CustomAppBar(
                    title: category.name,
                    showBackButton: true,
                    onSearchTap: () {
                      context.pushReplacementNamed('/search');
                    },
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 85,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category.name),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.green
                              : AppColors.grey.withOpacity(0.4),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 38,
                            width: 43,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildCategoryImage(category),
                            ),
                          ),

                          const SizedBox(height: 2),

                          SizedBox(
                            height: 20,
                            child: Text(
                              category.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                height: 1.1,
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.black.withOpacity(0.8),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
          },
        );
      },
    );
  }

  // /// Handles both IconData and String icons gracefully
  // Widget _buildCategoryIcon(dynamic icon) {
  //   if (icon == null) {
  //     return const Icon(Icons.category, color: AppColors.green);
  //   }

  //   if (icon is IconData) {
  //     return Icon(icon, color: AppColors.green);
  //   }

  //   if (icon is String) {
  //     // If it's a string, try to load as asset image
  //     return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Image.asset(
  //         icon,
  //         fit: BoxFit.contain,
  //         errorBuilder: (context, _, __) =>
  //             const Icon(Icons.category, color: AppColors.green),
  //       ),
  //     );
  //   }

  //   return const Icon(Icons.category, color: AppColors.green);
  // }
  Color _getCategoryColor(String categoryName) {
    final colors = [
      const Color(0xFFFAE5E5),
      const Color(0xFFFDF4F9),
      const Color(0xFFFFF3EF),
      const Color(0xFFE2FDEA),
      const Color(0xFFF5FFF8),
      const Color(0xFFFDF4F4),
      const Color.fromARGB(255, 248, 249, 251),
    ];

    final index = categoryName.hashCode % colors.length;
    return colors[index.abs()];
  }

  Widget _buildCategoryImage(CategoryModel item) {
    final image = item.image?.toString() ?? '';

    try {
      if (image.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: image,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            width: 35,
            height: 35,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, _, __) =>
              const Icon(Icons.category, color: AppColors.green),
        );
      }

      if (image.startsWith('data:image') || image.length > 100) {
        Uint8List bytes = base64Decode(image.split(',').last);

        return Image.memory(bytes, width: 35, height: 35, fit: BoxFit.cover);
      }

      return Image.asset(
        image.isNotEmpty ? image : 'assets/images/cat-1.png',
        width: 58,
        height: 43,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) =>
            const Icon(Icons.category, color: AppColors.green),
      );
    } catch (e) {
      return const Icon(Icons.category, color: AppColors.green);
    }
  }
}
