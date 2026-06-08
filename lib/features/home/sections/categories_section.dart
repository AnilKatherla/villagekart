import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key, required this.onCategoryTap});
  final Function(CategoryModel) onCategoryTap;

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          return _buildCategoryData(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryData(CategoryLoaded state) {
    final List<CategoryModel> categories = state.categories;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SectionHeader(
            title: 'Categories',
            onSeeAll: () {
              // Add any specific logic needed when 'See all' is pressed.
            },
          ),
        ),
        SizedBox(height: 16.h),

        _buildCategoriesGrid(categories, state is CategoryRefreshing),
      ],
    );
  }

 Color _getCategoryColorByIndex(int index) {
  final colors = [
    const Color(0xFFE2FDEA),
    const Color(0xFFFAE5E5),
    const Color(0xFFEFF1FF),
  ];

  return colors[index % colors.length];
}

  Widget _buildCategoriesGrid(List<CategoryModel> categories, bool isLoading) {
    return Stack(
      children: [
        GridView.builder(
          itemCount: categories.length > 6 ? 6 : categories.length, // Display a subset as shown in mockup
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];

            return GestureDetector(
              onTap: () {
                widget.onCategoryTap(item);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:const BorderRadius.only(
                    topLeft:Radius.circular(8),
                    topRight:Radius.circular(8),
                    bottomRight:Radius.circular(8)
                    ),
                  color: _getCategoryColorByIndex(index),
                ),
                child: Row(
                  children: [
                    // Category Image
                    Container(
                      width: 58,
                      height: double.infinity,
                      child: ClipRect(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                           Positioned(
                            bottom: -35,
                            left: -33,
                            child: ClipOval(
                              child: SizedBox(
                                width:80.w,
                                height:80.h,
                                child: _buildCategoryImage(item),
                        
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),

                    // Category details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right:5.w,bottom: 12.h,top:2.h),
                        child: Text(
                          item.name,                          
                          style: const TextStyle(
                            color: Color(0xFF192E36),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            fontFamily: 'SegoeUI',
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryPlaceholder(String categoryName) {
    // Use first letter of category name as placeholder
    final firstLetter = categoryName.isNotEmpty ? categoryName[0] : 'C';

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(CategoryModel item) {
    final image = item.image.toString() ?? '';

    try {
      if (image.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: image,
          fit: BoxFit.contain,
          errorWidget: (context, url, error) =>
              _buildCategoryPlaceholder(item.name),
          placeholder: (context, url) => _buildCategoryPlaceholder(item.name),
        );
      }

      if (image.startsWith('data:image') || image.length > 100) {
        final Uint8List bytes = base64Decode(image.split(',').last);

        return Image.memory(bytes, fit: BoxFit.contain);
      }

      return Image.asset(
        image.isNotEmpty ? image : 'assets/images/cat-1.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildCategoryPlaceholder(item.name),
      );
    } catch (e) {
      return _buildCategoryPlaceholder(item.name);
    }
  }
}
