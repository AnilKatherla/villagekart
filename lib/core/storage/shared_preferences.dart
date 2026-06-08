import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villag_kart/features/onboard/model/login_response_model.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart';

class SharedPrefs {
  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isProfileCompleteKey = 'is_profile_complete';
  static const String _isNewUserKey = 'is_new_user';
  // Profile image key
static const String _profileImagePathKey = 'profile_image_path';


  // Save complete auth response
  static Future<void> saveAuthResponse(AuthResponseModel authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    // Save tokens
    await prefs.setString(_accessTokenKey, authResponse.data.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.data.refreshToken);

    // Save user data as JSON string
    await prefs.setString(
      _userDataKey,
      jsonEncode(authResponse.data.user.toJson()),
    );

    // Save flags
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(
      _isProfileCompleteKey,
      authResponse.data.user.isProfileComplete,
    );
    await prefs.setBool(_isNewUserKey, authResponse.data.user.isNewUser);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);

    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      debugPrint('Error parsing user data: $e');
      return null;
    }
  }

  // Update user data (after profile update)
  static Future<void> updateUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isProfileCompleteKey, user.isProfileComplete);
    await prefs.setBool(_isNewUserKey, user.isNewUser);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Check if profile is complete
  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfileCompleteKey) ?? false;
  }

  // Check if user is new
  static Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isNewUserKey) ?? false; // Default to false if not set
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final user = await getUserData();
    return user?.id;
  }

  // Get user phone
  static Future<String?> getUserPhone() async {
    final user = await getUserData();
    return user?.phone;
  }

  // Get user name
  static Future<String?> getUserName() async {
    final user = await getUserData();
    return user?.name;
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final user = await getUserData();
    return user?.email;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  //  Remove specific key
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Location storage keys
  static const String _userLocationKey = 'user_location';

  // Warehouse storage key
  static const String _warehouseKey = 'warehouse_data';

  // Save user location
static Future<void> saveUserLocation({
  required double latitude,
  required double longitude,
  required String pincode,
  String? address,
}) async {
  final prefs = await SharedPreferences.getInstance();

  final locationData = {
    'latitude': latitude,
    'longitude': longitude,
    'pincode': pincode,
    'address': address,
  };

  await prefs.setString(_userLocationKey, jsonEncode(locationData));
}

  // Get all location data
 static Future<Map<String, dynamic>?> getUserLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_userLocationKey);
  if (json == null) return null;
  return jsonDecode(json);
}

  // Warehouse storage methods
  /// Save warehouse data from serviceability response
  static Future<void> saveWarehouse(Warehouse warehouse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_warehouseKey, jsonEncode(warehouse.toJson()));
    debugPrint('✅ Warehouse saved: ${warehouse.name} (ID: ${warehouse.id})');
  }

  /// Get warehouse data
  static Future<Warehouse?> getWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    final warehouseJson = prefs.getString(_warehouseKey);

    if (warehouseJson == null) return null;

    try {
      final warehouseMap = jsonDecode(warehouseJson) as Map<String, dynamic>;
      return Warehouse.fromJson(warehouseMap);
    } catch (e) {
      debugPrint('Error parsing warehouse data: $e');
      return null;
    }
  }

  /// Get warehouse ID (convenience method)
  static Future<String?> getWarehouseId() async {
    final warehouse = await getWarehouse();
    return warehouse?.id;
  }

  /// Clear warehouse data
  static Future<void> clearWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_warehouseKey);
    debugPrint('🗑️ Warehouse data cleared');
  }

  // -------------------------
  // Location Permission Tracking
  // -------------------------
  static const String _locationPermissionRequestedKey = 'location_permission_requested';

  /// Check if location permission has been requested before
  static Future<bool> hasLocationPermissionBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionRequestedKey) ?? false;
  }

  /// Mark that location permission has been requested
  static Future<void> markLocationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionRequestedKey, true);
  }

  // -------------------------
  // Cart Persistence
  // -------------------------
  static const String _cartProductsKey = 'cart_products';
  static const String _cartQuantitiesKey = 'cart_quantities';

  static Future<void> saveCart(
    List<dynamic> products,
    Map<String, int> quantities,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Serialize products (assuming they have toJson)
    final productsJson = products.map((p) => p.toJson()).toList();
    await prefs.setString(_cartProductsKey, jsonEncode(productsJson));

    // Serialize quantities
    await prefs.setString(_cartQuantitiesKey, jsonEncode(quantities));
  }

  static Future<Map<String, dynamic>> getCart() async {
    final prefs = await SharedPreferences.getInstance();

    final productsString = prefs.getString(_cartProductsKey);
    final quantitiesString = prefs.getString(_cartQuantitiesKey);

    final List<dynamic> productsJson = productsString != null
        ? jsonDecode(productsString)
        : [];

    final Map<String, int> quantities = quantitiesString != null
        ? Map<String, int>.from(jsonDecode(quantitiesString))
        : {};

    return {
      'products': productsJson, // returns List<dynamic> (json maps)
      'quantities': quantities,
    };
  }

  static Future<String?> getPincode() async {
  final location = await getUserLocation();
  return location?['pincode'] as String?;
}


// Save profile image path
static Future<void> saveProfileImagePath(String path) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_profileImagePathKey, path);
}

// Get profile image path
static Future<String?> getProfileImagePath() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_profileImagePathKey);
}

// Clear profile image
static Future<void> clearProfileImage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_profileImagePathKey);
}

 static Future<void> saveLastUsedAddress(Map<String, String> address) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('last_address_id', address['id'] ?? '');
  await prefs.setString('last_address_label', address['label'] ?? '');
  await prefs.setString('last_address', address['address'] ?? '');
  await prefs.setString('last_address_pincode', address['pincode'] ?? '');
}

static Future<Map<String, String>?> getLastUsedAddress() async {
  final prefs = await SharedPreferences.getInstance();

  final id = prefs.getString('last_address_id');
  final label = prefs.getString('last_address_label');
  final address = prefs.getString('last_address');
  final pincode = prefs.getString('last_address_pincode');

  if (id == null) return null;

  return {
    'id': id,
    'label': label ?? '',
    'address': address ?? '',
    'pincode': pincode ?? '',
  };
}
static const String _keyFirstTime = 'is_first_time';

static Future<void> setNotFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyFirstTime, false);
}

static Future<bool> isFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyFirstTime) ?? true;
}
}
