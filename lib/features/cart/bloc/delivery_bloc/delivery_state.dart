import 'package:villag_kart/features/cart/model/delivery_type_model.dart';
import 'package:villag_kart/features/cart/model/order_create_response.dart';

abstract class DeliveryState {}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryLoaded extends DeliveryState {
  final DeliveryTypesResponse data;
  DeliveryLoaded(this.data);
}

class DeliveryError extends DeliveryState {
  final String message;
  DeliveryError(this.message);
}
class OrderCreating extends DeliveryState {}
class OrderCreated extends DeliveryState {
  final OrderCreateResponse orderResponse;

  OrderCreated(this.orderResponse);
}

