import 'package:villag_kart/features/cart/model/create_order_pickup_model.dart';

abstract class CreateOrderPickupState {}

class CreateOrderPickupInitial extends CreateOrderPickupState {}

class CreateOrderPickupLoading extends CreateOrderPickupState {}

class CreateOrderPickupSuccess extends CreateOrderPickupState {
  final CreateOrderResponse response;
  CreateOrderPickupSuccess(this.response);
}

class CreateOrderPickupError extends CreateOrderPickupState {
  final String message;
  CreateOrderPickupError(this.message);
}
