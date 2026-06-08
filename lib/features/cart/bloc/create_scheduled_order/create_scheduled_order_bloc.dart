import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_event.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_state.dart';
import 'package:villag_kart/features/cart/services/create_schedule_order_api.dart';

class CreateScheduledOrderBloc
    extends Bloc<CreateScheduledOrderEvent, CreateScheduledOrderState> {

  final CreateScheduledOrderApiService apiService;

  CreateScheduledOrderBloc({required this.apiService})
      : super(CreateScheduledOrderInitial()) {
    on<SubmitCreateScheduledOrder>(_onSubmitCreateScheduledOrder);
  }

  Future<void> _onSubmitCreateScheduledOrder(
    SubmitCreateScheduledOrder event,
    Emitter<CreateScheduledOrderState> emit,
  ) async {
    emit(CreateScheduledOrderLoading());

    try {
      final response = await apiService.createScheduledOrder(
        request: event.request,
      );

      emit(CreateScheduledOrderSuccess(response: response));
    } catch (e) {
      emit(CreateScheduledOrderFailure(message: e.toString()));
    }
  }
}
