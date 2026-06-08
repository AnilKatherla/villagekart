// ============================================================================
// 1. WISHLIST MODELS (wishlist_model.dart)
// ============================================================================

class WishlistResponse {
  WishlistResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    // API returns { "status": true, "response": "...", "data": { "items": [...] } }
    final dataMap = json['data'] as Map<String, dynamic>?;
    final itemsList = dataMap?['items'] as List?;

    return WishlistResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data:
          itemsList
              ?.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  final bool status;
  final String response;
  final List<WishlistItem> data;
}

class WishlistItem {
  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.images,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // API item structure: { "productId": "...", "product": { "name": "...", "price": ... }, "createdAt": "..." }
    final product = json['product'] as Map<String, dynamic>? ?? {};

    return WishlistItem(
      id: json['_id'] ?? json['id'] ?? json['productId'] ?? '',
      productId: json['productId'] ?? product['id'] ?? '',
      name: product['name'] ?? '',
      description: product['description'] ?? '',
      unit: product['unit'] ?? product['weight']?.toString() ?? '1 Kg',
      price: (product['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (product['mrp'] as num?)?.toDouble(),
      discountPercentage: (product['discount'] as num?)?.toDouble(),
      images: List<String>.from(product['images'] as List? ?? []),
      addedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['addedAt'] != null
                ? DateTime.parse(json['addedAt'])
                : DateTime.now()),
    );
  }
  final String id;
  final String productId;
  final String name;
  final String description;
  final String unit;
  final double price;
  final double? originalPrice;
  final double? discountPercentage;
  final List<String> images;
  final DateTime addedAt;

  // Formatted price
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';

  // Formatted original price
  String get formattedOriginalPrice =>
      originalPrice != null ? '₹${originalPrice!.toStringAsFixed(2)}' : '';

  // Formatted savings
  String get formattedSavings {
    if (originalPrice == null) return '';
    final saving = originalPrice! - price;
    return 'Save ₹${saving.toStringAsFixed(2)}';
  }

  // Discount offer text
  String get discountOffer {
    if (discountPercentage == null || discountPercentage == 0) {
      return 'Special Offer';
    }
    return 'Up to ${discountPercentage!.toStringAsFixed(2)}% Off';
  }

  // Product image
  String get productImage =>
      images.isNotEmpty ? images[0] : 'assets/images/vegetables.png';

  // Check if on sale
  bool get isOnSale => originalPrice != null && originalPrice! > price;
}

// ============================================================================
// 2. REMOVE WISHLIST RESPONSE (for remove action)
// ============================================================================

class RemoveWishlistResponse {
  RemoveWishlistResponse({required this.status, required this.response});

  factory RemoveWishlistResponse.fromJson(Map<String, dynamic> json) {
    return RemoveWishlistResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
    );
  }
  final bool status;
  final String response;
}
