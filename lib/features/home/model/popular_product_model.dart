import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class PopularProductsModel {
  PopularProductsModel({required this.pincode, this.page = 1, this.limit = 20});
  final String pincode;
  final int page;
  final int limit;

  Map<String, dynamic> toJson() {
    return {'pincode': pincode, 'page': page, 'limit': limit};
  }
}

class PopularProductsResponse {
  PopularProductsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PopularProductsResponse.fromJson(Map<String, dynamic> json) {
    return PopularProductsResponse(
      success: json['success'] ?? false,
      data: PopularProductsData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final PopularProductsData data;
  final String message;
}

class PopularProductsData {
  PopularProductsData({
    required this.serviceable,
    required this.warehouse,
    required this.products,
    required this.count,
    required this.reason,
  });

  factory PopularProductsData.fromJson(Map<String, dynamic> json) {
    return PopularProductsData(
      serviceable: json['serviceable'] ?? false,
      warehouse: Warehouse.fromJson(json['warehouse']),
      products: (json['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      count: json['count'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
  final bool serviceable;
  final Warehouse warehouse;
  final List<Product> products;
  final int count;
  final String reason;
}
