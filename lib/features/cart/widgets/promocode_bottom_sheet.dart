import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/services/promocode_api_service.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_bloc.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_event.dart';
import 'package:villag_kart/features/cart/bloc/promocode_bloc/promocode_state.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';

class PromoCodeBottomSheet extends StatelessWidget {
  final String pincode;
  final double cartValue;

  const PromoCodeBottomSheet({
    super.key,
    required this.pincode,
    required this.cartValue,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponModel>>(
      future: PromoCodeService.fetchCoupons(
        pincode,
      ).then((res) => [...res['personalized']!, ...res['global']!]),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Failed to load coupons')),
          );
        }

        final coupons = snapshot.data ?? [];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45, // initial height (55% screen)
          minChildSize: 0.35, // minimum drag down
          maxChildSize: 0.90, // maximum drag up
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Promo Codes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),

                  ...coupons.map((coupon) {
                    final isEligible = cartValue >= coupon.minOrderValue;
                    return _CouponTile(
                      coupon: coupon,
                      isEligible: isEligible,
                      cartValue: cartValue,
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CouponTile extends StatelessWidget {
  final CouponModel coupon;
  final bool isEligible;
  final double cartValue;

  const _CouponTile({
    required this.coupon,
    required this.isEligible,
    required this.cartValue,
  });

  @override
  Widget build(BuildContext context) {
    const Backgroundcolor = Color(0xFF00891D);
    final remaining = (coupon.minOrderValue - cartValue).clamp(
      0,
      double.infinity,
    );

    return Opacity(
      opacity: isEligible ? 1 : 0.4,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // border: Border.all(color: isEligible ? Backgroundcolor : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEligible ? Backgroundcolor : Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    coupon.code.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coupon.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,

                      color: isEligible ? Backgroundcolor : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            if (coupon.description != null)
              Text(
                coupon.description!,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF747474),
                  fontWeight: FontWeight.w400,
                ),
              ),

            const SizedBox(height: 6),

            Text(
              isEligible
                  ? 'Eligible for this order'
                  : 'Add ₹${remaining.toStringAsFixed(2)} more to apply',
              style: TextStyle(
                fontSize: 12,
                color: isEligible ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 44,

              child: PrimaryButton(
                onPressed: isEligible ? () => context.pop(coupon) : null,
                label: 'Apply Code',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
