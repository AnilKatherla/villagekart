abstract class DeliverySlotEvent {}

class FetchDeliverySlots extends DeliverySlotEvent {
  final String pincode;
  final String date;

  FetchDeliverySlots({required this.pincode, required this.date});
}

class SelectDeliverySlot extends DeliverySlotEvent {
  final String slotId;

  SelectDeliverySlot(this.slotId);
}

// 🔥 NEW EVENT
class ResetDeliverySlot extends DeliverySlotEvent {}
