import 'package:villag_kart/features/cart/model/promocode_model.dart';



abstract class PromoCodeState {}

class PromoCodeInitial extends PromoCodeState {}

class PromoCodeLoading extends PromoCodeState {}

class PromoCodeSuccess extends PromoCodeState {
  final List<CouponModel> personalizedCoupons;
  final List<CouponModel> globalCoupons;
  final CouponModel? appliedCoupon;
  final double? discountAmount;

  PromoCodeSuccess({
    required this.personalizedCoupons,
    required this.globalCoupons,
    this.appliedCoupon,
    this.discountAmount,
  });

  List<CouponModel> get allCoupons => [...personalizedCoupons, ...globalCoupons];

  bool get hasCouponApplied => appliedCoupon != null;

  PromoCodeSuccess copyWith({
    List<CouponModel>? personalizedCoupons,
    List<CouponModel>? globalCoupons,
    CouponModel? appliedCoupon,
    double? discountAmount,
    bool clearAppliedCoupon = false,
  }) {
    return PromoCodeSuccess(
      personalizedCoupons: personalizedCoupons ?? this.personalizedCoupons,
      globalCoupons: globalCoupons ?? this.globalCoupons,
      appliedCoupon: clearAppliedCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: clearAppliedCoupon ? null : (discountAmount ?? this.discountAmount),
    );
  }
}

class PromoCodeRefreshing extends PromoCodeState {
  final List<CouponModel> personalizedCoupons;
  final List<CouponModel> globalCoupons;
  final CouponModel? appliedCoupon;

  PromoCodeRefreshing({
    required this.personalizedCoupons,
    required this.globalCoupons,
    this.appliedCoupon,
  });
}

class PromoCodeEmpty extends PromoCodeState {
  final String message;

  PromoCodeEmpty({required this.message});
}

class PromoCodeFailure extends PromoCodeState {
  final String error;

  PromoCodeFailure(this.error);
}

class CouponAppliedSuccess extends PromoCodeState {
  final CouponModel coupon;
  final double discountAmount;
  final String message;

  CouponAppliedSuccess({
    required this.coupon,
    required this.discountAmount,
    required this.message,
  });
}

class CouponRemovedSuccess extends PromoCodeState {
  final String message;

  CouponRemovedSuccess(this.message);
}

class CouponValidationError extends PromoCodeState {
  final String message;
  final CouponModel? coupon;

  CouponValidationError(this.message, {this.coupon});
}