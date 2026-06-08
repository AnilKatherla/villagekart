abstract class PromoCodeEvent {}

class FetchCouponsEvent extends PromoCodeEvent {
  final String pincode;
  final double cartValue;
  FetchCouponsEvent(this.pincode, this.cartValue);
}

class ApplyCouponEvent extends PromoCodeEvent {
  final String couponCode;
  final double cartTotal;

  ApplyCouponEvent({
    required this.couponCode,
    required this.cartTotal,
  });
}

class RemoveCouponEvent extends PromoCodeEvent {}

class RefreshCouponsEvent extends PromoCodeEvent {
  final String pincode;
  final double cartTotal;

  RefreshCouponsEvent({
    required this.pincode,
    required this.cartTotal,
  });
}

class ValidateCouponEvent extends PromoCodeEvent {
  final String couponCode;
  final double cartTotal;

  ValidateCouponEvent({
    required this.couponCode,
    required this.cartTotal,
  });
}