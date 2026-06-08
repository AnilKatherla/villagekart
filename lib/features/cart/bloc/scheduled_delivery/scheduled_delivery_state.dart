import 'package:villag_kart/features/cart/model/scheduled_delivery_model.dart';

abstract class DeliverySlotState {}

class DeliverySlotInitial extends DeliverySlotState {}

class DeliverySlotLoading extends DeliverySlotState {}

class DeliverySlotLoaded extends DeliverySlotState {
  final DeliverySlotResponseModel data;
  final String? selectedSlotId;
  final String date; // ✅ track which date these slots belong to

  DeliverySlotLoaded({
    required this.data,
    required this.date,
    this.selectedSlotId,
  });

  DeliverySlotLoaded copyWith({
    DeliverySlotResponseModel? data,
    String? selectedSlotId,
    String? date, // optional override
  }) {
    return DeliverySlotLoaded(
      data: data ?? this.data,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
      date: date ?? this.date,
    );
  }
}

class DeliverySlotError extends DeliverySlotState {
  final String message;

  DeliverySlotError(this.message);
}
