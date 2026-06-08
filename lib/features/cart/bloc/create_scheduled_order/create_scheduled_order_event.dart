
import 'package:villag_kart/features/cart/model/create_order_schedule_model.dart';

abstract class CreateScheduledOrderEvent {}

class SubmitCreateScheduledOrder extends CreateScheduledOrderEvent {
  final CreateScheduledOrderRequest request;

  SubmitCreateScheduledOrder({required this.request});
}
