// ============================================================================

import 'package:villag_kart/core/realtime/consumer_realtime_hub.dart';

abstract class OrderDetailsEvent {}

class FetchOrderDetails extends OrderDetailsEvent {
  final String orderId;

  FetchOrderDetails({required this.orderId});
}

class RefreshOrderDetails extends OrderDetailsEvent {
  final String orderId;

  RefreshOrderDetails({required this.orderId});
}

class SocketEventReceived extends OrderDetailsEvent {
  final ConsumerSocketEvent event;

  SocketEventReceived(this.event);
}