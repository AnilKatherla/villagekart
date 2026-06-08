import 'package:flutter/foundation.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class OffersModel {
  OffersModel({required this.pincode, this.page = 1, this.limit = 5});
  final String pincode;
  final int page;
  final int limit;

  Map<String, dynamic> toJson() {
    return {
      'pincode': pincode,
      'page': page.toString(),
      'limit': limit.toString(),
    };
  }
}

class OffersResponse {
  OffersResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory OffersResponse.fromJson(Map<String, dynamic> json) {
    return OffersResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? OffersData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final OffersData? data;
  final String message;
}

class OffersData {
  OffersData({
    required this.serviceable,
    required this.warehouse,
    required this.products,
    required this.count,
    required this.reason,
  });

  factory OffersData.fromJson(Map<String, dynamic> json) {
    return OffersData(
      serviceable: json['serviceable'] ?? false,
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'] as Map<String, dynamic>)
          : Warehouse(id: '', name: '', code: '', pincodeList: []),
    products: json['products'] != null && json['products'] is List
    ? (json['products'] as List).map((product) {
        try {
          return Product.fromJson(product as Map<String, dynamic>);
        } catch (e, stack) {
          debugPrint("❌ PRODUCT JSON ERROR: $product");
          debugPrint("❌ ERROR: $e");
          debugPrint("❌ STACK: $stack");
          rethrow;
        }
      }).toList()
    : [],
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
