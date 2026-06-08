// class CouponsRequest {
//   final String userId;
//   final String pincode;
//   final double cartValue;

//   CouponsRequest({
//     required this.userId,
//     required this.pincode,
//     required this.cartValue,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'pincode': pincode,
//       'cartValue': cartValue,
//     };
//   }
// }

// class CouponsResponse {
//   final bool success;
//   final CouponsData data;
//   final String message;

//   CouponsResponse({
//     required this.success,
//     required this.data,
//     required this.message,
//   });

//   factory CouponsResponse.fromJson(Map<String, dynamic> json) {
//     return CouponsResponse(
//       success: json['success'] ?? false,
//       data: CouponsData.fromJson(json['data']),
//       message: json['message'] ?? '',
//     );
//   }
// }

// class CouponsData {
//   final List<Coupon> personalized;
//   final List<Coupon> global;
//   final int count;

//   CouponsData({
//     required this.personalized,
//     required this.global,
//     required this.count,
//   });

//   factory CouponsData.fromJson(Map<String, dynamic> json) {
//     return CouponsData(
//       personalized: (json['personalized'] as List)
//           .map((coupon) => Coupon.fromJson(coupon))
//           .toList(),
//       global: (json['global'] as List)
//           .map((coupon) => Coupon.fromJson(coupon))
//           .toList(),
//       count: json['count'] ?? 0,
//     );
//   }

//   List<Coupon> get allCoupons => [...personalized, ...global];
// }

// class Coupon {
//   final String id;
//   final String code;
//   final String title;
//   final String description;
//   final String discountType;
//   final double discountValue;
//   final double minCartValue;
//   final double maxDiscount;
//   final int usageLimit;
//   final int usedCount;
//   final DateTime validFrom;
//   final DateTime validUntil;
//   final bool isActive;
//   final String? categoryId;
//   final String? brandId;

//   Coupon({
//     required this.id,
//     required this.code,
//     required this.title,
//     required this.description,
//     required this.discountType,
//     required this.discountValue,
//     required this.minCartValue,
//     required this.maxDiscount,
//     required this.usageLimit,
//     required this.usedCount,
//     required this.validFrom,
//     required this.validUntil,
//     required this.isActive,
//     this.categoryId,
//     this.brandId,
//   });

//   factory Coupon.fromJson(Map<String, dynamic> json) {
//     return Coupon(
//       id: json['id'] ?? '',
//       code: json['code'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       discountType: json['discountType'] ?? 'percentage',
//       discountValue: (json['discountValue'] as num).toDouble(),
//       minCartValue: (json['minCartValue'] as num).toDouble(),
//       maxDiscount: (json['maxDiscount'] as num).toDouble(),
//       usageLimit: json['usageLimit'] ?? 1,
//       usedCount: json['usedCount'] ?? 0,
//       validFrom: DateTime.parse(json['validFrom']),
//       validUntil: DateTime.parse(json['validUntil']),
//       isActive: json['isActive'] ?? false,
//       categoryId: json['categoryId'],
//       brandId: json['brandId'],
//     );
//   }

//   String get formattedDiscount {
//     if (discountType == 'percentage') {
//       return '${discountValue.toInt()}% OFF';
//     } else {
//       return '₹${discountValue.toInt()} OFF';
//     }
//   }

//   String get formattedMinCart => 'Min. cart: ₹${minCartValue.toInt()}';

//   bool get isValid => isActive && DateTime.now().isBefore(validUntil);
//   bool get canUse => usedCount < usageLimit;
// }

// coupons_model.dart
import 'dart:convert';

class CouponsResponse {
  final bool success;
  final CouponsData data;
  final String message;

  CouponsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CouponsResponse.fromJson(String str) =>
      CouponsResponse.fromMap(json.decode(str));

  factory CouponsResponse.fromMap(Map<String, dynamic> json) {
    return CouponsResponse(
      success: json['success'] ?? false,
      data: CouponsData.fromMap(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class CouponsData {
  final List<Coupon> personalized;
  final List<Coupon> global;
  final int count;

  CouponsData({
    required this.personalized,
    required this.global,
    required this.count,
  });

  factory CouponsData.fromMap(Map<String, dynamic> json) {
    return CouponsData(
      personalized: (json['personalized'] as List? ?? [])
          .map((coupon) => Coupon.fromMap(coupon))
          .toList(),
      global: (json['global'] as List? ?? [])
          .map((coupon) => Coupon.fromMap(coupon))
          .toList(),
      count: json['count'] ?? 0,
    );
  }

  // Get all coupons (personalized + global)
  List<Coupon> get allCoupons => [...personalized, ...global];
}

class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final String type; // "PERCENTAGE" or "FIXED"
  final double value;
  final double? maxDiscount;
  final double minOrderValue;
  final DateTime startDate;
  final DateTime expiryDate;
  final List<String> applicablePincodes;
  final String? warehouseId;
  final int? usageLeftForUser;
  final int totalRemainingUses;
  final double? calculatedDiscountForCart;
  final String? termsUrl;

  Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    required this.minOrderValue,
    required this.startDate,
    required this.expiryDate,
    required this.applicablePincodes,
    this.warehouseId,
    this.usageLeftForUser,
    required this.totalRemainingUses,
    this.calculatedDiscountForCart,
    this.termsUrl,
  });

  factory Coupon.fromMap(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'PERCENTAGE',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate'] ?? '2025-11-26T15:24:03.794Z'),
      expiryDate: DateTime.parse(json['expiryDate'] ?? '2026-02-26T15:24:03.794Z'),
      applicablePincodes: (json['applicablePincodes'] as List? ?? [])
          .map((pincode) => pincode.toString())
          .toList(),
      warehouseId: json['warehouseId'],
      usageLeftForUser: json['usageLeftForUser'],
      totalRemainingUses: json['totalRemainingUses'] ?? 0,
      calculatedDiscountForCart: (json['calculatedDiscountForCart'] as num?)?.toDouble(),
      termsUrl: json['termsUrl'],
    );
  }

  // Helper getters
  String get formattedDiscount {
    if (type == 'PERCENTAGE') {
      return '${value.toInt()}% OFF';
    } else {
      return '₹${value.toInt()} OFF';
    }
  }

  String get formattedMinCart => 'Min. cart: ₹${minOrderValue.toInt()}';

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  bool get isActive => !isExpired && totalRemainingUses > 0;
  
  bool isApplicableForPincode(String pincode) {
    if (applicablePincodes.isEmpty) return true;
    return applicablePincodes.contains(pincode);
  }
  
  double calculateDiscount(double cartValue) {
    if (cartValue < minOrderValue) return 0.0;
    
    double discount = 0.0;
    
    if (type == 'PERCENTAGE') {
      discount = (cartValue * value) / 100;
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
    } else {
      discount = value;
    }
    
    return discount;
  }
}