// features/wishlist/models/wishlist_response.dart
import 'dart:convert';

import 'package:villag_kart/features/home/model/product_response.dart';

class WishlistModel {
  WishlistModel({
    required this.status,
    required this.response,
    required this.data,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return WishlistModel(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: dataJson is Map<String, dynamic>
          ? WishlistData.fromJson(dataJson)
          : WishlistData(
              id: '',
              userId: '',
              items: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }
  final bool status;
  final String response;
  final WishlistData data;

  Map<String, dynamic> toJson() => {
    'status': status,
    'response': response,
    'data': data.toJson(),
  };
}

class WishlistData {
  WishlistData({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    return WishlistData(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items:
          (json['items'] as List?)
              ?.where((x) => x != null)
              .map((x) => WishlistItem.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  final String id;
  final String userId;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': List<dynamic>.from(items.map((x) => x.toJson())),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class WishlistItem {
  WishlistItem({
    required this.status,
    required this.createdAt,
    required this.productId,
    required this.updatedAt,
    required this.warehouseId,
    required this.product,
    this.warehouse,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      productId: json['productId']?.toString() ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      warehouseId: json['warehouseId']?.toString() ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'])
          : null,
    );
  }
  final String status;
  final DateTime createdAt;
  final String productId;
  final DateTime? updatedAt;
  final String warehouseId;
  final Product product;
  final Warehouse? warehouse;

  // Formatted price
  String get formattedPrice => '₹${product.price.toStringAsFixed(2)}';

  // Formatted original price
  String get formattedOriginalPrice =>
      product.mrp > product.price ? '₹${product.mrp.toStringAsFixed(2)}' : '';

  // Formatted savings
  String get formattedSavings {
    if (product.mrp <= product.price) {
      return '';
    }
    final saving = product.mrp - product.price;
    return 'Save ₹${saving.toStringAsFixed(2)}';
  }

  // Discount offer text
  String get discountOffer {
    if (product.discount == 0) {
      return 'Special Offer';
    }
    return 'Up to ${product.discount.toStringAsFixed(2)}% Off';
  }

  // Product image
  String get productImage => product.images.isNotEmpty
      ? product.images[0]
      : 'assets/images/vegetables.png';

  // Check if on sale
  bool get isOnSale => product.mrp > product.price;

  // Helper getters for name, unit etc
  String get name => product.name;
  String get unit =>
      product.unit.isNotEmpty ? product.unit : '${product.weight}';

  Map<String, dynamic> toJson() => {
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'productId': productId,
    'updatedAt': updatedAt?.toIso8601String(),
    'warehouseId': warehouseId,
    'product': product.toJson(),
    'warehouse': warehouse?.toJson(),
  };
}

class Warehouse {
  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.address,
    required this.phone,
    required this.state,
    required this.isActive,
    required this.opensAt,
    required this.closesAt,
    required this.servicePincodes,
    required this.createdAt,
    required this.updatedAt,
    required this.isPickupStore,
    required this.pickupTimeSlots,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? false,
      opensAt: json['opensAt'] ?? '',
      closesAt: json['closesAt'] ?? '',
      servicePincodes: List<String>.from(json['servicePincodes'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isPickupStore: json['isPickupStore'] ?? false,
      pickupTimeSlots: List<PickupTimeSlot>.from(
        (json['pickupTimeSlots'] ?? []).map((x) => PickupTimeSlot.fromJson(x)),
      ),
    );
  }
  final String id;
  final String name;
  final String code;
  final Location location;
  final String address;
  final String phone;
  final String state;
  final bool isActive;
  final String opensAt;
  final String closesAt;
  final List<String> servicePincodes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPickupStore;
  final List<PickupTimeSlot> pickupTimeSlots;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'location': location.toJson(),
    'address': address,
    'phone': phone,
    'state': state,
    'isActive': isActive,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'servicePincodes': servicePincodes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isPickupStore': isPickupStore,
    'pickupTimeSlots': List<dynamic>.from(
      pickupTimeSlots.map((x) => x.toJson()),
    ),
  };
}

class Location {
  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      lng: (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
    );
  }
  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class PickupTimeSlot {
  PickupTimeSlot({
    required this.slot,
    required this.capacity,
    required this.timeRange,
  });

  factory PickupTimeSlot.fromJson(Map<String, dynamic> json) {
    return PickupTimeSlot(
      slot: json['slot'] ?? '',
      capacity: json['capacity'] ?? 0,
      timeRange: json['timeRange'] ?? '',
    );
  }
  final String slot;
  final int capacity;
  final String timeRange;

  Map<String, dynamic> toJson() => {
    'slot': slot,
    'capacity': capacity,
    'timeRange': timeRange,
  };
}
