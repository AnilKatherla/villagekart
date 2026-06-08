import 'package:cached_network_image/cached_network_image.dart';
import 'package:villag_kart/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/custom_appbar/custom_app_bar.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_bloc.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_events.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_event.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_event.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_event.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_event.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart';
import 'package:villag_kart/features/location/screens/location_picker_screen.dart';

class ServiceAvailabilityCheckScreen extends StatefulWidget {
  final LatLng? initialLatLng;
  final String? address;
  final String? pincode;
  final String? label;

  const ServiceAvailabilityCheckScreen({
    super.key,
    this.initialLatLng,
    this.address,
    this.pincode,
    this.label,
  });

  @override
  State<ServiceAvailabilityCheckScreen> createState() =>
      _ServiceAvailabilityCheckScreenState();
}

class _ServiceAvailabilityCheckScreenState
    extends State<ServiceAvailabilityCheckScreen> {
  bool _isLoadingLocation = false;
  bool _locationResolved = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationFlow();
      _updateDeviceToken();
    });
  }

  // =====================================================
  // INITIALIZE LOCATION FLOW
  // =====================================================
  Future<void> _initializeLocationFlow() async {
    if (_locationResolved) {
      return;
    }

    if (widget.initialLatLng != null) {
      if (mounted) {
        setState(() {
          _locationResolved = true;
          _isLoadingLocation = true;
        });
      }

      context.read<LocationBloc>().add(
        CheckServiceabilityEvent(
          latitude: widget.initialLatLng!.latitude,
          longitude: widget.initialLatLng!.longitude,
          pincode: widget.pincode ?? '',
          userId: await SharedPrefs.getUserId() ?? '',
        ),
      );
    } else {
      await _checkPermissionAndProceed();
    }
  }

  // =====================================================
  // CHECK PERMISSION AND PROCEED
  // =====================================================
  Future<void> _checkPermissionAndProceed() async {
    if (_locationResolved || _isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      // Check if this is the first time requesting permission
      final hasRequestedBefore =
          await SharedPrefs.hasLocationPermissionBeenRequested();

      // Check permission using permission_handler (primary check)
      var permission = await Permission.location.status;
      var geolocatorPermission = await Geolocator.checkPermission();

      debugPrint('📍 Permission status: $permission');
      debugPrint('📍 Geolocator permission: $geolocatorPermission');
      debugPrint('📍 Has requested before: $hasRequestedBefore');

      // Check if permission is granted (handles both "always" and "while in use" on iOS)
      var isPermissionGranted =
          permission.isGranted ||
          permission.isLimited ||
          geolocatorPermission == LocationPermission.whileInUse ||
          geolocatorPermission == LocationPermission.always;

      if (isPermissionGranted) {
        // Permission granted - proceed directly to location check
        debugPrint('✅ Permission is granted - proceeding with location check');
        await _checkLocationServicesAndFetch();
      } else if (permission.isPermanentlyDenied ||
          geolocatorPermission == LocationPermission.deniedForever) {
        // Permission permanently denied - show error view
        debugPrint('❌ Permission permanently denied');
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _isLoadingLocation = false;
          });
        }
      } else if (hasRequestedBefore && permission.isDenied) {
        // Permission was requested before and is denied - show error view
        // Don't request again as iOS won't show popup if already denied
        debugPrint(
          '❌ Permission denied (previously requested) - showing error view',
        );
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _isLoadingLocation = false;
          });
        }
      } else {
        // First time requesting OR permission not determined
        // On first install, we should always try to request permission
        // Even if status shows "denied" (can happen on iOS simulator), we try once
        debugPrint(
          '🔔 Requesting location permission (first time) - will show native popup',
        );
        debugPrint(
          '   Current status: $permission, Geolocator: $geolocatorPermission',
        );

        // Mark that we've requested permission (before the request)
        await SharedPrefs.markLocationPermissionRequested();

        // Request permission - use Geolocator for better iOS handling
        // Geolocator.requestPermission() handles iOS better than permission_handler
        if (geolocatorPermission == LocationPermission.denied) {
          // If already denied (but not forever), try requesting anyway (might work on first install)
          // On iOS simulator, permission might show as "denied" even on first install
          debugPrint(
            '   Geolocator permission is denied, attempting request (first install)...',
          );
          geolocatorPermission = await Geolocator.requestPermission();
        } else if (geolocatorPermission == LocationPermission.deniedForever) {
          // Already permanently denied - shouldn't happen on first install, but handle it
          debugPrint(
            '   Geolocator permission is permanently denied - cannot request',
          );
          // Don't request, will show error view below
        } else {
          // Not determined - request permission (normal first install case)
          debugPrint('   Geolocator permission not determined - requesting...');
          geolocatorPermission = await Geolocator.requestPermission();
        }

        // Also request with permission_handler for consistency
        // permission = await Permission.location.request();
        permission = await Permission.location.status;

        // Re-check after request
        geolocatorPermission = await Geolocator.checkPermission();
        final updatedPermission = await Permission.location.status;
        isPermissionGranted =
            updatedPermission.isGranted ||
            updatedPermission.isLimited ||
            geolocatorPermission == LocationPermission.whileInUse ||
            geolocatorPermission == LocationPermission.always;

        debugPrint(
          '📍 After request - Permission: $updatedPermission, Geolocator: $geolocatorPermission',
        );

        if (isPermissionGranted) {
          // User granted permission - proceed with location check
          debugPrint(
            '✅ Permission granted after request - proceeding with location check',
          );
          await _checkLocationServicesAndFetch();
        } else if (updatedPermission.isPermanentlyDenied ||
            geolocatorPermission == LocationPermission.deniedForever) {
          // Permission became permanently denied - show error view
          // This means iOS won't show popup again, user needs to go to settings
          debugPrint(
            '❌ Permission permanently denied after request - showing error view',
          );
          if (mounted) {
            setState(() {
              _permissionDenied = true;
              _isLoadingLocation = false;
            });
          }
        } else {
          // User denied permission (but not permanently) - show custom error view
          debugPrint('❌ Permission denied after request - showing error view');
          if (mounted) {
            setState(() {
              _permissionDenied = true;
              _isLoadingLocation = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Permission check error: $e');
      // On error, try to proceed anyway - might be a false negative
      // Check if we can actually get location
      try {
        final canGetLocation = await Geolocator.isLocationServiceEnabled();
        if (canGetLocation) {
          // Try to proceed - if location fetch fails, error will be handled there
          await _checkLocationServicesAndFetch();
        } else {
          if (mounted) {
            setState(() {
              _permissionDenied = true;
              _isLoadingLocation = false;
            });
          }
        }
      } catch (e2) {
        debugPrint('❌ Error checking location service: $e2');
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _isLoadingLocation = false;
          });
        }
      }
    }
  }

  // =====================================================
  // CHECK LOCATION SERVICES AND FETCH POSITION
  // =====================================================
  Future<void> _checkLocationServicesAndFetch() async {
    try {
      final isLocationOn = await Geolocator.isLocationServiceEnabled();

      if (!isLocationOn) {
        // Location services disabled - show dialog to enable
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        _showLocationOffDialog();
        return;
      }

      // Location services enabled - fetch current position
      await _fetchCurrentPositionAndCheckServiceability();
    } catch (e) {
      debugPrint('Location services check error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // =====================================================
  // FETCH CURRENT POSITION AND CHECK SERVICEABILITY
  // =====================================================
  Future<void> _fetchCurrentPositionAndCheckServiceability() async {
    if (_locationResolved) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      final place = placemarks.first;
      final pincode = place.postalCode ?? '';

      if (pincode.isEmpty) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      if (mounted) {
        setState(() {
          _locationResolved = true;
          _permissionDenied = false;
        });
      }

      // Check serviceability - this will emit ServiceableLocationState or NonServiceableLocationState
      context.read<LocationBloc>().add(
        CheckServiceabilityEvent(
          latitude: position.latitude,
          longitude: position.longitude,
          pincode: pincode,
          userId: await SharedPrefs.getUserId() ?? '',
        ),
      );
    } catch (e) {
      debugPrint('Get current position error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // =====================================================
  // LEGACY METHOD (for compatibility)
  // =====================================================
  Future<void> _checkAndFetchLocation() async {
    await _checkPermissionAndProceed();
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<LocationBloc, LocationState>(
        listenWhen: (_, state) =>
            state is CheckingServiceabilityState ||
            state is ServiceableLocationState ||
            state is LocationConfirmedState ||
            state is NonServiceableLocationState,
        listener: (context, state) {
          // Keep loading while checking serviceability
          if (state is CheckingServiceabilityState) {
            if (mounted) {
              setState(() => _isLoadingLocation = true);
            }
          }

          // Handle serviceable location - confirm and navigate to home
          if (state is ServiceableLocationState) {
            // Stop loading - serviceability check completed
            if (mounted) {
              setState(() => _isLoadingLocation = false);
            }
            // Confirm the location and save it
            context.read<LocationBloc>().add(
              ConfirmLocationEvent(
                latitude: state.latLng.latitude,
                longitude: state.latLng.longitude,
                address: widget.address ?? state.address,
                pincode: state.pincode,
              ),
            );
          }

          // Location confirmed - navigate to home screen
          if (state is LocationConfirmedState) {
            final pincode = state.userLocation.pincode;
            final lat = state.userLocation.latitude;
            final lng = state.userLocation.longitude;
            final warehouse = state.locationResponse.data.warehouse;
            final address = state.userLocation.address;

            SharedPrefs.getUserId().then((userId) {
              if (!mounted) return;

              final uid = userId ?? '';

              context.read<HomeBloc>().add(const HomeInitialized());
              context.read<OffersBloc>().add(
                FetchOffers(
                  pincode: state.userLocation.pincode ?? '',
                  limit: 10,
                ),
              );
              context.read<PopularProductsBloc>().add(
                FetchPopularProducts(
                  pincode: state.userLocation.pincode ?? '',
                  limit: 10,
                ),
              );
              context.read<CategoryBloc>().add(
                FetchCategories(
                  pincode: state.userLocation.pincode ?? '',
                  latitude: lat,
                  longitude: lng,
                  userId: uid,
                ),
              );
              context.read<BrandsBloc>().add(
                FetchBrands(
                  pincode: state.userLocation.pincode ?? '',
                  latitude: lat,
                  longitude: lng,
                  userId: uid,
                ),
              );

              if (warehouse != null) {
                context.read<HomeBloc>().add(
                  UpdateHomeLocation(
                    address: widget.address ?? address,
                    pincode: pincode ?? '',
                    latitude: lat,
                    longitude: lng,
                    label: widget.label ?? 'Current Location',
                    warehouse: warehouse,
                  ),
                );
              }

              context.goNamed('home');
            });
          }

          // Non-serviceable location - stop loading so builder can show stores list
          if (state is NonServiceableLocationState) {
            if (mounted) {
              setState(() => _isLoadingLocation = false);
            }
            // Builder will handle showing the stores list - no popup, just show the screen
          }
        },
        builder: (context, state) {
          // 1. Show loading while fetching location or checking serviceability
          if (_isLoadingLocation) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Show permission error view if permission was denied
          if (_permissionDenied) {
            return _buildPermissionErrorView();
          }

          // 3. Show stores list if location is not serviceable
          if (state is NonServiceableLocationState) {
            final stores = state.availableWarehouses
                .where((e) => e.servicePincodes.isNotEmpty)
                .toList();

            return _buildServiceNotAvailable(
              stores: stores,
              address: state.address,
              pincode: state.pincode,
              latitude: state.latLng.latitude,
              longitude: state.latLng.longitude,
            );
          }

          // 4. Show permission error for location errors
          if (state is LocationErrorState ||
              state is LocationPermissionDeniedState) {
            return _buildPermissionErrorView();
          }

          // 5. Default loading state (shouldn't reach here normally)
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // =====================================================
  // SERVICE NOT AVAILABLE UI
  // =====================================================
  Widget _buildServiceNotAvailable({
    required List<Warehouse> stores,
    required String address,
    required String pincode,
    required double latitude,
    required double longitude,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Current Location',
        location: address,
        pincode: pincode,
        onLocationTap: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SvgPicture.asset('assets/images/feelsad.svg', height: 140),
            const SizedBox(height: 16),
            const Text(
              'Sorry!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We regret to inform you that service is not\navailable for this location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF747474)),
            ),
            const SizedBox(height: 32),

            InkWell(
              onTap: () => _handleOtherLocation(
                address: address,
                pincode: pincode,
                latitude: latitude,
                longitude: longitude,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: AppColors.green),
                  SizedBox(width: 6),
                  Text(
                    'Try Different Location',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            if (stores.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Our Available Store Locations',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: stores.length,
                itemBuilder: (_, i) => _buildWarehouseCard(stores[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STORE CARD
  // =====================================================
  Widget _buildWarehouseCard(Warehouse store) {
    final imageUrl = store.imageUrl ?? '';
    return SizedBox(
      width: 158,
      height: 162,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          debugPrint('🏬 Selected Store: ${store.name}');
          debugPrint('🏬 Selected Store: ${store.servicePincodes}');

          final area = store.location.colony ?? store.location.label ?? '';
          final city = store.location.city ?? '';
          final pin =
              store.location.pincode ?? store.servicePincodes.firstOrNull ?? '';

          List<String> addressParts = [];
          if (area.isNotEmpty) addressParts.add(area);
          if (city.isNotEmpty) addressParts.add(city);
          if (pin.isNotEmpty) addressParts.add(pin);

          final String customAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : store.address;

          await SharedPrefs.saveUserLocation(
            address: customAddress,
            pincode: store.servicePincodes.first,
            latitude: store.location.latitude,
            longitude: store.location.longitude,
          );
          await SharedPrefs.saveWarehouse(store);

          context.read<HomeBloc>().add(const HomeInitialized());
          context.read<OffersBloc>().add(
            FetchOffers(pincode: store.servicePincodes.first, limit: 10),
          );
          context.read<PopularProductsBloc>().add(
            FetchPopularProducts(
              pincode: store.servicePincodes.first,
              limit: 10,
            ),
          );
          context.read<CategoryBloc>().add(
            FetchCategories(
              pincode: store.servicePincodes.first,
              latitude: store.location.latitude,
              longitude: store.location.longitude,
              userId: await SharedPrefs.getUserId() ?? '',
            ),
          );
          context.read<BrandsBloc>().add(
            FetchBrands(
              pincode: store.servicePincodes.first,
              latitude: store.location.latitude,
              longitude: store.location.longitude,
              userId: await SharedPrefs.getUserId() ?? '',
            ),
          );
          context.read<HomeBloc>().add(
            UpdateHomeLocation(
              address: customAddress,
              pincode: store.servicePincodes.first,
              latitude: store.location.latitude,
              longitude: store.location.longitude,
              label: store.name,
              warehouse: store,
            ),
          );
          context.goNamed('home');
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(Icons.store, size: 40, color: Colors.black),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageUrl.isEmpty
                    ? Image.asset(
                        'assets/images/W-1.png',
                        width: double.infinity,
                        height: 102,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: store.imageUrl ?? '',
                        width: double.infinity,
                        height: 102,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: double.infinity,
                          height: 102,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/W-1.png',
                          width: double.infinity,
                          height: 102,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 4),

              SizedBox(
                width: 154,
                height: 68,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Store Name
                      Text(
                        store.name.toUpperCase(),
                        textAlign: TextAlign.center,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Address + Pincode
                      Text(
                        [
                          if (store.location.colony?.isNotEmpty ?? false)
                            store.location.colony,
                          if (store.location.city?.isNotEmpty ?? false)
                            store.location.city,
                          if (store.servicePincodes.isNotEmpty)
                            store.servicePincodes.first,
                        ].join(', '),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // PERMISSION ERROR VIEW
  // =====================================================
  Widget _buildPermissionErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/feelsad.svg', height: 140),
            const SizedBox(height: 24),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Please enable location permission to check service availability in your area.',
              style: TextStyle(fontSize: 14, color: Color(0xFF747474)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                // Retry after user returns from settings
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _locationResolved = false;
                      _permissionDenied = false;
                      _isLoadingLocation = false;
                    });
                    _checkPermissionAndProceed();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _locationResolved = false;
                  _permissionDenied = false;
                  _isLoadingLocation = false;
                });
                _checkPermissionAndProceed();
              },
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DIALOGS
  // =====================================================
  void _showLocationOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 265,
          width: 328,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SegoeUI',
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please enable your location',
                  style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        context.pop(); // close dialog first
                        context.pushNamed(
                          'denyLocation',
                          extra: _checkPermissionAndProceed,
                        );
                      },

                      child: Container(
                        height: 35,
                        width: 86,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Center(
                          child: Text(
                            'Deny',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF000000),
                              fontFamily: 'SegoeUI',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // 1️⃣ Open the location settings
                        await Geolocator.openLocationSettings();

                        // 2️⃣ Listen for app resume
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          WidgetsBinding.instance.addObserver(
                            _LifecycleObserver(
                              onResume: () {
                                _checkPermissionAndProceed();
                              },
                            ),
                          );
                        });

                        context.pop(context); // Close the dialog
                      },
                      child: Container(
                        height: 35,
                        width: 86,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C9E19),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const Center(
                          child: Text(
                            'Allow',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'SegoeUI',
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Removed _showPermissionDeniedDialog - using _buildPermissionErrorView instead
  // This prevents showing popup dialogs when permission is already handled

  Future<void> _handleOtherLocation({
    required String address,
    required String pincode,
    required double latitude,
    required double longitude,
  }) async {
    final result = await context.pushNamed(
      'location',
      extra: {
        'initialAddress': address,
        'initialPincode': pincode,
        'initialLatLng': LatLng(latitude, longitude),
      },
    );

    // // ✅ If picker returned non-serviceable result, trigger bloc again
    // if (result != null && result['nonServiceable'] == true && mounted) {
    //   context.read<LocationBloc>().add(
    //     CheckServiceabilityEvent(
    //       latitude: result['latitude'],
    //       longitude: result['longitude'],
    //       pincode: result['pincode'],
    //       userId: await SharedPrefs.getUserId() ?? '',
    //     ),
    //   );
    // }
  }

  void _updateDeviceToken() async {
    final token = await NotificationService().getToken();
    if (token != null) {
      debugPrint('Device Token: $token');
      ServiceLocator.networkService.post(
        'updateToken',
        data: {'deviceToken': token},
      );
    }
  }
}

// =====================================================
// Deny Location Screen
// =====================================================
class DenyLocationScreen extends StatefulWidget {
  const DenyLocationScreen({super.key, required this.onAllow});
  final VoidCallback onAllow;

  @override
  State<DenyLocationScreen> createState() => _DenyLocationScreenState();
}

class _DenyLocationScreenState extends State<DenyLocationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🔁 Detect when user comes back from settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final isLocationOn = await Geolocator.isLocationServiceEnabled();
      final permission = await Permission.location.status;

      if (isLocationOn && permission.isGranted) {
        if (mounted) {
          context.pop(context); // ✅ CLOSE DenyLocationScreen
          widget.onAllow(); // ✅ START service check
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.accent,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, left: 10, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                'assets/images/villagekart_logo.svg',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/images/feelsad.svg', height: 140),
              const SizedBox(height: 24),
              const Text(
                'Sorry!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF5A06),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please enable your location to see accurate\n products',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF747474),

                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              /// ✅ UI SAME — only logic fixed
              InkWell(
                onTap: () async {
                  await Geolocator.openLocationSettings();
                },
                child: const Text(
                  'Enable Location >',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  _LifecycleObserver({required this.onResume});
  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
