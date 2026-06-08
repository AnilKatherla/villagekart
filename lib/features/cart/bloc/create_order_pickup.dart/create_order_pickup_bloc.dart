import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_event.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_state.dart';
import 'package:villag_kart/features/cart/services/create_order_pickup_api_service.dart';

class CreateOrderPickupBloc extends Bloc<CreateOrderPickupEvent,CreateOrderPickupState> {
  final CreateOrderPickupApiService apiService;

  CreateOrderPickupBloc(this.apiService) : super(CreateOrderPickupInitial()) {
    on<CreateOrderPickupOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrderPickupOrder event,
    Emitter<CreateOrderPickupState> emit,
  ) async {
    emit(CreateOrderPickupLoading());
    try {
      final response =
          await apiService.createOrder(request: event.request);
      emit(CreateOrderPickupSuccess(response));
    } catch (e) {
      emit(CreateOrderPickupError(e.toString()));
    }
  }
}
