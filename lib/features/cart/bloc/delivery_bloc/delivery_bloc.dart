import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_event.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_state.dart';
import 'package:villag_kart/features/cart/model/order_create_response.dart';
import 'package:villag_kart/features/cart/services/delivery_api_service.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryApiService apiService;

  DeliveryBloc(this.apiService) : super(DeliveryInitial()) {
    on<FetchDeliveryTypes>(_onFetchDeliveryTypes);
    on<CreateOrderEvent>(_onCreateOrder);
  }

  Future<void> _onFetchDeliveryTypes(
    FetchDeliveryTypes event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    try {
      final warehouseId = await SharedPrefs.getWarehouseId();

      if (warehouseId == null || warehouseId.isEmpty) {
        emit(DeliveryError('Warehouse ID not found'));
        return;
      }

      final data = await apiService.getDeliveryTypes(
        warehouseId: warehouseId,
      );

      emit(DeliveryLoaded(data));
    } catch (e) {
      emit(DeliveryError(e.toString()));
    }
  }

  //  CREATE ORDER METHOD
  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(OrderCreating());

  try {
    final OrderCreateResponse orderResponse =
        await apiService.createOrder(
      addressId: event.addressId ?? '',
      deliveryType: event.deliveryType,
      specialInstructions: event.specialInstructions,
      warehouseId: event.warehouseId ?? '',
      orderStatus: event.orderStatus ?? 'PLACED',
      deliveryDate: event.deliveryDate,
      deliverySlot: event.deliverySlot,
      routeMapId: event.routeMapId,
      couponCode: event.couponCode,
      pickupSlotId: event.pickupSlotId,
    );

    emit(OrderCreated(orderResponse)); // ✔ matches state
  } catch (e) {
    emit(DeliveryError(e.toString()));
  }
  }
}
