abstract class CouponsEvent {}

class FetchCoupons extends CouponsEvent {
  final String userId;
  final String pincode;
  final double cartValue;

  FetchCoupons({
    required this.userId,
    required this.pincode,
    required this.cartValue,
  });
}

class RefreshCoupons extends CouponsEvent {
  final String userId;
  final String pincode;
  final double cartValue;

  RefreshCoupons({
    required this.userId,
    required this.pincode,
    required this.cartValue,
  });
}