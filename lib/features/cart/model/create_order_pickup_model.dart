class CreateOrderRequest {
  final String deliveryType;
  final String warehouseId;
  final String pickupTimeSlot;
  final String ?orderStatus;
  final String? specialinstructions;
  final String? couponCode;
  final double? discount;
  final String? addressId;
  final String? deliveryDate;
  final String? deliverySlot;
  final String? routeMapId;
  final String? pickupSlotId;

  CreateOrderRequest({
    required this.deliveryType,
    required this.warehouseId,
    required this.pickupTimeSlot,
    this.orderStatus,
    this.specialinstructions,
    this.couponCode,
    this.discount,
    this.addressId,
    this.deliveryDate,
    this.deliverySlot,
    this.routeMapId,
    this.pickupSlotId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "deliveryType": deliveryType,
      "warehouseId": warehouseId,
      "pickupTimeSlot": pickupTimeSlot,
      'specialInstructions': specialinstructions,
    };
    if (orderStatus != null) {
      data["orderStatus"] = orderStatus;
    }
    if (couponCode != null && couponCode!.isNotEmpty) {
      data["couponCode"] = couponCode;
    }
    if (discount != null) {
      data["discount"] = discount;
    }
    if (addressId != null && addressId!.isNotEmpty) {
      data["addressId"] = addressId;
    }
    if (deliveryDate != null && deliveryDate!.isNotEmpty) {
      data["deliveryDate"] = deliveryDate;
    }
    if (deliverySlot != null && deliverySlot!.isNotEmpty) {
      data["deliverySlot"] = deliverySlot;
    }
    if (routeMapId != null && routeMapId!.isNotEmpty) {
      data["routeMapId"] = routeMapId;
    }
    if (pickupSlotId != null && pickupSlotId!.isNotEmpty) {
      data["pickupSlotId"] = pickupSlotId;
    }

    return data;
  }
}

class CreateOrderResponse {
  final bool status;
  final String response;
  final CreateOrderData data;

  CreateOrderResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      status: json['status'],
      response: json['response'],
      data: CreateOrderData.fromJson(json['data']),
    );
  }
}

class CreateOrderData {
  final Order order;

  CreateOrderData({required this.order});

  factory CreateOrderData.fromJson(Map<String, dynamic> json) {
    return CreateOrderData(
      order: Order.fromJson(json['order']),
    );
  }
}

class Order {
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
  final String? deliveryDate;
  final bool? isScheduled;
  final String? specialInstructions;
  final String? couponCode;
  final double couponDiscount;
  final String createdAt;
  final String updatedAt;
  final Address address;
  final List<OrderItem> items;
  final Payment payment;
  final Delivery? delivery;

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
    required this.address,
    required this.items,
    required this.payment,
    this.delivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      status: json['status'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      cgst: (json['cgst'] as num).toDouble(),
      sgst: (json['sgst'] as num).toDouble(),
      igst: (json['igst'] as num).toDouble(),
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
      deliverySlot: json['deliverySlot'],
      deliveryDate: json['deliveryDate'],
      isScheduled: json['isScheduled'],
      specialInstructions: json['specialInstructions'],
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] as num).toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      address: Address.fromJson(json['address']),
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      payment: Payment.fromJson(json['payment']),
      delivery: Delivery.fromJson(json['delivery']),
    );
  }
}

class Address {
  final String id;
  final String label;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pincode;
  final Location? location;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.location,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location']),
    
      isDefault: json['isDefault'],
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class OrderItem {
  final String id;
  final Product product;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double discount;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
    );
  }
}
class Product {
  final String id;
  final String name;
  final List<String> images;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.images,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      unit: json['unit'],
    );
  }
}

class Payment {
  final String id;
  final String method;
  final double amount;
  final String status;

  Payment({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      method: json['method'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
    );
  }
}


class Delivery {
  final String id;
  final String status;
  final String? name;
  final String? phone;

  Delivery({
    required this.id,
    required this.status,
    this.name,
    this.phone,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}