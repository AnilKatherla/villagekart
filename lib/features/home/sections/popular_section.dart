import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_event.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_produts_state.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/home/sections/popular_product_screen.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';

class PopularSection extends StatefulWidget {
  const PopularSection({super.key});

  @override
  State<PopularSection> createState() => _PopularSectionState();
}

class _PopularSectionState extends State<PopularSection> {
  @override
  void initState() {
    super.initState();
    _fetchPopularProducts();
  }

  void _fetchPopularProducts() {
    final pincode = context.read<HomeBloc>().state.pincode ?? '';

    if (pincode.isEmpty) {
      debugPrint('⚠️ PopularSection: Invalid pincode');
      return;
    }

    context.read<PopularProductsBloc>().add(
      FetchPopularProducts(pincode: pincode, limit: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pincode = context.watch<HomeBloc>().state.pincode ?? '';

    return BlocBuilder<PopularProductsBloc, PopularProductsState>(
      builder: (context, state) {
        if (state is PopularProductsLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Most Popular'),
              const SizedBox(height: 8),
              _buildLoadingState(),
            ],
          );
        }

        if (state is PopularProductsError) {
          return const SizedBox.shrink();
        }

        if (state is PopularProductsLoaded) {
          if (state.products.isEmpty) {
            return const SizedBox.shrink();
          }
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Most Popular',
                onSeeAll: () {
                  context.pushNamed('popularProducts', extra: pincode);
                },
              ),
              const SizedBox(height: 8),
              _buildContent(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(PopularProductsState state) {
    if (state is PopularProductsLoading) {
      return _buildLoadingState();
    }

    if (state is PopularProductsError) {
      return _buildErrorState(state.errorMessage);
    }

    if (state is PopularProductsLoaded) {
      return _buildProductsList(state.products);
    }

    return _buildLoadingState();
  }

  // ---------------- UI STATES ----------------

  Widget _buildLoadingState() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 12, color: Colors.grey.shade200),
                  const SizedBox(height: 4),
                  Container(width: 40, height: 10, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                      const Spacer(),
                      Container(
                        width: 25,
                        height: 10,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 8),
            Text(
              'Failed to load products',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchPopularProducts,
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildEmptyState() {
  //   return const SizedBox(
  //     height: 160,
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.shopping_bag_outlined,
  //             //color: Colors.grey.shade400,
  //             size: 40,
  //           ),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'No popular products',
  //             style: TextStyle(color: Colors.grey, fontSize: 12),
  //           ),
  //           const SizedBox(height: 4),
  //           const Text(
  //             'Check back later for updates',
  //             style: TextStyle(color: Colors.grey, fontSize: 10),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProductsList(List<Product> products) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];

          return SizedBox(
            width: 140,
            child: ProductCard(
              product: product,
              shrinkText: true,
              warehouseId: '',
              onTap: () => _navigateToProductDetail(context, product),
            ),
          );
        },
      ),
    );
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    final pincode = context.read<HomeBloc>().state.pincode ?? '';

    context.pushNamed(
      'proddetail',
      extra: {'prod': product, 'pincode': pincode},
    );
  }
}
