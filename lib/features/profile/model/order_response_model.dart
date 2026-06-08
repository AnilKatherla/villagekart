
// ============================= CANCEL RESPONSES =============================
import 'package:villag_kart/features/profile/model/invoice_model.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';

class CancelOrderResponse {
  final bool status;
  final String response;
  final CancelOrderData data;

  CancelOrderResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: CancelOrderData.fromJson(json['data'] ?? {}),
    );
  }
}

class CancelOrderData {
  final String orderId;
  final String status;
  final String message;

  CancelOrderData({
    required this.orderId,
    required this.status,
    required this.message,
  });

  factory CancelOrderData.fromJson(Map<String, dynamic> json) {
    return CancelOrderData(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class CancelItemResponse {
  final bool status;
  final String response;
  final CancelItemData data;

  CancelItemResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory CancelItemResponse.fromJson(Map<String, dynamic> json) {
    return CancelItemResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: CancelItemData.fromJson(json['data'] ?? {}),
    );
  }
}

class CancelItemData {
  final String orderId;
  final String itemId;
  final String status;
  final String message;

  CancelItemData({
    required this.orderId,
    required this.itemId,
    required this.status,
    required this.message,
  });

  factory CancelItemData.fromJson(Map<String, dynamic> json) {
    return CancelItemData(
      orderId: json['orderId'] ?? '',
      itemId: json['itemId'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// ============================= TRACKING RESPONSES =============================
class OrderTrackingResponse {
  final bool status;
  final String response;
  final TrackingData data;

  OrderTrackingResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: TrackingData.fromJson(json['data'] ?? {}),
    );
  }
}

class TrackingData {
  final String orderId;
  final String orderNumber;
  final String status;
  final String currentStatus;
  final List<TrackingEvent> timeline;
  final DeliveryAddress deliveryAddress;
  final String? estimatedDelivery;

  TrackingData({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.currentStatus,
    required this.timeline,
    required this.deliveryAddress,
    this.estimatedDelivery,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
      timeline: (json['timeline'] as List?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      estimatedDelivery: json['estimatedDelivery'],
    );
  }
}

class TrackingEvent {
  final String status;
  final DateTime timestamp;
  final String message;

  TrackingEvent({
    required this.status,
    required this.timestamp,
    required this.message,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    final rawTs = json['timestamp'];
    DateTime ts;
    if (rawTs is String) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.tryParse(rawTs?.toString() ?? '') ?? DateTime.now();
    }
    return TrackingEvent(
      status: json['status'] ?? '',
      timestamp: ts,
      message: json['message'] ?? '',
    );
  }
}

class DeliveryAddress {
  final String city;
  final String state;
  final String pincode;

  DeliveryAddress({
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

// ============================= LIVE TRACKING RESPONSE =============================
class LiveTrackingResponse {
  final bool status;
  final String response;
  final LiveTrackingData data;

  LiveTrackingResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory LiveTrackingResponse.fromJson(Map<String, dynamic> json) {
    return LiveTrackingResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: LiveTrackingData.fromJson(json['data'] ?? {}),
    );
  }
}

class LiveTrackingData {
  final String orderId;
  final String orderNumber;
  final String status;
  final String deliveryStatus;
  final DeliveryAgent? agent;
  final Location? currentLocation;
  final TrackingLocation pickupLocation;
  final TrackingLocation deliveryLocation;
  final String? eta;
  final String? distance;
  final List<TrackingEvent> timeline;
  final DateTime lastUpdate;

  LiveTrackingData({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.deliveryStatus,
    this.agent,
    this.currentLocation,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.eta,
    this.distance,
    required this.timeline,
    required this.lastUpdate,
  });

  factory LiveTrackingData.fromJson(Map<String, dynamic> json) {
    return LiveTrackingData(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      deliveryStatus: json['deliveryStatus'] ?? '',
      agent: json['agent'] != null ? DeliveryAgent.fromJson(json['agent']) : null,
      currentLocation: json['currentLocation'] != null
          ? Location.fromJson(json['currentLocation'])
          : null,
      pickupLocation: TrackingLocation.fromJson(json['pickupLocation'] ?? {}),
      deliveryLocation: TrackingLocation.fromJson(json['deliveryLocation'] ?? {}),
      eta: json['eta'],
      distance: json['distance'],
      timeline: (json['timeline'] as List?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class DeliveryAgent {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final double rating;

  DeliveryAgent({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.rating,
  });

  factory DeliveryAgent.fromJson(Map<String, dynamic> json) {
    return DeliveryAgent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrackingLocation {
  final double lat;
  final double lng;
  final String address;

  TrackingLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory TrackingLocation.fromJson(Map<String, dynamic> json) {
    return TrackingLocation(
      lat: (json['latitude'] ?? json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['longitude'] ?? json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
    );
  }
}

// ============================= INVOICE RESPONSE =============================
class InvoiceResponse {
  final bool status;
  final String response;
  final InvoiceData data;

  InvoiceResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: InvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

class CustomerInfo {
  final String? name;
  final String phone;
  final String? email;

  CustomerInfo({
    this.name,
    required this.phone,
    this.email,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}

class ShippingAddress {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;

  ShippingAddress({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class WarehouseInfo {
  final String name;
  final String address;
  final String? phone;

  WarehouseInfo({
    required this.name,
    required this.address,
    this.phone,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final String? hsnCode;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    this.hsnCode,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      hsnCode: json['hsnCode'],
    );
  }
}

class InvoiceSummary {
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double deliveryCharge;
  final double totalAmount;

  InvoiceSummary({
    required this.subtotal,
    required this.discount,
    required this.taxableAmount,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.deliveryCharge,
    required this.totalAmount,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentDetails {
  final String method;
  final String status;
  final double amount;

  PaymentDetails({
    required this.method,
    required this.status,
    required this.amount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}