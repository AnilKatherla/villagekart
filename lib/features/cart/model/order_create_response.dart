class OrderCreateResponse {
  final bool status;
  final String response;
  final OrderData data;

  OrderCreateResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
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
  final double totalAmount;
  final double deliveryCharge;
  final double taxableAmount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.taxableAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
    );
  }
}
