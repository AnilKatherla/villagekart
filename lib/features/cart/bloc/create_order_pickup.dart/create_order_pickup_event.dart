import 'package:villag_kart/features/cart/model/create_order_pickup_model.dart';

abstract class CreateOrderPickupEvent {}

class CreateOrderPickupOrder extends CreateOrderPickupEvent {
  final CreateOrderRequest request;

  CreateOrderPickupOrder(this.request);
}
