import 'package:villag_kart/features/home/model/coupons_model.dart';

abstract class CouponsState {}

class CouponsInitial extends CouponsState {}

class CouponsLoading extends CouponsState {}

class CouponsLoaded extends CouponsState {
  final List<Coupon> coupons;
  final List<Coupon> personalizedCoupons;
  final List<Coupon> globalCoupons;
  final int totalCount;

  CouponsLoaded({
    required this.coupons,
    required this.personalizedCoupons,
    required this.globalCoupons,
    required this.totalCount,
  });
}

class CouponsRefreshing extends CouponsState {
  final List<Coupon> coupons;
  final List<Coupon> personalizedCoupons;
  final List<Coupon> globalCoupons;
  final int totalCount;

  CouponsRefreshing({
    required this.coupons,
    required this.personalizedCoupons,
    required this.globalCoupons,
    required this.totalCount,
  });
}

class CouponsEmpty extends CouponsState {
  final String message;

  CouponsEmpty({required this.message});
}

class CouponsError extends CouponsState {
  final String errorMessage;

  CouponsError({required this.errorMessage});
}