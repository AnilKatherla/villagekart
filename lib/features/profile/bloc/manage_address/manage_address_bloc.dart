// ============================================================================
// UPDATED ADDRESS BLOC (address_bloc.dart)
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'manage_address_event.dart';
import 'manage_address_service.dart';
import 'manage_address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressInitial()) {
    on<FetchAddresses>(_onFetchAddresses);
    on<RefreshAddresses>(_onRefreshAddresses);
    on<DeleteAddress>(_onDeleteAddress);
    on<SelectAddress>(_onSelectAddress);
  }

  List<Address> userAddresses = [];
  LatLng? selectedLatLng;
  Address? selectedAddress;

  /// Handle initial fetch of addresses
  Future<void> _onFetchAddresses(
    FetchAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final addressesResponse = await AddressService.fetchAddresses();

      if (addressesResponse.data.addresses.isEmpty) {
        emit(AddressEmpty(message: 'No addresses found'));
      } else {
        userAddresses = addressesResponse.data.addresses;
        // Auto-select first address as default
        if (selectedAddress == null && userAddresses.isNotEmpty) {
          selectedAddress = userAddresses.first;
          selectedLatLng = selectedAddress?.location != null
              ? LatLng(
                  selectedAddress!.location!.lat,
                  selectedAddress!.location!.lng,
                )
              : null;
        }
        emit(AddressLoaded(addresses: userAddresses));
      }
    } catch (e) {
      emit(AddressError(errorMessage: e.toString()));
    }
  }

  /// Handle refresh of addresses
  Future<void> _onRefreshAddresses(
    RefreshAddresses event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    if (currentState is AddressLoaded) {
      emit(AddressRefreshing(addresses: currentState.addresses));
    }

    try {
      final addressesResponse = await AddressService.fetchAddresses();

      if (addressesResponse.data.addresses.isEmpty) {
        emit(AddressEmpty(message: 'No addresses found'));
      } else {
        userAddresses = addressesResponse.data.addresses;
        emit(AddressLoaded(addresses: addressesResponse.data.addresses));
      }
    } catch (e) {
      if (currentState is AddressLoaded) {
        emit(currentState); // Revert to previous state
      }
      emit(AddressError(errorMessage: e.toString()));
    }
  }

  /// Handle delete address
  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;

    if (currentState is AddressLoaded) {
      emit(
        AddressDeleting(
          addresses: currentState.addresses,
          deletingAddressId: event.addressId,
        ),
      );

      try {
        await AddressService.deleteAddress(addressId: event.addressId);

        // Remove the address from list
        final updatedAddresses = currentState.addresses
            .where((address) => address.id != event.addressId)
            .toList();

        // If we deleted the selected address, select a new one
        if (selectedAddress?.id == event.addressId) {
          selectedAddress = updatedAddresses.isNotEmpty ? updatedAddresses.first : null;
          selectedLatLng = selectedAddress?.location != null
              ? LatLng(
                  selectedAddress!.location!.lat,
                  selectedAddress!.location!.lng,
                )
              : null;
        }

        if (updatedAddresses.isEmpty) {
          emit(AddressEmpty(message: 'No addresses found'));
        } else {
          emit(
            AddressDeleted(
              addresses: updatedAddresses,
              message: 'Address deleted successfully',
            ),
          );
          // Emit loaded state after showing deletion message
          userAddresses = updatedAddresses;
          emit(AddressLoaded(addresses: userAddresses));
        }
      } catch (e) {
        emit(currentState); // Revert to previous state
        emit(AddressError(errorMessage: e.toString()));
      }
    }
  }

  /// Handle selecting an address
  void _onSelectAddress(
    SelectAddress event,
    Emitter<AddressState> emit,
  ) {
    selectedAddress = event.address;
    selectedLatLng = event.address.location != null
        ? LatLng(
            event.address.location!.lat,
            event.address.location!.lng,
          )
        : null;

    emit(AddressSelected(
      address: event.address,
      latLng: selectedLatLng,
    ));
  }

  /// Helper method to get current location from device
  Future<void> getCurrentLocation() async {
    try {
      // You'll need to implement geolocation here
      // For now, we'll use a default location if no address is selected
      if (selectedLatLng == null && userAddresses.isNotEmpty) {
        final defaultAddress = userAddresses.firstWhere(
          (address) => address.location != null,
          orElse: () => userAddresses.first,
        );
        
        if (defaultAddress.location != null) {
          selectedLatLng = LatLng(
            defaultAddress.location!.lat,
            defaultAddress.location!.lng,
          );
          selectedAddress = defaultAddress;
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }
}