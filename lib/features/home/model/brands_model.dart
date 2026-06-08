import 'package:villag_kart/features/home/model/category_model.dart';

class BrandsRequest {
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  BrandsRequest({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
    };
  }
}

class BrandsResponse {
  final bool success;
  final BrandsData data;
  final String message;

  BrandsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory BrandsResponse.fromJson(Map<String, dynamic> json) {
    return BrandsResponse(
      success: json['success'] ?? false,
      data: BrandsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class BrandsData {
  final bool serviceable;
  final Warehouse warehouse;
  final List<Brand> brands;
  final int count;
  final String reason;

  BrandsData({
    required this.serviceable,
    required this.warehouse,
    required this.brands,
    required this.count,
    required this.reason,
  });

  factory BrandsData.fromJson(Map<String, dynamic> json) {
    return BrandsData(
      serviceable: json['serviceable'] ?? false,
      warehouse: Warehouse.fromJson(json['warehouse'] ?? {}),
      brands: json['brands'] != null && json['brands'] is List
          ? (json['brands'] as List)
              .map((brand) => Brand.fromJson(brand as Map<String, dynamic>))
              .toList()
          : <Brand>[],
      count: json['count'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String title;
  final String image;
  final int productCount;

  Brand({
    required this.id,
    required this.name,
    required this.title,
    required this.image,
    required this.productCount,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }
}