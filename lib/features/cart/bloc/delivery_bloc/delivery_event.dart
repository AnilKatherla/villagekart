abstract class DeliveryEvent {}

class FetchDeliveryTypes extends DeliveryEvent {}


class CreateOrderEvent extends DeliveryEvent {
  final String? addressId;
  final String deliveryType;
  final String? specialInstructions;
  final String? warehouseId;
  final String? orderStatus;
  final double? couponDiscount;
  final String? couponCode;
  final double? discount;
  final String? deliveryDate;
  final String? deliverySlot;
  final String? routeMapId;
  final String? pickupSlotId;

  CreateOrderEvent({
    required this.addressId,
    required this.deliveryType,
    this.specialInstructions,
    this.warehouseId,
    this.orderStatus,
    this.couponDiscount,
    this.couponCode,
    this.discount,
    this.deliveryDate,
    this.deliverySlot,
    this.routeMapId,
    this.pickupSlotId,
  });
}
