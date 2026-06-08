import 'package:equatable/equatable.dart';

abstract class PickupSlotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPickupSlots extends PickupSlotEvent {
  final String warehouseId;
  final String date;

  FetchPickupSlots({
    required this.warehouseId,
    required this.date,
  });

  @override
  List<Object?> get props => [warehouseId, date];
}
