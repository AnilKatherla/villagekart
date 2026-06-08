import 'package:villag_kart/features/cart/model/VariantModel.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
 
class SuggestionVariant {
  final String id;
  final String name;
  final String? unit;
  final double mrp;
  final double price;
  final int stock;
  final bool inStock;
 
  SuggestionVariant({
    required this.id,
    required this.name,
    this.unit,
    required this.mrp,
    required this.price,
    required this.stock,
    required this.inStock,
  });
 
  factory SuggestionVariant.fromJson(Map<String, dynamic> json) {
    return SuggestionVariant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'],
      mrp: (json['mrp'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : 0,
      inStock: json['inStock'] ?? false,
    );
  }
}
 
class SuggestionProduct {
  final String id;
  final String name;
  final String image;
  final double price;
  final double mrp;
  final double savedAmount;
  final String unit;
  final String measurement;
  final int stock;
  final int minOrderQty;
  final int maxOrderQty;
  final bool isWishlistAdded;
  final int cartItemCount;
  final List<SuggestionVariant> variants;
 
  SuggestionProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.mrp,
    required this.savedAmount,
    required this.unit,
    required this.measurement,
    required this.stock,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.isWishlistAdded,
    required this.cartItemCount,
    required this.variants,
  });
 
  factory SuggestionProduct.fromJson(Map<String, dynamic> json) {
    return SuggestionProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      mrp: (json['mrp'] ?? 0).toDouble(),
      savedAmount: (json['savedAmount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      measurement: json['measurement']?.toString() ?? '',
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : 10,
      minOrderQty: json['minOrderQty'] != null ? (json['minOrderQty'] as num).toInt() : 1,
      maxOrderQty: json['maxOrderQty'] != null ? (json['maxOrderQty'] as num).toInt() : 10,
      isWishlistAdded: json['isWishlistAdded'] ?? false,
      cartItemCount: json['cartItemCount'] ?? 0,
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((v) => SuggestionVariant.fromJson(v))
              .toList() ??
          [],
    );
  }
 
  /// ✅ Convert SuggestionProduct → Product for ProductDetailPage
  Product toProduct() {
    return Product(
      id: id,
      name: name,
      description: '',
      price: price,
      mrp: mrp > 0 ? mrp : price,
      discount: 0.0,
      savedAmount: savedAmount,
      images: [image],
      unit: unit,
      measurement: measurement,
      stock: stock,
      inStock: stock > 0,
      minOrderQty:minOrderQty ,
      maxOrderQty: maxOrderQty,
      isFeatured: false,
      brand: null,
      category: null,
      subCategory: null,
      rating: 0.0,
      ratingCount: 0,
      weight: 0.0,
      createdAt: DateTime.now(),
      warehouse: null,
      variants: variants
          .map(
            (v) => VariantModel(
              id: v.id,
              name: v.name,
              unit: v.unit ?? '', // SuggestionVariant.unit is nullable
              measurement: '',
              mrp: v.mrp,
              price: v.price,
              discount: 0.0,
              stock: v.stock,
              inStock: v.inStock,
              minOrderQty: 1,
              maxOrderQty: 10,
              images: [],
            ),
          )
          .toList(),
      cartCount: cartItemCount,
      isFavorite: isWishlistAdded,
    );
  }
}