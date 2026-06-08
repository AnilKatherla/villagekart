// subcategory_model.dart
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class SubCategoryResponse {
  final bool success;
  final SubCategoryData data;
  final String message;

  SubCategoryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      success: json['success'] ?? false,
      data: SubCategoryData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}

class SubCategoryData {
  final bool serviceable;
  final Warehouse warehouse;
  final List<SubCategory> subcategories;
  final int count;
  final String reason;

  SubCategoryData({
    required this.serviceable,
    required this.warehouse,
    required this.subcategories,
    required this.count,
    required this.reason,
  });

  factory SubCategoryData.fromJson(Map<String, dynamic> json) {
    return SubCategoryData(
      serviceable: json['serviceable'] ?? false,
      warehouse: Warehouse.fromJson(json['warehouse']),
      subcategories: (json['subcategories'] as List)
          .map((subcat) => SubCategory.fromJson(subcat))
          .toList(),
      count: json['count'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
} 
