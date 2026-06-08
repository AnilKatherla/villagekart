// ============================================================================
// 1. ORDER TRACKING MODELS (Add to order_model.dart)
// ============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';

class OrderTrackingResponse {
  final bool status;
  final String response;
  final OrderTrackingData data;

  OrderTrackingResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: OrderTrackingData.fromJson(json['data'] ?? {}),
    );
  }
}

class OrderTrackingData {
  final String orderId;
  final String orderNumber;
  final String status;
  final String currentStatus;
  final List<TimelineEvent> timeline;
  final DeliveryAddressInfo deliveryAddress;
  final DateTime? estimatedDelivery;

  OrderTrackingData({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.currentStatus,
    required this.timeline,
    required this.deliveryAddress,
    this.estimatedDelivery,
  });

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    return OrderTrackingData(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'PENDING',
      currentStatus: json['currentStatus'] ?? 'PENDING',
      timeline: (json['timeline'] as List?)
              ?.map((e) => TimelineEvent.fromJson(e))
              .toList() ??
          [],
      deliveryAddress:
          DeliveryAddressInfo.fromJson(json['deliveryAddress'] ?? {}),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
    );
  }
}

class TimelineEvent {
  final String status;
  final DateTime timestamp;
  final String message;

  TimelineEvent({
    required this.status,
    required this.timestamp,
    required this.message,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      status: json['status'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      message: json['message'] ?? '',
    );
  }

  // Get human-readable status
  String get statusLabel {
    switch (status) {
      case 'ORDER_PLACED':
        return 'Order Placed';
      case 'ORDER_CONFIRMED':
        return 'Order Confirmed';
      case 'PREPARING':
        return 'Preparing Order';
      case 'READY_FOR_DELIVERY':
        return 'Ready for Delivery';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Get status icon
  IconData get statusIcon {
    switch (status) {
      case 'ORDER_PLACED':
        return Icons.shopping_cart;
      case 'ORDER_CONFIRMED':
        return Icons.check_circle;
      case 'PREPARING':
        return Icons.hourglass_empty;
      case 'READY_FOR_DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'OUT_FOR_DELIVERY':
        return Icons.local_shipping;
      case 'DELIVERED':
        return Icons.done_all;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case 'ORDER_PLACED':
        return Colors.blue;
      case 'ORDER_CONFIRMED':
        return Colors.orange;
      case 'PREPARING':
        return Colors.orange;
      case 'READY_FOR_DELIVERY':
        return Colors.purple;
      case 'OUT_FOR_DELIVERY':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Format timestamp for display
  String get formattedTime {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return formattedTime;
    }
  }
}

class DeliveryAddressInfo {
  final String city;
  final String state;
  final String pincode;

  DeliveryAddressInfo({
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory DeliveryAddressInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressInfo(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  String get fullAddress => '$city, $state $pincode';
}