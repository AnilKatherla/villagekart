// order_status_model.dart
class OrderStatusResponse {
  OrderStatusResponse({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
  });

  final int status;
  final String message;
  final int total;
  final List<OrderStatus> data;

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusResponse(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OrderStatus.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'total': total,
    'data': data.map((item) => item.toJson()).toList(),
  };
}

class OrderStatus {
  OrderStatus({
    required this.id,
    required this.status,
  });

  final int id;
  final String status;

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
  };
}