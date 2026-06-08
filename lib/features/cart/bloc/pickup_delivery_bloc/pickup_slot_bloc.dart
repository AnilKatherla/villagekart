import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/cart/services/pickup_slot_api_service.dart';
import 'pickup_slot_event.dart';
import 'pickup_slot_state.dart';


class PickupSlotBloc extends Bloc<PickupSlotEvent, PickupSlotState> {
  final PickupSlotApiService apiService;

  PickupSlotBloc(this.apiService) : super(PickupSlotInitial()) {
    on<FetchPickupSlots>(_onFetchPickupSlots);
  }

  Future<void> _onFetchPickupSlots(
    FetchPickupSlots event,
    Emitter<PickupSlotState> emit,
  ) async {
    emit(PickupSlotLoading());
    try {
      final response = await apiService.getPickupSlots(
        warehouseId: event.warehouseId, 
      );
      emit(PickupSlotLoaded(response));
    } catch (e) {
      emit(PickupSlotError(e.toString()));
    }
  }
}
