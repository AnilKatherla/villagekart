// Updated FilterChipsRow
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/product_bloc/product_bloc.dart';
import 'package:villag_kart/features/home/bloc/subcategory_bloc/subcategory_bloc.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final label = filters[index];
        final isSelected = label == selectedFilter;

        return GestureDetector(
          onTap: () => onFilterSelected(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.green.withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.green
                    : AppColors.grey.withOpacity(0.4),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.green : AppColors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleFilterSelection(
    BuildContext context,
    String filter,
    SubCategoryState state,
  ) {
    final productBloc = context.read<ProductBloc>();
    const pincode = ''; // Get pincode from your location service

    if (filter == 'All') {
      // Fetch all products for the category
      const categoryId = ''; // Get current category ID
      productBloc.add(
        FetchProductsByCategory(categoryId: categoryId, pincode: pincode),
      );
    } else if (state is SubCategoryLoaded) {
      // Find the subcategory and fetch its products
      final subCategory = state.subcategories.firstWhere(
        (subcat) => subcat.name == filter,
        orElse: () => SubCategory(id: '', name: ''),
      );

      if (subCategory.id?.isNotEmpty ?? false) {
        productBloc.add(
          FetchProductsBySubCategory(
            subCategoryId: subCategory.id ?? '',
            pincode: pincode,
          ),
        );
      }
    }
  }
}
