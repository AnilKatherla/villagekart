import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';
import 'package:villag_kart/features/search/view/pages/search_product_rail.dart';
import '../../../../core/theme/colors.dart';
import 'group_card.dart';

class BrowseGroupWise extends StatefulWidget {
  const BrowseGroupWise({super.key, required this.categories});
  final List<CategoryModel> categories;

  @override
  State<BrowseGroupWise> createState() => _BrowseGroupWiseState();
}

class _BrowseGroupWiseState extends State<BrowseGroupWise> {
  final ScrollController _scrollController = ScrollController();
  double progress = 1;
  int totalItems = 1; 

 @override
  void initState() {
    super.initState();

    totalItems = widget.categories.length > 10 ? 10 : widget.categories.length;

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
    if(widget.categories.isEmpty) {
     return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse Group wise',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            //Container(
             // width: 44,
             // height: 7,
             // decoration: BoxDecoration(
              //  color: const Color(0xFFEEF2FF),
             //   borderRadius: BorderRadius.circular(20),
             // ),
              // child: Align(
              //   alignment: Alignment.centerLeft,
              //   child: FractionallySizedBox(
              //     widthFactor:totalItems==1
              //     ? 1
              //      :progress.clamp(0.1, 1.0),
              //     child: Container(
              //       margin: const EdgeInsets.all(2),
              //       height: 4,
              //       decoration: BoxDecoration(
              //         color: AppColors.green,
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //     ),
              //   ),
              // ),
           // ),
          ],
        ),
        const SizedBox(height: 12),

        // Show loading state or categories
       
        _buildCategoriesGrid(context, widget.categories),
      ],
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 100,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 100,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () async {
            // Navigate to category products
            final savedLocation = await LocationService.getSavedLocation();
            final pincode = savedLocation?['pincode'] as String? ?? '';

            // Convert all categories to CategoryModel
            final allCategoryModels = categories.map((cat) {
              return CategoryModel(
                id: cat.id,
                name: cat.name,
                image: cat.image,
                itemCount: cat.itemCount,
              );
            }).toList();

            context.pushNamed(
             'searchrail',
              extra: {
                'categoryId': category.id,
                'category': category,
                'pincode': pincode,
                'allCategories': allCategoryModels,
              },
            );
          },
          child: GroupCard(
            name: category.name,
            icon: category.image,
            backgroundColor: _getCategoryColor(category.name),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'vegetables':
        return AppColors.catGreen;
      case 'fruits':
        return AppColors.catPeach;
      case 'beverages':
        return AppColors.catLavender;
      case 'dairy':
        return AppColors.catBlonde;
      case 'coffee & tea':
        return AppColors.catMint;
      case 'snacks':
        return AppColors.catPeriwinkle;
      case 'personal care':
        return AppColors.catPink;
      case 'household':
        return AppColors.catMagnolia;
      default:
        final hash = categoryName.hashCode;
        return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.2);
    }
  }
  @override
void didUpdateWidget(BrowseGroupWise oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.categories != widget.categories) {
    setState(() {
      totalItems = widget.categories.length > 10 ? 10 : widget.categories.length;
    });
  }
}
}

