/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/location/widgets/center_pin.dart';
import 'package:villag_kart/features/location/widgets/location_bottom_sheet.dart';
import 'package:villag_kart/features/location/widgets/location_search_bar.dart';

class LocationPickerScreen extends StatefulWidget {
  final String? initialAddress;
  final String? initialPincode;
  final LatLng? initialLatLng;

  const LocationPickerScreen({
    super.key,
    this.initialAddress,
    this.initialPincode,
    this.initialLatLng,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String _address = 'Fetching address...';
  String _pincode = '';
  bool _isServiceable = false;
  bool _isChecking = false;
  LatLng? _lastUpdatedLatLng;
  bool _isTapping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLatLng != null) {
        // Pre-fill with the shared non-serviceable location
        setState(() {
          _currentLatLng = widget.initialLatLng;
          _address = widget.initialAddress ?? 'Unknown location';
          _pincode = widget.initialPincode ?? '';
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: widget.initialLatLng!, zoom: 16),
          ),
        );
      } else {
        // No location passed — request fresh location as before
        context.read<LocationBloc>().add(RequestLocationPermissionEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        // Location fetched
        if (state is LocationFetchedState) {
          setState(() {
            _currentLatLng = state.latLng;
            _address = state.address;
            _pincode = state.pincode;
            _isChecking = false;
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(state.latLng, 17),
          );
        }

        // Location updated (camera moved)
        if (state is LocationUpdatedState) {
          setState(() {
            _currentLatLng = state.latLng;
            _address = state.address;
            _pincode = state.pincode;
          });
        }

        // Place selected from search
        if (state is PlaceSelectedState) {
          setState(() {
            _currentLatLng = state.latLng;
            _address = state.address;
            _pincode = state.pincode;
          });

          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: state.latLng, zoom: 16),
            ),
          );
          context.read<LocationBloc>().add(ClearSearchEvent()); 
          FocusScope.of(context).unfocus();
        }

        // Checking serviceability
        if (state is CheckingServiceabilityState) {
          setState(() {
            _isChecking = true;
            _isServiceable = false;
          });
        }


        // Location is serviceable
        if (state is ServiceableLocationState) {
          setState(() {
            _currentLatLng = state.latLng;
            _address = state.address;
            _pincode = state.pincode;
            _isServiceable = true;
            _isChecking = false;
          });

          context.pushReplacementNamed('home', extra: state.address);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Great! We deliver to your location'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Location is not serviceable
        if (state is NonServiceableLocationState) {
          setState(() {
            _currentLatLng = state.latLng;
            _address = state.address;
            _pincode = state.pincode;
            _isServiceable = false;
            _isChecking = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        //  Location confirmed
        if (state is LocationConfirmedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location confirmed!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home or address list
          // context.pushReplacementNamed('home', extra: state.userLocation);
        }

        // Error
        if (state is LocationErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }

        // Permission denied
        if (state is LocationPermissionDeniedState) {
          _showPermissionDeniedDialog();
        }
      },
      child: BlocBuilder<LocationBloc, LocationState>(
        buildWhen: (previous, current) =>
            // Rebuild for loading/initial states AND location changes
            // But NOT for SearchResultsState (those trigger parent rebuild)
            current is LocationLoadingState ||
            current is LocationInitialState ||
            current is LocationFetchedState ||
            current is LocationUpdatedState ||
            current is PlaceSelectedState ||
            current is CheckingServiceabilityState ||
            current is ServiceableLocationState ||
            current is NonServiceableLocationState ,
        builder: (context, state) {
          if (state is LocationLoadingState ||
                  state is LocationInitialState ||
                  _currentLatLng == null)
             {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text('Fetching your location...'),
                  ],
                ),
              ),
            );
          }

          // Use context.read to check state without rebuilding
          final currentState = context.read<LocationBloc>().state;
          final showSearchResults = currentState is SearchResultsState;
          final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

          return Scaffold(
            body: Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (LatLng tappedPoint) {
                    final currentState = context.read<LocationBloc>().state;
                    if (currentState is SearchResultsState) {
                      context.read<LocationBloc>().add(ClearSearchEvent());
                      FocusScope.of(context).unfocus();
                    } else {
                      _isTapping = true;
                      _lastUpdatedLatLng = null;

                      setState(() {
                        _currentLatLng = tappedPoint;
                        _address =
                            'Fetching address...'; // ✅ immediately shows loading
                        _isServiceable = false;
                        _isChecking =
                            true; // ✅ show loading indicator in bottom sheet
                      });

                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(tappedPoint, 17),
                      );

                      context.read<LocationBloc>().add(
                        UpdateLocationEvent(latLng: tappedPoint),
                      );

                      debugPrint('📍 Tap fired UpdateLocationEvent: $tappedPoint');

                      Future.delayed(const Duration(milliseconds: 800), () {
                        _isTapping = false;
                      });
                    }
                  },
                  onCameraIdle: () {
                    if (_isTapping) return;

                    final currentState = context.read<LocationBloc>().state;

                    if (_currentLatLng != null &&
                        currentState is! SearchResultsState) {
                      final isSameLocation =
                          _lastUpdatedLatLng != null &&
                          (_lastUpdatedLatLng!.latitude -
                                      _currentLatLng!.latitude)
                                  .abs() <
                              0.00001 &&
                          (_lastUpdatedLatLng!.longitude -
                                      _currentLatLng!.longitude)
                                  .abs() <
                              0.00001;

                      if (!isSameLocation) {
                        _lastUpdatedLatLng = _currentLatLng;

                        setState(() {
                          _address =
                              'Fetching address...'; // ✅ show loading on every drag
                          _isServiceable =
                              false; // ✅ disable confirm until new check
                        });

                        context.read<LocationBloc>().add(
                          UpdateLocationEvent(latLng: _currentLatLng!),
                        );
                      }
                    }
                  },
                ),

                // Center Pin
                if (!showSearchResults) const CenterPin(),

                // Back Button
                Positioned(
                  top: 8,
                  left: 10,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          debugPrint('Cannot go back');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),

                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                // Search Bar - Overlay on top of map
                const Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: SafeArea(child: LocationSearchBar()),
                ),

                // My Location Button
                if (!showSearchResults)
                  Positioned(
                    right: 16,
                    bottom: 200,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        context.read<LocationBloc>().add(
                          GetCurrentLocationEvent(),
                        );
                      },
                      child: const Icon(Icons.my_location, color: Colors.green),
                    ),
                  ),

                // Bottom Sheet
                if (!showSearchResults && !isKeyboardOpen)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: LocationBottomSheet(
                      address: _address,
                      pincode: _pincode,
                      isServiceable: _isServiceable,
                      isChecking: _isChecking,
                      onChangeLocation: () {
                        // Show search or allow map pan
                        context.read<LocationBloc>().add(
                          GetCurrentLocationEvent(),
                        );
                      },
                      onConfirm: () {
                        if (_currentLatLng != null && _isServiceable) {
                          context.read<LocationBloc>().add(
                            ConfirmLocationEvent(
                              latitude: _currentLatLng!.latitude,
                              longitude: _currentLatLng!.longitude,
                              address: _address,
                              pincode: _pincode,
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Please enable location permission in settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
