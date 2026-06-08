import 'package:villag_kart/features/cart/model/create_order_schedule_model.dart';

abstract class CreateScheduledOrderState {}

class CreateScheduledOrderInitial extends CreateScheduledOrderState {}

class CreateScheduledOrderLoading extends CreateScheduledOrderState {}

class CreateScheduledOrderSuccess extends CreateScheduledOrderState {
  final CreateScheduledOrderResponse response;

  CreateScheduledOrderSuccess({required this.response});
}

class CreateScheduledOrderFailure extends CreateScheduledOrderState {
  final String message;

  CreateScheduledOrderFailure({required this.message});
}
