class CategoryRequest {
  CategoryRequest({
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });
  final String pincode;
  final double latitude;
  final double longitude;
  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
    };
  }
}

class CategoryResponse {
  CategoryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      data: CategoryData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final CategoryData data;
  final String message;
}

class CategoryData {
  CategoryData({
    required this.serviceable,
    required this.warehouse,
    required this.categories,
    required this.count,
    required this.reason,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      serviceable: json['serviceable'] ?? false,
      warehouse: Warehouse.fromJson(json['warehouse']),
      categories: (json['categories'] as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList(),
      count: json['count'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
  final bool serviceable;
  final Warehouse warehouse;
  final List<CategoryModel> categories;
  final int count;
  final String reason;
}

class Warehouse {
  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.pincodeList,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      pincodeList: List<String>.from(json['pincodeList'] ?? []),
    );
  }
  final String id;
  final String name;
  final String code;
  final List<String> pincodeList;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }
}

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.itemCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      itemCount: json['itemCount'] ?? 0,
    );
  }
  final String id;
  final String name;
  final String image;
  final int itemCount;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'itemCount': itemCount};
  }
}
