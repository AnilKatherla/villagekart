class CreateScheduledOrderRequest {
  final String addressId;
  final String deliveryType;
  final String deliverySlot;
  final String deliveryDate;
  final String? couponCode;
  final String? orderStatus;
  final String? warehouseId;
  final String? specialInstructions;
  final int? discount;

  CreateScheduledOrderRequest ({
    required this.addressId,
    required this.deliveryType,
    required this.deliverySlot,
    required this.deliveryDate,
    this.couponCode,
    this.orderStatus,
    this.warehouseId,
    this.specialInstructions,
    this.discount
  });

  Map<String, dynamic> toJson() {
    return {
      "addressId": addressId,
      "deliveryType": deliveryType,
      "deliverySlot": deliverySlot,
      "deliveryDate": deliveryDate,
      'orderStatus': orderStatus,
      'warehouseId': warehouseId,
      'specialInstructions' : specialInstructions,
      if(discount != null) "discount" : discount,
      if (couponCode != null) "couponCode": couponCode,
    };
  }
}

class CreateScheduledOrderResponse {
  final bool status;
  final String response;
  final OrderData data;

  CreateScheduledOrderResponse ({
    required this.status,
    required this.response,
    required this.data,
  });

  factory CreateScheduledOrderResponse .fromJson(Map<String, dynamic> json) {
    return CreateScheduledOrderResponse (
      status: json['status'],
      response: json['response'],
      data: OrderData.fromJson(json['data']),
    );
  }
}
class OrderData {
  final Order order;

  OrderData({required this.order});

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
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
  final double taxableAmount;
  final String deliverySlot;
  final DateTime deliveryDate;
  final bool isScheduled;
  final Address address;
  final List<OrderItem> items;
  final Payment payment;
  final Delivery delivery;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.discount,
    required this.taxAmount,
    required this.taxableAmount,
    required this.deliverySlot,
    required this.deliveryDate,
    required this.isScheduled,
    required this.address,
    required this.items,
    required this.payment,
    required this.delivery,
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
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
      deliverySlot: json['deliverySlot'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
      isScheduled: json['isScheduled'],
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

  Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.location,
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
    );
  }
}
class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

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

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
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