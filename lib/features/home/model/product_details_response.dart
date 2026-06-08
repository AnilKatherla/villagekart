// features/product_detail/model/product_detail_response.dart
import 'package:villag_kart/features/home/model/product_response.dart';

class ProductDetailResponse {
  ProductDetailResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      success: json['success'] ?? false,
      data: Product.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final Product data;
  final String message;
}
