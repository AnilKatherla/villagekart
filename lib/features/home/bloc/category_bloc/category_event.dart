abstract class CategoryEvent {}

class FetchCategories extends CategoryEvent {
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  FetchCategories({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}

class RefreshCategories extends CategoryEvent {
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  RefreshCategories({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
}