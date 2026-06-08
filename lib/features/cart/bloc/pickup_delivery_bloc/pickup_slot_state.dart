import 'package:equatable/equatable.dart';
import '../../model/pickup_slot_model.dart';

abstract class PickupSlotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickupSlotInitial extends PickupSlotState {}

class PickupSlotLoading extends PickupSlotState {}

class PickupSlotLoaded extends PickupSlotState {
  final PickupSlotResponse data;

  PickupSlotLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class PickupSlotError extends PickupSlotState {
  final String message;

  PickupSlotError(this.message);

  @override
  List<Object?> get props => [message];
}
