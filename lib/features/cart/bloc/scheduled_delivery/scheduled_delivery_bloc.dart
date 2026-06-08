import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_event.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_state.dart';
import 'package:villag_kart/features/cart/services/scheduled_delivery_api.dart';

class DeliverySlotBloc extends Bloc<DeliverySlotEvent, DeliverySlotState> {
  final DeliverySlotApiService apiService;

  DeliverySlotBloc(this.apiService) : super(DeliverySlotInitial()) {
    on<FetchDeliverySlots>(_onFetchDeliverySlots);
    on<SelectDeliverySlot>(_onSelectDeliverySlot);
    on<ResetDeliverySlot>(_onResetDeliverySlot); // optional
  }

  Future<void> _onFetchDeliverySlots(
    FetchDeliverySlots event,
    Emitter<DeliverySlotState> emit,
  ) async {
    emit(DeliverySlotLoading());

    final warehouseId = await SharedPrefs.getWarehouseId();

    try {
      final data = await apiService.getDeliverySlots(
        warehouseId:warehouseId ?? '' ,
        deliveryDate: event.date,
      );

      emit(DeliverySlotLoaded(
        data: data,
        selectedSlotId: null,   // reset selected slot on every fetch
        date: event.date,       // ✅ track date in state
      ));
    } catch (e) {
      emit(DeliverySlotError(e.toString()));
    }
  }

  void _onSelectDeliverySlot(
    SelectDeliverySlot event,
    Emitter<DeliverySlotState> emit,
  ) {
    if (state is DeliverySlotLoaded) {
      emit(
        (state as DeliverySlotLoaded).copyWith(
          selectedSlotId: event.slotId,
        ),
      );
    }
  }

  void _onResetDeliverySlot(
    ResetDeliverySlot event,
    Emitter<DeliverySlotState> emit,
  ) {
    emit(DeliverySlotInitial());
  }
}
