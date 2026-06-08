// features/product_detail/bloc/product_detail_event.dart
abstract class ProductDetailEvent {}

class FetchProductDetail extends ProductDetailEvent {
  final String productId;
  final String pincode;

  FetchProductDetail({
    required this.productId,
    required this.pincode,
  });
}

class RefreshProductDetail extends ProductDetailEvent {
  final String productId;
  final String pincode;

  RefreshProductDetail({
    required this.productId,
    required this.pincode,
  });
}