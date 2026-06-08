import 'package:villag_kart/features/location/model/location_response_model.dart';

abstract class CartEvent {}

class FetchCartItemsEvent extends CartEvent {
    FetchCartItemsEvent({  this.warehouseId});
    final String? warehouseId;
}

/// NEW FINAL EVENT (supports product + variant)
class CartIncrement extends CartEvent {
  final String id;
  final bool isVariant;
  final String? productId;
  final int? quantity;
  final int? maxQty;

  CartIncrement({
    required this.id,
    this.isVariant = false,
    this.productId,
    this.quantity,this.maxQty

  });
}


class CartDecrement extends CartEvent {
  final String id;
  final bool isVariant;
  final String? productId;
  final int? minQty;

  CartDecrement({
    required this.id,
    required this.isVariant,
    this.productId,
    this.minQty,
  });
}

class CartItemRemove extends CartEvent {
  final String cartItemId;

  CartItemRemove(this.cartItemId);
}

class ClearCartEvent extends CartEvent {
   ClearCartEvent();
}

class ReorderItemsEvent extends CartEvent{
 final String orderId;

  ReorderItemsEvent({required this.orderId});

  @override
  List<Object?>get props => [orderId];
}
class CartRemove extends CartEvent {
  final String id;
  final bool isVariant;
  final String productId;

  CartRemove({
    required this.id,
    required this.isVariant,
    required this.productId,
  });
}
class SwitchWarehouseEvent extends CartEvent {
  final Warehouse? warehouse;
  SwitchWarehouseEvent(this.warehouse);
}