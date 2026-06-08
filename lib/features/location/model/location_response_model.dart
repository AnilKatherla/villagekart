// =======================
// LOCATION RESPONSE MODEL
// =======================

class LocationResponseModel {
  final bool success;
  final LocationData data;
  final String message;

  LocationResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory LocationResponseModel.fromJson(Map<String, dynamic> json) {
    return LocationResponseModel(
      success: json['success'] ?? false,
      data: LocationData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

// =======================
// LOCATION DATA
// =======================
class LocationData {
  final bool serviceable;
  final Warehouse? warehouse;
  final String reason;
  final List<Warehouse>? availableWarehouses;

  LocationData({
    required this.serviceable,
    required this.warehouse,
    required this.reason,
    required this.availableWarehouses,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      serviceable: json['serviceable'] ?? false,
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'])
          : null,
      reason: json['reason'] ?? '',
      availableWarehouses: (json['availableWarehouses'] as List? ?? [])
          .map((e) => Warehouse.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceable': serviceable,
      'warehouse': warehouse?.toJson(),
      'reason': reason,
      'availableWarehouses': availableWarehouses
          ?.map((e) => e.toJson())
          .toList(),
    };
  }
}

// =======================
// WAREHOUSE MODEL
// =======================

class Warehouse {
  final String id;
  final String name;
  final String code;
  final List<String> servicePincodes;
  final WarehouseLocation location;
  final String address;
  final String? phone;
  final String? state;
  final String? imageUrl;

  /// UI-only field
  double distance;

  Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.servicePincodes,
    required this.location,
    required this.address,
    this.phone,
    this.state,
    this.imageUrl,
    this.distance = 0.0,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      servicePincodes: List<String>.from(json['servicePincodes'] ?? []),
      location: WarehouseLocation.fromJson(json['location'] ?? {}),
      address: json['address'] ?? '',
      phone: json['phone'],
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '',
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'servicePincodes': servicePincodes,
      'location': location.toJson(),
      'address': address,
      'phone': phone,
      'state': state,
      'imageUrl': imageUrl,
      'distance': distance, // optional
    };
  }
}

// =======================
// WAREHOUSE LOCATION
// =======================

class WarehouseLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? label;
  final String? colony;
  final String? pincode;
  final String? state;

  WarehouseLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.label,
    this.colony,
    this.pincode,
    this.state,
  });

  factory WarehouseLocation.fromJson(Map<String, dynamic> json) {
    return WarehouseLocation(
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      city: json['city'],
      label: json['label'],
      colony: json['colony'],
      pincode: json['pincode'],
      state: json['state'],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'label': label,
      'colony': colony,
      'pincode': pincode,
      'state': state,
    };
  }
}

// =======================
// USER LOCATION (LOCAL)
// =======================

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? pincode;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.pincode,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      pincode: json['pincode'],
    );
  }
}

// =======================
// EXISTING STORE MODEL (UNCHANGED)
// =======================

class StoreModel {
  final int id;
  final String name;
  final String storeName;
  final String latitude;
  final String longitude;
  final String placeName;
  final String formattedAddress;
  final double distance;
  final int maxDeliverableDistance;
  final String logoUrl;

  StoreModel({
    required this.id,
    required this.name,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.formattedAddress,
    required this.distance,
    required this.maxDeliverableDistance,
    required this.logoUrl,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      storeName: json['store_name'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      placeName: json['place_name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      maxDeliverableDistance: json['max_deliverable_distance'] ?? 0,
      logoUrl: json['logo_url'] ?? '',
    );
  }
}

class ServiceabilityAddressResponse {
  final bool success;
  final bool serviceable;
  final String reason;
  final String message;

  ServiceabilityAddressResponse({
    required this.success,
    required this.serviceable,
    required this.reason,
    required this.message,
  });

  factory ServiceabilityAddressResponse.fromJson(Map<String, dynamic> json) {
    return ServiceabilityAddressResponse(
      success: json['success'],
      serviceable: json['data']['serviceable'],
      reason: json['data']['reason'],
      message: json['message'],
    );
  }
}
