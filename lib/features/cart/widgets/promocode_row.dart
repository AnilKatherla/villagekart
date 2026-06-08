import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';
import 'package:villag_kart/features/cart/widgets/promocode_bottom_sheet.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';

class PromocodeRow extends StatelessWidget {
  final double cartValue;
  final Function(CouponModel coupon, double discount) onCouponApplied;

  const PromocodeRow({
    super.key,
    required this.cartValue,
    required this.onCouponApplied,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;
    String _pincode = homeState.pincode ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final appliedCoupon = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) =>
              PromoCodeBottomSheet(pincode: _pincode, cartValue: cartValue),
        );

        if (appliedCoupon is CouponModel) {
          final discount = _calculateDiscount(appliedCoupon, cartValue);

          onCouponApplied(appliedCoupon, discount);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),

          color: Colors.white,
        ),
        child: Row(
          children: [
            // Left Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.orange,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // Texts
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Promocodes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFF7700),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Avail offer and discounts on your order',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF747474),

                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Right Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDiscount(CouponModel coupon, double cartValue) {
    if (coupon.type == 'PERCENTAGE') {
      final discount = (cartValue * coupon.value) / 100;
      if (coupon.maxDiscount != null) {
        return discount > coupon.maxDiscount!
            ? coupon.maxDiscount!.toDouble()
            : discount;
      }
      return discount;
    }
    return coupon.value.toDouble();
  }
}
