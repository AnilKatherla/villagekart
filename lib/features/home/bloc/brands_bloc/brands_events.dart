abstract class BrandsEvent {}

class FetchBrands extends BrandsEvent {
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  FetchBrands({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}

class RefreshBrands extends BrandsEvent {
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  RefreshBrands({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}