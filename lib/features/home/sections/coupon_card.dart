import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_bloc.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_state.dart';
import 'package:villag_kart/features/home/model/coupons_model.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';

class CouponsSection extends StatefulWidget {
  const CouponsSection({super.key});

  @override
  State<CouponsSection> createState() => _CouponsSectionState();
}

class _CouponsSectionState extends State<CouponsSection> {
  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }


 Color _getCategoryColor(String key) {
    //Random colors
    final randomColors = [
     const Color(0xFFF5FFF8),
     const Color(0xFFFFF3EF),
     const Color(0xFFF9F8FF),
     const Color(0xFFFDFAF4),
     const Color(0xFFE2FDEA),
     const Color(0xFFEFF1FF),
     const Color(0xFFFAE5E5),
     const Color(0xFFFDF4F9),
    ];

    final random = Random();
    return randomColors[random.nextInt(randomColors.length)];
  }
  void _fetchCoupons() async {
    final userId = await LocationService.getUserId();
    final savedLocation = await LocationService.getSavedLocation();

    if (savedLocation == null) {
      debugPrint('⚠️ No saved location found');
      return;
    }

    final pincode = savedLocation['pincode'] as String? ?? '';

    if (pincode.isEmpty) {
      debugPrint('⚠️ Invalid pincode');
      return;
    }

    final cartValue = 1000.0; // You can make this dynamic based on cart state

    if (mounted) {
      context.read<CouponsBloc>().add(
        FetchCoupons(
          userId: userId ?? '',
          pincode: pincode,
          cartValue: cartValue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponsBloc(),
      child: BlocBuilder<CouponsBloc, CouponsState>(
        builder: (context, state) {
          // Hide the entire section if no coupons available
          if (state is CouponsLoaded) {
            if (state.coupons.isEmpty) {
              return const SizedBox.shrink();
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top info banner (always show this part)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Free delivery on your VillagKart daily order',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Coupons section (only show if coupons available)
              if (state is CouponsLoading ||
                  state is CouponsLoaded ||
                  state is CouponsRefreshing ||
                  state is CouponsError) ...[
                const SectionHeader(title: 'Coupons for you', onSeeAll: null),
                const SizedBox(height: 10),
                _buildCouponsContent(state),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponsContent(CouponsState state) {
    if (state is CouponsLoading) {
      return _buildLoadingState();
    }

    if (state is CouponsError) {
      return _buildErrorState(state.errorMessage);
    }

    if (state is CouponsLoaded || state is CouponsRefreshing) {
      final coupons = state is CouponsLoaded
          ? (state as CouponsLoaded).coupons
          : (state as CouponsRefreshing).coupons;

      return _buildCouponsList(coupons, state is CouponsRefreshing);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 67,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 10,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 10,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
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
    return Container(
      height: 67,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          'Failed to load coupons: $errorMessage',
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCouponsList(List<Coupon> coupons, bool isLoading) {
    return Stack(
      children: [
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _buildCouponCard(coupon);
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

  // coupons_section.dart - Updated _buildCouponCard method
  Widget _buildCouponCard(Coupon coupon) {
    final cartValue = 1000.0; // Get from actual cart state
    final discount = coupon.calculateDiscount(cartValue);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 300, // Fixed width to prevent overflow
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ), // Reduced vertical padding
      decoration: BoxDecoration(
        color:_getCategoryColor(coupon.code) ,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          // Coupon Icon - Fixed size
          Container(
            width: 36, // Reduced size
            height: 36, // Reduced size
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_offer,
              color: Colors.orange.shade600,
              size: 18, // Reduced icon size
            ),
          ),
          const SizedBox(width: 8),

          // Coupon Details - Make this flexible
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Important: Allow column to shrink
              children: [
                // Title
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Reduced from 14
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // Description - Single line only
                Text(
                  coupon.description,
                  style: const TextStyle(
                    fontSize: 10, // Reduced from 11
                    color: AppColors.secondary,
                    height: 1.2, // Reduced line height
                  ),
                  maxLines: 1, // Changed to 1 line only
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Price info in a single row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        coupon.formattedMinCart,
                        style: const TextStyle(
                          fontSize: 9, // Reduced from 10
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4), // Reduced spacing
                    Flexible(
                      child: Text(
                        'Save: ₹${discount.toInt()}',
                        style: const TextStyle(
                          fontSize: 9, // Reduced from 10
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Coupon Code - Fixed width
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(
              minWidth: 50, // Reduced from 60
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200, width: 1),
            ),
            child: Text(
              coupon.code,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 11, // Reduced from 12
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
