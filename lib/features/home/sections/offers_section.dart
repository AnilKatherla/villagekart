import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_state.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/home/sections/offers_screen.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';

class OffersSection extends StatefulWidget {
  const OffersSection({super.key});

  @override
  State<OffersSection> createState() => _OffersSectionState();
}

class _OffersSectionState extends State<OffersSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;
    final String _pincode = homeState.pincode ?? '';
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        debugPrint('🔄 OffersSection State: $state');

        // Hide the ENTIRE section if no data or empty
        if (state is OffersEmpty ||
            (state is OffersLoaded && state.products.isEmpty) ||
            (state is OffersRefreshing && state.products.isEmpty)) {
          debugPrint('🚫 Offers section completely hidden - no offers');
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Offer on products',
                onSeeAll: () {
                  context.push('/offers', extra: _pincode);
                },
              ),
              const SizedBox(height: 8),

              if (state is OffersLoading) _buildLoadingState(),

              if (state is OffersError) const SizedBox.shrink(),

              if (state is OffersLoaded || state is OffersRefreshing)
                _buildProductsList(
                  state is OffersLoaded
                      ? state.products
                      : (state as OffersRefreshing).products,
                  state is OffersRefreshing,
                ),
            ],
          ),
        );
      },
    );
  }

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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.lightGrey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 10,
                        color: Colors.grey.shade200,
                      ),
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
              ],
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

  Widget _buildErrorState(String errorMessage) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 8),
            Text(
              'Failed to load offers',
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
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products, bool isLoading) {
    // Double check if products are empty
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        SizedBox(
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
                  shrinkText: true,
                  product: product,
                  warehouseId: '',
                  onTap: () => _navigateToProductDetail(context, product),
                ),
              );
            },
          ),
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
}
