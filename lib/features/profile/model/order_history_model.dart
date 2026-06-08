// ============================================================================
// UPDATED ORDER MODEL (order_model.dart)
// Matches the actual API response structure
// ============================================================================

// ============================= ORDERS LIST RESPONSE =============================
import 'package:villag_kart/features/home/model/product_response.dart';

class OrdersResponse {
  OrdersResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: OrdersData.fromJson(json['data'] ?? {}),
    );
  }
  final bool status;
  final String response;
  final OrdersData data;
}

class OrdersData {
  OrdersData({required this.orders, required this.pagination});

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      orders:
          (json['orders'] as List?)?.map((e) => Order.fromJson(e)).toList() ??
          [],
      pagination: PaginationData.fromJson(json['pagination'] ?? {}),
    );
  }
  final List<Order> orders;
  final PaginationData pagination;
}

class PaginationData {
  PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
}

// ============================= ORDER MODEL =============================
class Order {
  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.discount,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxableAmount,
    this.deliverySlot,
    this.deliveryDate,
    this.isScheduled,
    this.specialInstructions,
    this.couponCode,
    required this.couponDiscount,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.address,
    required this.items,
    required this.payment,
    required this.delivery,
    required this.statusHistory,
    this.partner,
    this.liveRiderLat,
    this.liveRiderLng,
    this.liveRiderEta,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      deliverySlot: json['deliverySlot'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      isScheduled: json['isScheduled'],
      specialInstructions: json['specialInstructions'],
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
      address: Address.fromJson(json['address'] ?? {}),
      items:
          (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
      payment: PaymentInfo.fromJson(json['payment'] ?? {}),
      delivery: DeliveryInfo.fromJson(json['delivery'] ?? {}),
      statusHistory: json['statusHistory'] ?? [],
      partner: DeliveryPartner.fromJson(json['partner'] ?? {}),
      liveRiderLat: null,
      liveRiderLng: null,
      liveRiderEta: null,
    );
  }
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final double deliveryCharge;
  final double discount;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double taxableAmount;
  final String? deliverySlot;
  final DateTime? deliveryDate;
  final bool? isScheduled;
  final String? specialInstructions;
  final String? couponCode;
  final double couponDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Address address;
  final List<OrderItem> items;
  final PaymentInfo payment;
  final DeliveryInfo delivery;
  final List<dynamic> statusHistory;
  final DeliveryPartner? partner;
  final double? liveRiderLat;
  final double? liveRiderLng;
  final Map<String, dynamic>? liveRiderEta;

  Order copyWith({
    String? status,
    DateTime? updatedAt,
    double? liveRiderLat,
    double? liveRiderLng,
    Map<String, dynamic>? liveRiderEta,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      status: status ?? this.status,
      totalAmount: totalAmount,
      deliveryCharge: deliveryCharge,
      discount: discount,
      taxAmount: taxAmount,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      taxableAmount: taxableAmount,
      deliverySlot: deliverySlot,
      deliveryDate: deliveryDate,
      isScheduled: isScheduled,
      specialInstructions: specialInstructions,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
      address: address,
      items: items,
      payment: payment,
      delivery: delivery,
      statusHistory: statusHistory,
      partner: partner,
      liveRiderLat: liveRiderLat ?? this.liveRiderLat,
      liveRiderLng: liveRiderLng ?? this.liveRiderLng,
      liveRiderEta: liveRiderEta ?? this.liveRiderEta,
    );
  }

  // Formatted date for display
  String get formattedDate {
    final localTime = createdAt.toLocal();

    final day = localTime.day;
    final month = _getMonth(localTime.month);

    final hour = localTime.hour > 12 ? localTime.hour - 12 : localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = localTime.hour >= 12 ? 'PM' : 'AM';

    return '$day $month, $hour:$minute $period';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Check status
  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isOngoing =>
      status == 'PLACED' ||
      status == 'CONFIRMED' ||
      status == 'PROCESSING' ||
      status == 'READY_FOR_PICKUP' ||
      status == 'OUT_FOR_DELIVERY' ||
      status == 'RETURN_INITIATED';

  // Format items list
  String get formattedItems {
    if (items.isEmpty) return 'No items';
    return items
        .map((item) => '${item.product.name} X${item.quantity}')
        .join(', ');
  }

  // Format amount
  String get formattedAmount => 'Rs.${totalAmount.toStringAsFixed(2)}';

  // Get delivery address
  String get deliveryAddressText {
    return '${address.line1}, ${address.line2}, ${address.city}, ${address.state} ${address.pincode}';
  }

  // Get store name (placeholder - adjust based on your needs)
  String get storeName => 'VillagKart Store';
}

// ============================= ADDRESS MODEL =============================
class Location {
  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['latitude'] ?? json['lat'])?.toDouble() ?? 0.0,
      lng: (json['longitude'] ?? json['lng'])?.toDouble() ?? 0.0,
    );
  }
  final double lat;
  final double lng;
}

class Address {
  // Added: isDefault flag

  Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.location, // Added
    this.isDefault = false, // Added with a default value
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    // Helper to parse the optional Location object
    final locationJson = json['location'] as Map<String, dynamic>?;
    final Location? locationObj = locationJson != null
        ? Location.fromJson(locationJson)
        : null;

    return Address(
      id: json['id'] ?? '',
      label: json['label'] ?? 'Home',
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      // Handles 'isDefault' which might be missing (defaults to false)
      isDefault: json['isDefault'] ?? false,
      // Handles 'location' which might be missing (defaults to null)
      location: locationObj,
    );
  }
  final String id;
  final String label;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final Location? location; // Added: Location object (optional)
  final bool isDefault;

  String get fullAddress => '$line1, $line2, $city, $state $pincode';
}

// ============================= ORDER ITEM MODEL =============================
class OrderItem {
  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.mrp,
    required this.discount,
    required this.taxAmount,
    this.hsnCode,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      hsnCode: json['hsnCode'],
    );
  }
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? mrp;
  final double discount;
  final double taxAmount;
  final String? hsnCode;

  String get name => product.name;
  String get image => product.images.isNotEmpty ? product.images[0] : '';
  String get formattedPrice => 'Rs.${totalPrice.toStringAsFixed(2)}';
}

// ============================= PAYMENT INFO MODEL =============================
class PaymentInfo {
  PaymentInfo({required this.id, required this.method, required this.status});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] ?? '',
      method: json['method'] ?? 'COD',
      status: json['status'] ?? 'PENDING',
    );
  }
  final String id;
  final String method;
  final String status;

  bool get isPending =>
      status == 'PENDING' || status == 'INITIATED';
  bool get isPaid =>
      status == 'PAID' ||
      status == 'COMPLETED' ||
      status == 'SUCCESS';
  bool get isRefundInProgress => status == 'REFUND_PENDING';
  bool get isPartiallyRefunded => status == 'PARTIALLY_REFUNDED';
  bool get isRefunded => status == 'REFUNDED';
}

// ============================= DELIVERY INFO MODEL =============================
class DeliveryInfo {
  DeliveryInfo({required this.id, required this.status, this.name, this.phone});

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? 'PENDING',
      name: json['name'],
      phone: json['phone'],
    );
  }
  final String id;
  final String status;
  final String? name;
  final String? phone;

  bool get isPending => status == 'PENDING';
  bool get isDelivered =>
      status == 'DELIVERED' || status == 'RETURN_COMPLETED';
}

// ============================= ORDER DETAILS RESPONSE =============================
class OrderDetailsResponse {
  OrderDetailsResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: OrderDetailsData.fromJson(json['data'] ?? {}),
    );
  }
  final bool status;
  final String response;
  final OrderDetailsData data;
}

class OrderDetailsData {
  OrderDetailsData({
    required this.order,
    this.deliveryPartner,
    this.billDetails,
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    return OrderDetailsData(
      order: Order.fromJson(json['order'] ?? {}),
      deliveryPartner: json['deliveryPartner'] != null
          ? DeliveryPartner.fromJson(json['deliveryPartner'])
          : null,
      billDetails: json['billDetails'] != null
          ? BillDetails.fromJson(json['billDetails'])
          : null,
    );
  }
  final Order order;
  final DeliveryPartner? deliveryPartner;
  final BillDetails? billDetails;
}

// ============================= DELIVERY PARTNER MODEL =============================
class DeliveryPartner {
  DeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profileImage,
    required this.rating,
    required this.totalDeliveries,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Delivery Partner',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? 'assets/images/deliverypartner.png',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      totalDeliveries: json['totalDeliveries'] ?? 0,
    );
  }
  final String id;
  final String name;
  final String phone;
  final String email;
  final String profileImage;
  final double rating;
  final int totalDeliveries;
}

// ============================= BILL DETAILS MODEL =============================
class BillDetails {
  BillDetails({
    required this.itemsTotal,
    required this.discountAmount,
    required this.discountPercentage,
    required this.deliveryFee,
    required this.taxesAndCharges,
    this.packagingCharges,
    this.promoCodeApplied,
    required this.totalAmount,
    required this.paidAmount,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      itemsTotal: (json['itemsTotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      taxesAndCharges: (json['taxesAndCharges'] as num?)?.toDouble() ?? 0.0,
      packagingCharges: (json['packagingCharges'] as num?)?.toDouble(),
      promoCodeApplied: json['promoCodeApplied'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
  final double itemsTotal;
  final double discountAmount;
  final double discountPercentage;
  final double deliveryFee;
  final double taxesAndCharges;
  final double? packagingCharges;
  final String? promoCodeApplied;
  final double totalAmount;
  final double paidAmount;

  // Format amounts for display
  String get formattedItemsTotal => 'Rs.${itemsTotal.toStringAsFixed(2)}';
  String get formattedDiscount => 'Rs.${discountAmount.toStringAsFixed(2)}';
  String get formattedDeliveryFee => 'Rs.${deliveryFee.toStringAsFixed(2)}';
  String get formattedTaxes => 'Rs.${taxesAndCharges.toStringAsFixed(2)}';
  String get formattedTotal => 'Rs.${totalAmount.toStringAsFixed(2)}';
  String get formattedPaid => 'Rs.${paidAmount.toStringAsFixed(2)}';
}
