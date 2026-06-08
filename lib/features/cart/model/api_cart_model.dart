import 'package:villag_kart/features/cart/model/cart_item_model.dart';

class ApiCart {
  ApiCart({required this.cartId, required this.items, required this.summary});

  factory ApiCart.fromJson(Map<String, dynamic> json) {
    return ApiCart(
      cartId: json['id'],
      items: (json['items'] as List)
          .map((i) => CartItemModel.fromJson(i))
          .toList(),
      summary: ApiCartSummary.fromJson(json['summary']),
    );
  }
  final String cartId;
  final List<CartItemModel> items;
  final ApiCartSummary summary;
}

class ApiCartSummary {
  ApiCartSummary({
    required this.itemCount,
    required this.subtotal,
    required this.total,
    required this.taxAmount,
  });

  factory ApiCartSummary.fromJson(Map<String, dynamic> json) {
    return ApiCartSummary(
      itemCount: json['itemCount'],
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
    );
  }
  final int itemCount;
  final double subtotal;
  final double total;
  final double taxAmount;
}
