import 'package:villag_kart/features/home/model/product_response.dart';

class CartItemModel {
  final String id;

  /// Product info
  final Product? product;

  /// variant support
  final String? productVariantId;
  final String? variantName;

  final int quantity;
  final int availableQuantity;
  final bool isOutOfStock;
  final bool isLowStock;

  final double unitPrice;
  final double snapshotPrice;

  final bool priceChanged;
  final double priceDifference;
  final double priceChangePercent;

  final double savings;
  final double totalPrice;

  final String addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.availableQuantity,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.unitPrice,
    required this.snapshotPrice,
    required this.priceChanged,
    required this.priceDifference,
    required this.priceChangePercent,
    required this.savings,
    required this.totalPrice,
    required this.addedAt,

    /// variant
    this.productVariantId,
    this.variantName,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',

      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,

      /// VARIANT
      productVariantId: json['productVariantId'],
      variantName: json['variantName'],

      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      availableQuantity: (json['availableQuantity'] as num?)?.toInt() ?? 0,
      isOutOfStock: json['isOutOfStock'] ?? false,
      isLowStock: json['isLowStock'] ?? false,

      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      snapshotPrice: (json['snapshotPrice'] as num?)?.toDouble() ?? 0.0,

      priceChanged: json['priceChanged'] ?? false,
      priceDifference: (json['priceDifference'] as num?)?.toDouble() ?? 0.0,
      priceChangePercent:
          (json['priceChangePercent'] as num?)?.toDouble() ?? 0.0,

      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,

      addedAt: json['addedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product?.toJson(),

      'productVariantId': productVariantId,
      'variantName': variantName,

      'quantity': quantity,
      'availableQuantity': availableQuantity,
      'isOutOfStock': isOutOfStock,
      'isLowStock': isLowStock,
      'unitPrice': unitPrice,
      'snapshotPrice': snapshotPrice,
      'priceChanged': priceChanged,
      'priceDifference': priceDifference,
      'priceChangePercent': priceChangePercent,
      'savings': savings,
      'totalPrice': totalPrice,
      'addedAt': addedAt,
    };
  }
}