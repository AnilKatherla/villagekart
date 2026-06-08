class RepeatOrderModel {
  final bool status;
  final String response;
  final CartData data;

  RepeatOrderModel({
    required this.status,
    required this.response,
    required this.data
  });

  factory RepeatOrderModel.fromJson(Map<String,dynamic>json){
    return RepeatOrderModel(
      status: json['status'] ?? false,
       response: json['response'] ?? '',
        data: CartData.fromJson(json['data'] ?? {}));
  }
}

class CartData{
  final List<CartItem>addedItems;
  final List<CartItem>skippedItems;
  final String message;

  CartData({
    required this.addedItems,
    required this.skippedItems,
    required this.message
  });
  factory CartData.fromJson(Map<String,dynamic>json){
    return CartData(
      addedItems: (json['addeditems'] as List?)?.map((e)=> CartItem.fromJson(e)).toList() ?? [],
       skippedItems:(json['skippeditems'] as List?)?.map((e)=>CartItem.fromJson(e)).toList() ?? [], 
       message: json['message'] ?? ' ');
  }
}

class CartItem {
  final String productId;
  final String productName;
  final int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity
  });

  factory CartItem.fromJson(Map<String,dynamic>json){
    return CartItem(
      productId: json['productId'],
       productName: json['productName'],
        quantity: json['quantity']);
  }
}