// product_model.dart
import 'package:villag_kart/features/cart/model/VariantModel.dart';
import 'package:villag_kart/features/home/model/category_model.dart';

class ProductResponse {
  ProductResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] ?? false,
      data: ProductData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final ProductData data;
  final String message;
}

class ProductData {
  ProductData({
    required this.serviceable,
    required this.warehouse,
    this.category,
    this.subCategory,
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.reason,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      serviceable: json['serviceable'] ?? false,
      warehouse: Warehouse.fromJson(json['warehouse']),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      products: (json['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
      reason: json['reason'] ?? '',
    );
  }
  final bool serviceable;
  final Warehouse warehouse;
  final CategoryModel? category;
  final SubCategory? subCategory;
  final List<Product> products;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final String reason;
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.savedAmount,
    required this.images,
    required this.unit,
    required this.stock,
    required this.inStock,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.isFeatured,
    this.brand,
    this.category,
    this.subCategory,
    required this.rating,
    required this.ratingCount,
    required this.weight,
    this.measurement,
    required this.createdAt,
    this.warehouse,
    required this.variants,
    this.cartCount = 0,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      savedAmount:(json['savedAmount'] as num?)?.toDouble() ?? 0.0 ,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      unit: json['unit'] ?? '',
      stock: json['stock'] ?? 0,
      inStock: json['inStock'] ?? false,
      minOrderQty: json['minOrderQty'] ?? 1,
      maxOrderQty: json['maxOrderQty'] ?? 1,
      isFeatured: json['isFeatured'] ?? false,
      // FIX: Handle null brand
      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : Brand(id: '', name: '', image: ''),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      measurement: (json['measurement'] as String?) ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'])
          : null,
       variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => VariantModel.fromJson(e))
              .toList() ??
          [],
    
      cartCount: json['cartCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
  final String id;
  final String name;
  final String description;
  final double price;
  final double mrp;
  final double discount;
  final double savedAmount;
  final List<String> images;
  final String unit;
  final int stock;
  final bool inStock;
  final int minOrderQty;
  final int maxOrderQty;
  final bool isFeatured;
  final Brand? brand;
  final CategoryModel? category;
  final SubCategory? subCategory;
  final double rating;
  final int ratingCount;
  final double weight;
  final String? measurement;
  final DateTime createdAt;
  final Warehouse? warehouse;
  final List<VariantModel> variants;
  int? cartCount;
  bool isFavorite = false;

  String get warehouseId => warehouse?.id ?? '';

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? mrp,
    double? discount,
    double? savedAmount,
    List<String>? images,
    String? unit,
    int? stock,
    bool? inStock,
    int? minOrderQty,
    int?maxOrderQty,
    bool? isFeatured,
    Brand? brand,
    CategoryModel? category,
    SubCategory? subCategory,
    double? rating,
    int? ratingCount,
    double? weight,
    DateTime? createdAt,
    Warehouse? warehouse,
    List<VariantModel>? variants,
    int? cartCount,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      discount: discount ?? this.discount,
      savedAmount: savedAmount ?? this.savedAmount,
      images: images ?? this.images,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      inStock: inStock ?? this.inStock,
      minOrderQty: minOrderQty ?? this.minOrderQty,
      maxOrderQty: maxOrderQty ?? this.maxOrderQty,
      isFeatured: isFeatured ?? this.isFeatured,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      warehouse: warehouse ?? this.warehouse,
       variants: variants ?? this.variants,
      cartCount: cartCount ?? this.cartCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'mrp': mrp,
      'discount': discount,
      'images': images,
      'unit': unit,
      'stock': stock,
      'inStock': inStock,
      'isFeatured': isFeatured,
      'brand': brand?.toJson(),
      'category': category?.toJson(),
      'subCategory': subCategory?.toJson(),
      'rating': rating,
      'ratingCount': ratingCount,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
      'warehouse': warehouse?.toJson(),
      'variants': variants.map((e) => e.toJson()).toList(),
      'cartCount': cartCount,
      'isFavorite': isFavorite,
    };
  }
}

class Brand {
  Brand({required this.id, required this.name, required this.image});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
  final String id;
  final String name;
  final String image;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image};
  }
}

class SubCategory {
  SubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.image,
    this.colorCode,
    this.itemCount,
  });

  factory SubCategory.fromJson(Map<String, dynamic>? json) {
    return SubCategory(
      id: json?['id'] ?? '',
      name: json?['name'] ?? '',
      categoryId: json?['categoryId'],
      image: json?['image'],
      colorCode: json?['colorCode'],
      itemCount: json?['itemCount'],
    );
  }
  final String? id;
  final String? name;
  final String? categoryId;
  final String? image;
  final String? colorCode;
  final int? itemCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'image': image,
      'colorCode': colorCode,
      'itemCount': itemCount,
    };
  }
}
