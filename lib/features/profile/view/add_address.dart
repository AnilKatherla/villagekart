import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_bloc.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_event.dart';

import '../bloc/add_address/add_address_bloc.dart';
import '../bloc/add_address/add_address_event.dart';
import '../bloc/add_address/add_address_state.dart';
import '../model/order_history_model.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, this.existingAddress});
  final Address? existingAddress;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late AddAddressBloc _addAddressBloc;
  GoogleMapController? mapController;

  final TextEditingController line1Controller = TextEditingController();
  final TextEditingController line2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  final FocusNode _line1Focus = FocusNode();
  final FocusNode _line2Focus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _pincodeFocus = FocusNode();

  String selectedLabel = 'Home';
  final List<String> addressLabels = ['Home', 'Office', 'Hotel', 'Other'];

  LatLng selectedLocation = const LatLng(12.9716, 77.5946); // Default Bangalore

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _addAddressBloc = AddAddressBloc();
    _addAddressBloc.add(UpdateLabel(label: 'Home'));
    if (widget.existingAddress != null) {
      _addAddressBloc.add(
        InitializeAddAddress(existingAddress: widget.existingAddress),
      );
      _populateFields();
    }
  }

  void _populateFields() {
    if (widget.existingAddress != null) {
      selectedLabel = widget.existingAddress!.label;
      line1Controller.text = widget.existingAddress!.line1;
      line2Controller.text = widget.existingAddress!.line2;
      cityController.text = widget.existingAddress!.city;
      stateController.text = widget.existingAddress!.state;
      pincodeController.text = widget.existingAddress!.pincode;

      if (widget.existingAddress!.location != null) {
        selectedLocation = LatLng(
          widget.existingAddress!.location!.lat,
          widget.existingAddress!.location!.lng,
        );
      }
    }
  }

  @override
  void dispose() {
    _addAddressBloc.close();
    line1Controller.dispose();
    line2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    _line1Focus.dispose();
    _line2Focus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _pincodeFocus.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  // ================= MAP UPDATE ON TAP =================

  void _onMapTap(LatLng location) async {
    setState(() {
      selectedLocation = location;
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(location));

    _addAddressBloc.add(
      UpdateLocation(lat: location.latitude, lng: location.longitude),
    );

    // ✅ Reverse Geocoding
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // ✅ Auto fill fields
        line1Controller.text =
            "${place.subThoroughfare ?? ''} ${place.thoroughfare ?? ''}";
        line2Controller.text = place.street ?? '';
        cityController.text = place.locality ?? '';
        stateController.text = place.administrativeArea ?? '';
        pincodeController.text = place.postalCode ?? '';

        // ✅ Update BLoC also
        _addAddressBloc.add(
          UpdateAddressField(field: 'line1', value: line1Controller.text),
        );
        _addAddressBloc.add(
          UpdateAddressField(field: 'line2', value: line2Controller.text),
        );
        _addAddressBloc.add(
          UpdateAddressField(field: 'city', value: cityController.text),
        );
        _addAddressBloc.add(
          UpdateAddressField(field: 'state', value: stateController.text),
        );
        _addAddressBloc.add(
          UpdateAddressField(field: 'pincode', value: pincodeController.text),
        );
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  // ================= DEBOUNCED AUTO LOCATION =================
  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      final fullAddress =
          '${line1Controller.text}, ${line2Controller.text}, ${cityController.text}, ${stateController.text}, ${pincodeController.text}';
      _addAddressBloc.add(FetchLocationFromAddress(fullAddress: fullAddress));
    });
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      actions:
          [
            _line1Focus,
            _line2Focus,
            _cityFocus,
            _stateFocus,
            _pincodeFocus,
          ].map((focusNode) {
            return KeyboardActionsItem(
              focusNode: focusNode,
              toolbarButtons: [
                (node) {
                  return GestureDetector(
                    onTap: () => node.unfocus(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ SAME AddressBloc instance (from parent)
        BlocProvider.value(value: context.read<AddressBloc>()),

        // ✅ AddAddressBloc
        BlocProvider<AddAddressBloc>(create: (context) => _addAddressBloc),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(context),
          ),
          title: Text(
            widget.existingAddress != null ? 'Edit Address' : 'Add Address',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AddAddressBloc, AddAddressState>(
              listener: (context, state) {
                if (state is AddAddressSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));

                  // Refresh address list
                  context.read<AddressBloc>().add(FetchAddresses());

                  context.pop(state.address);
                } else if (state is AddAddressError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is AddressLocationFetched) {
                  final newLocation = LatLng(state.lat, state.lng);
                  setState(() {
                    selectedLocation = newLocation;
                  });
                  mapController?.animateCamera(
                    CameraUpdate.newLatLng(newLocation),
                  );
                }
              },
            ),
          ],
          child: KeyboardActions(
            config: _buildConfig(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ================= MAP =================
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: selectedLocation,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      onTap: _onMapTap,
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: selectedLocation,
                        ),
                      },
                    ),
                  ),

                  // ================= FORM =================
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          child: Container(
                            height: 4,
                            width: 47,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter complete address',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Save Address as',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: addressLabels.map((label) {
                              final isSelected = selectedLabel == label;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => selectedLabel = label);
                                    _addAddressBloc.add(
                                      UpdateLabel(label: label),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: line1Controller,
                          focusNode: _line1Focus,
                          label: 'Flat, House no, Floor, Tower',
                          placeholder: 'Ex. 13-12/A, Mothnagr',
                          onChanged: (v) {
                            _addAddressBloc.add(
                              UpdateAddressField(field: 'line1', value: v),
                            );
                            _onAddressChanged();
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: line2Controller,
                          focusNode: _line2Focus,
                          label: 'Street, Society...',
                          placeholder: 'Ex. Snehapuri colony',
                          onChanged: (v) {
                            _addAddressBloc.add(
                              UpdateAddressField(field: 'line2', value: v),
                            );
                            _onAddressChanged();
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: cityController,
                          focusNode: _cityFocus,
                          label: 'City',
                          placeholder: 'Enter city',
                          onChanged: (v) {
                            _addAddressBloc.add(
                              UpdateAddressField(field: 'city', value: v),
                            );
                            _onAddressChanged();
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: stateController,
                          focusNode: _stateFocus,
                          label: 'State',
                          placeholder: 'Enter state',
                          onChanged: (v) {
                            _addAddressBloc.add(
                              UpdateAddressField(field: 'state', value: v),
                            );
                            _onAddressChanged();
                          },
                        ),
                        const SizedBox(height: 16),

                        /// ✅ AUTO LOCATION TRIGGER
                        _buildTextField(
                          controller: pincodeController,
                          focusNode: _pincodeFocus,
                          label: 'Pincode',
                          placeholder: 'Enter pincode',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _addAddressBloc.add(
                              UpdateAddressField(
                                field: 'pincode',
                                value: value,
                              ),
                            );
                            if (value.length == 6) _onAddressChanged();
                          },
                        ),

                        const SizedBox(height: 20),

                        /// DEFAULT CHECKBOX (UNCHANGED)
                        BlocBuilder<AddAddressBloc, AddAddressState>(
                          builder: (_, state) {
                            bool isDefault = false;
                            if (state is AddAddressFormUpdated) {
                              isDefault = state.isDefault;
                            }

                            return Row(
                              children: [
                                Checkbox(
                                  value: isDefault,
                                  onChanged: (v) => _addAddressBloc.add(
                                    SetDefaultAddress(isDefault: v ?? false),
                                  ),
                                ),
                                const Text('Set as default address'),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        /// SAVE BUTTON (UNCHANGED)
                        BlocBuilder<AddAddressBloc, AddAddressState>(
                          builder: (_, state) {
                            final isSaving = state is AddAddressSaving;
                            return PrimaryButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      final address = Address(
                                        id: widget.existingAddress?.id ?? '',
                                        label: selectedLabel,
                                        line1: line1Controller.text,
                                        line2: line2Controller.text,
                                        city: cityController.text,
                                        state: stateController.text,
                                        pincode: pincodeController.text,
                                        location: Location(
                                          lat: selectedLocation.latitude,
                                          lng: selectedLocation.longitude,
                                        ),
                                      );

                                      _addAddressBloc.add(
                                        SaveAddress(addressData: address),
                                      );
                                    },
                              label: 'Save Address',
                              isLoading: isSaving,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================= TEXT FIELD WIDGET =============================
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLength: 50,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}
