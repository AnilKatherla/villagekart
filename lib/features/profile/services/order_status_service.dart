// features/profile/service/order_status_service.dart
import 'package:villag_kart/features/profile/model/order_status_model.dart';

/// Legacy helper: consumer API does not expose `GET order-statuses`.
/// Prefer order payloads / tracking endpoints for status information.
class OrderStatusService {
  Future<OrderStatusResponse> getOrderStatuses({
    required Function(OrderStatusResponse) onSuccess,
    required Function(String) onError,
  }) async {
    onSuccess(OrderStatusResponse(
      status: 1,
      message: '',
      total: 0,
      data: [],
    ));
    return OrderStatusResponse(status: 1, message: '', total: 0, data: []);
  }
}
