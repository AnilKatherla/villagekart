// ============================================================================
// USER PROFILE MODELS (user_profile_model.dart - Add to order_model.dart)
// ============================================================================

import 'order_history_model.dart';

class UserProfileResponse {
  UserProfileResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: UserProfile.fromJson(json['data'] ?? {}),
    );
  }
  final bool status;
  final String response;
  final UserProfile data;
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.shareMessage,
    required this.gender,
    required this.dob,
    required this.countryCode,
    this.referralCode,
    required this.inviteRefCode,
    required this.isProfileComplete,
    required this.missingFields,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
    required this.totalOrdersCount,
    required this.totalWishlistCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CONSUMER',
      shareMessage: json['shareMessage'],
      avatar: json['avatar'],
      gender: json['gender'] ?? 'male',
      dob: DateTime.parse(json['dob'] ?? DateTime.now().toString()),
      countryCode: json['countryCode'] ?? '+91',
      referralCode: json['referralCode'],
      inviteRefCode: json['inviteRefCode'] ?? '',
      isProfileComplete: json['isProfileComplete'] ?? false,
      missingFields: List<String>.from(json['missingFields'] as List? ?? []),
      addresses:
          (json['addresses'] as List?)
              ?.map((e) => Address.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      totalOrdersCount: json['totalOrdersCount'] ?? 0,
      totalWishlistCount: json['totalWishlistCount'] ?? 0,
    );
  }
  final String id;
  final String phone;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String gender;
  final String? shareMessage;
  final DateTime dob;
  final String countryCode;
  final String? referralCode;
  final String inviteRefCode;
  final bool isProfileComplete;
  final List<String> missingFields;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalOrdersCount;
  final int? totalWishlistCount;
}

class UpdateProfileRequest {
  UpdateProfileRequest({required this.name, required this.email});
  final String name;
  final String email;

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }
}

class UpdateProfileResponse {
  UpdateProfileResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: UserProfile.fromJson(json['data'] ?? {}),
    );
  }
  final bool status;
  final String response;
  final UserProfile data;
}
