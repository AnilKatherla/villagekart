import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/product_bloc/product_bloc.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';

class CategoryProductSection extends StatelessWidget {
  const CategoryProductSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const SizedBox.shrink();
        }

        final categories = state.categories;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  bool hasProducts = false;

                  if (productState is ProductLoading) {
                    hasProducts = true;
                  } else if (productState is ProductLoaded) {
                    hasProducts = productState.products.any(
                      (p) => p.category?.id == category.id,
                    );
                  }

                  if (!hasProducts) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Category Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),

                      /// Products Grid
                      CategoryProductsGrid(categoryId: category.id),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class CategoryProductsGrid extends StatelessWidget {
  const CategoryProductsGrid({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return _ProductGridShimmer(context);
        }

        if (state is! ProductLoaded) {
          return const SizedBox();
        }

        /// Filter products by category
        final products = state.products.where((product) {
          if (product.category == null) return false;

          return product.category!.id == categoryId;
        }).toList();

        print('Category ID: $categoryId');
        print('Total Products: ${state.products.length}');
        print('Filtered Products: ${products.length}');

        if (products.isEmpty) {
          return const SizedBox();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.57,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      product: product,
                      pincode: context.read<HomeBloc>().state.pincode ?? '',
                    ),
                  ),
                );
              },
              child: ProductCard(
                product: product,
                warehouseId: '',
                shrinkText: true,
              ),
            );
          },
        );
      },
    );
  }
}

Widget _ProductGridShimmer(BuildContext context) {
  final productlength = context.read<ProductBloc>().state;

  return GridView.builder(
    itemCount: 6,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.65,
    ),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Container(
              height: 168,

              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      );
    },
  );
}
