import 'package:flutter_bloc/flutter_bloc.dart';

class OrderStatusState {

  OrderStatusState({
    required this.hasActiveOrder,
    required this.eta,
  });

  factory OrderStatusState.initial() =>
      OrderStatusState(hasActiveOrder: false, eta: '');
  final bool hasActiveOrder;
  final String eta;
}

class OrderStatusCubit extends Cubit<OrderStatusState> {
  OrderStatusCubit() : super(OrderStatusState.initial());

  void setOrderPreparing(String eta) {
    emit(OrderStatusState(hasActiveOrder: true, eta: eta));
  }

  void clearOrder() {
    emit(OrderStatusState.initial());
  }
}
