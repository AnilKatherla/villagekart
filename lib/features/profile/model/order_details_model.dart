class OrderDetailsResponse {
  final bool status;
  final String response;
  final OrderData data;

  OrderDetailsResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory OrderDetailsResponse.fromJson(
      Map<String,dynamic> json) {
    return OrderDetailsResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: OrderData.fromJson(
        json['data'] ?? {},
      ),
    );
  }
}

class OrderData {
  final OrderDetails order;

  OrderData({
    required this.order,
  });

  factory OrderData.fromJson(
      Map<String,dynamic> json){
    return OrderData(
      order: OrderDetails.fromJson(
        json['order'] ?? {},
      ),
    );
  }
}

class OrderDetails {
  final String id;
  final String orderNumber;
  final String status;
  final String orderStatusLabel;

  final double totalAmount;
  final double deliveryCharge;
  final double taxableAmount;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Address address;
  final List<OrderItem> items;
  final Payment payment;
  final Delivery delivery;

  OrderDetails({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderStatusLabel,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.taxableAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    required this.items,
    required this.payment,
    required this.delivery,
  });

  factory OrderDetails.fromJson(
      Map<String,dynamic> json){
    return OrderDetails(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      orderStatusLabel:
         json['orderStatusLabel'] ?? '',

      totalAmount:
      (json['totalAmount'] as num?)
          ?.toDouble() ?? 0,

      deliveryCharge:
      (json['deliveryCharge'] as num?)
          ?.toDouble() ?? 0,

      taxableAmount:
      (json['taxableAmount'] as num?)
          ?.toDouble() ?? 0,

      createdAt:
      DateTime.parse(json['createdAt']),

      updatedAt:
      DateTime.parse(json['updatedAt']),

      address:
      Address.fromJson(
         json['address'] ?? {},
      ),

      items:
      (json['items'] as List?)
          ?.map(
             (e)=>OrderItem.fromJson(e),
           ).toList()
           ?? [],

      payment:
      Payment.fromJson(
        json['payment'] ?? {},
      ),

      delivery:
      Delivery.fromJson(
        json['delivery'] ?? {},
      ),
    );
  }
}

class Address {
 final String line1;
 final String line2;
 final String city;
 final String state;
 final String pincode;

 Address({
  required this.line1,
  required this.line2,
  required this.city,
  required this.state,
  required this.pincode,
 });

 factory Address.fromJson(
   Map<String,dynamic> json){
   return Address(
    line1: json['line1'] ?? '',
    line2: json['line2'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
   );
 }
}

class OrderItem {
 final String id;
 final String productName;
 final int quantity;
 final double totalPrice;

 OrderItem({
   required this.id,
   required this.productName,
   required this.quantity,
   required this.totalPrice,
 });

 factory OrderItem.fromJson(
   Map<String,dynamic> json){
   return OrderItem(
     id: json['id'] ?? '',
     productName:
       json['product']['name'] ?? '',
     quantity:
       json['quantity'] ?? 0,
     totalPrice:
      (json['totalPrice'] as num?)
         ?.toDouble() ?? 0,
   );
 }
}

class Payment {
 final String method;
 final String status;
 final double amount;

 Payment({
  required this.method,
  required this.status,
  required this.amount,
 });

 factory Payment.fromJson(
   Map<String,dynamic> json){
   return Payment(
    method: json['method'] ?? '',
    status: json['status'] ?? '',
    amount:
      (json['amount'] as num?)
          ?.toDouble() ?? 0,
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

 factory Delivery.fromJson(
   Map<String,dynamic> json){
   return Delivery(
    id: json['id'] ?? '',
    status: json['status'] ?? '',
    name: json['name'],
    phone: json['phone'],
   );
 }
}