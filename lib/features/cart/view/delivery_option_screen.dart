import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_event.dart';
import 'package:villag_kart/features/cart/bloc/create_order_pickup.dart/create_order_pickup_state.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_bloc.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_event.dart';
import 'package:villag_kart/features/cart/bloc/create_scheduled_order/create_scheduled_order_state.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_bloc.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_event.dart';
import 'package:villag_kart/features/cart/bloc/delivery_bloc/delivery_state.dart';
import 'package:villag_kart/features/cart/bloc/pickup_delivery_bloc/pickup_slot_bloc.dart';
import 'package:villag_kart/features/cart/bloc/pickup_delivery_bloc/pickup_slot_event.dart';
import 'package:villag_kart/features/cart/bloc/pickup_delivery_bloc/pickup_slot_state.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_bloc.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_event.dart';
import 'package:villag_kart/features/cart/bloc/scheduled_delivery/scheduled_delivery_state.dart';
import 'package:villag_kart/features/cart/model/create_order_pickup_model.dart'
    hide Address, Location;
import 'package:villag_kart/features/cart/model/create_order_schedule_model.dart'
    hide Address, Location;
import 'package:villag_kart/features/cart/model/delivery_type_model.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';
import 'package:villag_kart/features/cart/widgets/bill_details_card.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_bloc.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_event.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_state.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/view/add_address.dart';

class DeliveryOptionsScreen extends StatefulWidget {
  final double promo;
  final double itemsTotal;
  final double taxes;
  final String? instruction;
  final String? couponCode;

  const DeliveryOptionsScreen({
    super.key,
    required this.promo,
    required this.itemsTotal,
    required this.taxes,
    this.instruction,
    this.couponCode,
  });

  @override
  State<DeliveryOptionsScreen> createState() => _DeliveryOptionsScreenState();
}

class _DeliveryOptionsScreenState extends State<DeliveryOptionsScreen> {
  int selectedOption = 1;
  int selectedDay = 0;
  int selectedSlot = -1;

  int selectedPickupSlot = -1;

  Map<String, dynamic>? selectedAddress; // selected address

  late AddressBloc _addressBloc;
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _addressBloc = AddressBloc();
    _addressBloc.add(FetchAddresses());
    context.read<DeliveryBloc>().add(FetchDeliveryTypes());
    _loadLastAddress();
    context.read<LocationBloc>().add(GetCurrentLocationEvent());
  }

  @override
  void dispose() {
    _addressBloc.close();
    super.dispose();
  }

  List<String> generateDates() {
    final now = DateTime.now();
    return List.generate(5, (i) {
      if (i == 0) return 'Today';
      if (i == 1) return 'Tomorrow';
      final date = now.add(Duration(days: i));
      return DateFormat('MMM d').format(date);
    });
  }

  String _getSelectedDate(int index) {
    final date = DateTime.now().add(Duration(days: index));
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // FAST + SCHEDULED
        BlocListener<DeliveryBloc, DeliveryState>(
          listener: (context, state) {
            if (state is OrderCreated) {
              final order = state.orderResponse.data.order;

              context
                  .push(
                    '/paymentOption',
                    extra: {
                      'orderId': order.id,
                      'amount': order.totalAmount.toDouble(),
                    },
                  )
                  .then((_) {
                    // reload delivery types when coming back
                    context.read<DeliveryBloc>().add(FetchDeliveryTypes());
                  });
            }

            if (state is DeliveryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),

        //schedule
        BlocListener<CreateScheduledOrderBloc, CreateScheduledOrderState>(
          listener: (context, state) {
            if (state is CreateScheduledOrderSuccess) {
              final order = state.response.data.order;

              context.push(
                '/paymentOption',
                extra: {
                  'orderId': order.id,
                  'amount': order.totalAmount.toDouble(),
                },
              );
            }

            if (state is CreateScheduledOrderFailure) {
              _show(state.message);
            }
          },
        ),

        // PICKUP LISTENER (THIS WAS MISSING)
        BlocListener<CreateOrderPickupBloc, CreateOrderPickupState>(
          listener: (context, state) async {
            if (state is CreateOrderPickupSuccess) {
              final order = state.response.data.order;

              await context.push(
                '/paymentOption',
                extra: {
                  'orderId': order.id,
                  'amount': order.totalAmount.toDouble(),
                },
              );

              // reload pickup slots after coming back
              final warehouseId = await SharedPrefs.getWarehouseId();
              if (warehouseId != null) {
                context.read<PickupSlotBloc>().add(
                  FetchPickupSlots(
                    warehouseId: warehouseId,
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                );
              }
            } else if (state is CreateOrderPickupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],

      child: BlocBuilder<DeliveryBloc, DeliveryState>(
        builder: (context, state) {
          if (state is OrderCreating || state is DeliveryLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DeliveryError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }

          if (state is DeliveryLoaded) {
            final types = state.data;
            final dates = generateDates();
            final itemsTotal = widget.itemsTotal;
            final promo = widget.promo;

            final deliveryFee = selectedOption == 1
                ? types.fast.charge.toDouble()
                : selectedOption == 2
                ? types.scheduled.charge.toDouble()
                : types.pickup.charge.toDouble();

            return BlocProvider<AddressBloc>.value(
              value: _addressBloc,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0XFFFFFFFF),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Color(0XFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // ---------- PROCEED BUTTON ----------
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PrimaryButton(
                    onPressed: _handleProceed,
                    label: 'Proceed to Pay',
                  ),
                ),

                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Choose Delivery Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: ListView(
                          children: [
                            if (types.fast.available)
                              buildOptionTile(
                                index: 1,
                                title: types.fast.label,
                                subtitle: types.fast.description,
                                price: '₹ ${types.fast.charge}',
                              ),
                            if (types.scheduled.available)
                              buildOptionTile(
                                index: 2,
                                title: types.scheduled.label,
                                subtitle: types.scheduled.description,
                                price: '₹ ${types.scheduled.charge}',
                                child: buildScheduledDelivery(dates),
                              ),
                            if (types.pickup.available)
                              buildOptionTile(
                                index: 3,
                                title: types.pickup.label,
                                subtitle: types.pickup.description,
                                price: types.pickup.charge > 0
                                    ? '₹ ${types.pickup.charge}'
                                    : 'Free',
                                child: buildPickupStoreUI(),
                              ),
                            const SizedBox(height: 20),

                            if (selectedOption != 3)
                              Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Delivery Address',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 11),
                                  Container(
                                    width: double.infinity,

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0x26000000),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Delivery to',
                                                style: TextStyle(
                                                  fontSize: 14,

                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF000000),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  await _showSavedAddressesBottomSheet(
                                                    context,
                                                  );
                                                },
                                                child: const Text(
                                                  'CHANGE',
                                                  style: TextStyle(
                                                    fontSize: 12,

                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedAddress != null
                                                ? selectedAddress!["address"]
                                                : 'No address selected',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF4F4F4F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 100),
                            BillDetailsCard(
                              itemsTotal: itemsTotal,
                              promo: promo,
                              delivery: deliveryFee,
                              taxes: widget.taxes,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Future<void> _showSavedAddressesBottomSheet(
    BuildContext parentContext,
  ) async {
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;

    Map<String, dynamic>? _pendingAddress;
    bool _userTapped = false;

    String? liveAddress;
    String? livePincode;
    double? liveLat;
    double? liveLng;

    void _extractLocation(dynamic locationState) {
      if (locationState is LocationFetchedState) {
        liveAddress = locationState.address;
        livePincode = locationState.pincode;
        liveLat = locationState.latLng.latitude;
        liveLng = locationState.latLng.longitude;
      } else if (locationState is LocationUpdatedState) {
        liveAddress = locationState.address;
        livePincode = locationState.pincode;
        liveLat = locationState.latLng.latitude;
        liveLng = locationState.latLng.longitude;
      } else if (locationState is ServiceableLocationState) {
        liveAddress = locationState.address;
        livePincode = locationState.pincode;
        liveLat = locationState.latLng.latitude;
        liveLng = locationState.latLng.longitude;
      }
    }

    _extractLocation(parentContext.read<LocationBloc>().state);
    if (liveAddress == null) {
      parentContext.read<LocationBloc>().add(GetCurrentLocationEvent());
      try {
        final locationState = await parentContext
            .read<LocationBloc>()
            .stream
            .firstWhere(
              (state) =>
                  state is LocationFetchedState ||
                  state is LocationUpdatedState ||
                  state is ServiceableLocationState,
            )
            .timeout(const Duration(seconds: 5));
        _extractLocation(locationState);
      } catch (e) {
        debugPrint('GPS timeout or error: $e');
      }
    }

    if (!parentContext.mounted) return;

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String? _sheetLiveAddress = liveAddress;
        String? _sheetLivePincode = livePincode;
        double? _sheetLiveLat = liveLat;
        double? _sheetLiveLng = liveLng;
        String? _serviceError;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _addressBloc),
                BlocProvider.value(value: context.read<LocationBloc>()),
              ],
              child: BlocListener<LocationBloc, LocationState>(
                listener: (listenerCtx, state) async {
                  // 📍 Location updates (same as before)
                  if (state is LocationFetchedState) {
                    setSheetState(() {
                      _sheetLiveAddress = state.address;
                      _sheetLivePincode = state.pincode;
                      _sheetLiveLat = state.latLng.latitude;
                      _sheetLiveLng = state.latLng.longitude;
                    });
                    return;
                  }

                  if (state is LocationUpdatedState) {
                    setSheetState(() {
                      _sheetLiveAddress = state.address;
                      _sheetLivePincode = state.pincode;
                      _sheetLiveLat = state.latLng.latitude;
                      _sheetLiveLng = state.latLng.longitude;
                    });
                    return;
                  }

                  if (!_userTapped) return;

                  // ✅ NEW: Address Serviceability Handling
                  if (state is AddressServiceabilityState) {
                    if (state.serviceable) {
                      if (_pendingAddress != null) {
                        setState(() {
                          selectedAddress = _pendingAddress;
                        });

                        final warehouseId = await SharedPrefs.getWarehouseId();

                        await SharedPrefs.saveLastUsedAddress({
                          ..._pendingAddress!.map(
                            (k, v) => MapEntry(k, v.toString()),
                          ),
                          "warehouseId": warehouseId ?? "",
                        });
                        _pendingAddress = null;
                        _userTapped = false;
                      }

                      Navigator.pop(listenerCtx);
                    } else {
                      _userTapped = false;

                      GlobalSnackbar.show(
                        "",
                        state.message,
                        isError: true,
                        position: SnackPosition.top,
                      );
                    }
                  }

                  // ✅ Existing (Map-based)
                  if (state is ServiceableLocationState) {
                    await SharedPrefs.saveUserLocation(
                      address: state.address,
                      pincode: state.pincode,
                      latitude: state.latLng.latitude,
                      longitude: state.latLng.longitude,
                    );

                    Navigator.pop(listenerCtx);
                  }

                  if (state is NonServiceableLocationState) {
                    _userTapped = false;

                    GlobalSnackbar.show(
                      "",
                      state.message,
                      isError: true,
                      position: SnackPosition.top,
                    );
                  }
                },
                child: DraggableScrollableSheet(
                  expand: false,
                  builder: (sheetCtx, scrollController) {
                    return BlocBuilder<AddressBloc, AddressState>(
                      builder: (sheetCtx, addrState) {
                        if (addrState is AddressEmpty) {
                          return _buildEmptyStateWithAddButton();
                        }
                        if (addrState is AddressLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (addrState is AddressError) {
                          return Center(child: Text(addrState.errorMessage));
                        } else if (addrState is AddressLoaded ||
                            addrState is AddressRefreshing ||
                            addrState is AddressDeleted ||
                            addrState is AddressDeleting) {
                          List<Address> addresses = [];
                          if (addrState is AddressLoaded)
                            addresses = addrState.addresses;
                          if (addrState is AddressRefreshing)
                            addresses = addrState.addresses;
                          if (addrState is AddressDeleted)
                            addresses = addrState.addresses;
                          if (addrState is AddressDeleting)
                            addresses = addrState.addresses;

                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          2.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_sheetLiveAddress != null &&
                                      _sheetLiveAddress!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        if (_sheetLiveLat == null ||
                                            _sheetLiveLng == null)
                                          return;

                                        final placemarks =
                                            await placemarkFromCoordinates(
                                              _sheetLiveLat!,
                                              _sheetLiveLng!,
                                            );

                                        String city = '';
                                        String state = '';
                                        String area = '';
                                        String street = '';

                                        if (placemarks.isNotEmpty) {
                                          final place = placemarks.first;
                                          area = place.subLocality ?? '';
                                          street = place.street ?? '';
                                          city = place.locality ?? '';
                                          state =
                                              place.administrativeArea ?? '';
                                        }

                                        final result = await context.pushNamed(
                                          'addAddress',
                                          extra: Address(
                                            id: '',
                                            label: 'Home',
                                            line1: '',
                                            line2: '$street, $area',
                                            city: city,
                                            state: state,
                                            pincode: _sheetLivePincode ?? '',
                                            location: Location(
                                              lat: _sheetLiveLat ?? 0.0,
                                              lng: _sheetLiveLng ?? 0.0,
                                            ),
                                            isDefault: false,
                                          ),
                                        );

                                        if (result != null) {
                                          _addressBloc.add(FetchAddresses());
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7FA),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0XFF00000026),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              child: SvgPicture.asset(
                                                'assets/icons/location-tick 1.svg',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Current location',
                                                    style: TextStyle(
                                                      fontSize: 12,

                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _sheetLiveAddress!,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  const Text(
                                    'Saved Address',
                                    style: TextStyle(
                                      fontSize: 16,

                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  ...addresses.map((addr) {
                                    return GestureDetector(
                                      onTap: () async {
                                        _userTapped = true;
                                        _pendingAddress = {
                                          'id': addr.id,
                                          'label': addr.label,
                                          'address': addr.fullAddress,
                                          'pincode': addr.pincode,
                                        };

                                        final warehouse =
                                            await SharedPrefs.getWarehouse();
                                        final userId =
                                            await SharedPrefs.getUserId() ?? '';

                                        sheetCtx.read<LocationBloc>().add(
                                          CheckServiceabilityAddressEvent(
                                            pincode: addr.pincode,
                                            userId: userId,
                                            warehouseId: warehouse?.id ?? '',
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const ImageIcon(
                                              AssetImage(
                                                'assets/icons/location-tick.png',
                                              ),
                                              size: 28,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    addr.label,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    addr.fullAddress,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      height: 1.4,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await context.pushNamed(
                                        'addAddress',
                                      );

                                      if (result != null) {
                                        _addressBloc.add(FetchAddresses());
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Color(0XFF00891D),
                                    ),
                                    label: const Text(
                                      'Add New Address',
                                      style: TextStyle(
                                        color: Color(0XFF00891D),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0XFFFFFFFF),
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
    _isBottomSheetOpen = false;
  }

  // ---------- Your Existing Widgets ----------
  Widget buildOptionTile({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    Widget? child,
  }) {
    final isSelected = selectedOption == index;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () async {
          setState(() => selectedOption = index);

          // SCHEDULED DELIVERY
          if (index == 2) {
            // always select first date
            selectedDay = 0;

            // 🔑 PRIORITY: get pincode from either selectedAddress OR SharedPrefs
            String? pincode;

            if (selectedAddress != null) {
              pincode = selectedAddress!['pincode'];
            } else {
              final location = await SharedPrefs.getUserLocation();
              pincode = location?['pincode'];
            }

            if (pincode == null || pincode.isEmpty) {
              _show('Please select delivery address');
              return;
            }

            // 🚀 DIRECT API CALL (no postFrameCallback)
            context.read<DeliverySlotBloc>().add(
              FetchDeliverySlots(pincode: pincode, date: _getSelectedDate(0)),
            );
          }

          //  PICKUP
          if (index == 3) {
            final warehouseId = await SharedPrefs.getWarehouseId();
            if (warehouseId == null || warehouseId.isEmpty) {
              _show('Pickup store not available');
              return;
            }

            context.read<PickupSlotBloc>().add(
              FetchPickupSlots(
                warehouseId: warehouseId,
                date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  index == 1
                      ? SvgPicture.asset(
                          'assets/images/timer-pause.svg',

                          /// color: Colors.black87,
                        )
                      : index == 2
                      ? SvgPicture.asset(
                          'assets/images/calendar-tick.svg',
                          // color: Colors.black87,
                        )
                      : SvgPicture.asset(
                          'assets/images/Shop.svg',
                          //color: Colors.black87,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Segue UI',
                                color: Color(0xFF000000),
                              ),
                            ),
                            if (price.isNotEmpty)
                              Text(
                                '  | $price',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Segue UI',
                                  color: Color(0xFF000000),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              if (isSelected && child != null) child,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScheduledDelivery(List<String> dates) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final isSelected = selectedDay == i;
                return GestureDetector(
                  onTap: () async {
                    setState(() => selectedDay = i);

                    // 1️⃣ Get pincode from SharedPrefs
                    final location = await SharedPrefs.getUserLocation();
                    final pincode = location?['pincode'];

                    if (pincode == null || pincode.isEmpty) {
                      _show("Pincode not available");
                      return;
                    }

                    // 2️⃣ Fire Bloc event
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<DeliverySlotBloc>().add(
                        FetchDeliverySlots(
                          pincode: pincode,
                          date: _getSelectedDate(i),
                        ),
                      );
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? Colors.deepOrange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      dates[i],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 0),

          Expanded(
            child: BlocBuilder<DeliverySlotBloc, DeliverySlotState>(
              builder: (context, state) {
                if (state is DeliverySlotLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DeliverySlotError) {
                  return Center(child: Text(state.message));
                }

                if (state is DeliverySlotLoaded) {
                  final apiSlot = state.data.data.slots.where((slot) {
                    if (slot.time == null || slot.time!.isEmpty) return false;
                    if (slot.time!.contains('NaN')) return false;

                    // 🔥 NEW LOGIC
                    if (selectedDay == 0 && isSlotExpired(slot.time!)) {
                      return false;
                    }

                    return true;
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: apiSlot.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 107 / 30,
                        ),
                    itemBuilder: (_, i) {
                      final slot = apiSlot[i];

                      final isSelected = state.selectedSlotId == slot.id;

                      final isDisabled =
                          !slot.isAvailable ||
                          slot.available <= 0 ||
                          slot.booked >= slot.capacity;

                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () {
                                context.read<DeliverySlotBloc>().add(
                                  SelectDeliverySlot(slot.id),
                                );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDisabled
                                ? Colors.grey.shade400
                                : isSelected
                                ? Colors.deepOrange
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 0.4,
                              color: const Color(0XFFC4C4C4),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              slot.time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis, // ✅ NOT slot
                              style: TextStyle(
                                color: isDisabled
                                    ? Colors.grey
                                    : isSelected
                                    ? Colors.white
                                    : const Color(0xFF3E3E3E),
                                fontWeight: FontWeight.w400,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPickupStoreUI() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: BlocBuilder<PickupSlotBloc, PickupSlotState>(
        builder: (context, state) {
          if (state is PickupSlotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PickupSlotError) {
            return Center(child: Text(state.message));
          }

          if (state is PickupSlotLoaded) {
            final slots = state.data.slots.where((slot) {
              if (slot.time.isEmpty) return false;

              // Hide past slots only for TODAY
              if (isSlotExpired(slot.time)) return false;

              return slot.available;
            }).toList();

            final storeName = state.data.store.name.isNotEmpty
                ? state.data.store.name
                : "Store Location";

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/pickup_store.svg'),
                          Text(
                            ' ${storeName}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${state.data.store.location.city},${state.data.store.location.line1},${state.data.store.location.line2},${state.data.store.location.state},${state.data.store.location.colony},${state.data.store.location.mandal},${state.data.store.location.pincode}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5555555),
                        ),
                      ),
                      const Divider(thickness: 0.5),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  itemCount: slots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 107 / 22,
                  ),
                  itemBuilder: (_, i) {
                    final slot = slots[i];
                    final isSelected = selectedPickupSlot == i;

                    final isTimeExpired = isSlotExpired(slot.time);

                    // final decision
                    final isDisabled = !slot.available || isTimeExpired;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => setState(() => selectedPickupSlot = i),

                      child: Container(
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey.shade300
                              : isSelected
                              ? Colors.deepOrange
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 0.4,
                            color: const Color(0XFFC4C4C4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot.time,
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey
                                  : isSelected
                                  ? Colors.white
                                  : const Color(0xFF3E3E3E),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _handlePickupProceed() {
    final pickupState = context.read<PickupSlotBloc>().state;

    if (pickupState is! PickupSlotLoaded) {
      _show('Pickup slots not loaded');
      return;
    }

    if (selectedPickupSlot == -1) {
      _show('Please select pickup slot');
      return;
    }

    final slot = pickupState.data.slots[selectedPickupSlot];

    final warehouseId = pickupState.data.store.id;

    final request = CreateOrderRequest(
      deliveryType: 'PICKUP_STORE',
      warehouseId: warehouseId,
      pickupTimeSlot: slot.time,
      orderStatus: 'PLACED',
      couponCode: widget.couponCode,
      discount: widget.promo,
    );

    context.read<CreateOrderPickupBloc>().add(CreateOrderPickupOrder(request));

    // Widget build(BuildContext context) {
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildEmptyStateWithAddButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Addresses Found',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t added any addresses yet.\nAdd your first address to get started.',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await context.pushNamed('addAddress');

                  if (result is Address) {
                    _addressBloc.add(FetchAddresses());
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add New Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLastAddress() async {
    final address = await SharedPrefs.getLastUsedAddress();
    final currentWarehouseId = await SharedPrefs.getWarehouseId();

    if (address != null && address["warehouseId"] == currentWarehouseId) {
      setState(() {
        selectedAddress = address;
      });
    } else {
      setState(() {
        selectedAddress = null;
      });
    }
  }

  Future<void> _handleProceed() async {
    if (selectedOption == 3) {
      _handlePickupProceed();
      return;
    }

    if (selectedAddress == null) {
      _show('Please select address');
      return;
    }

    final warehouseId = await SharedPrefs.getWarehouseId();

    /// FAST DELIVERY
    if (selectedOption == 1) {
      context.read<DeliveryBloc>().add(
        CreateOrderEvent(
          addressId: selectedAddress!['id']!,
          deliveryType: 'FAST',
          warehouseId: warehouseId,
          orderStatus: 'PLACED',
          specialInstructions: widget.instruction,
          couponCode: widget.couponCode,
          discount: widget.promo,
        ),
      );
      return;
    }

    /// SCHEDULED DELIVERY
    if (selectedOption == 2) {
      final slotState = context.read<DeliverySlotBloc>().state;

      if (slotState is! DeliverySlotLoaded ||
          slotState.selectedSlotId == null) {
        _show('Please select delivery slot');
        return;
      }

      final slots = slotState.data.data.slots;

      final matchedSlots = slots
          .where((s) => s.id == slotState.selectedSlotId)
          .toList();

      if (matchedSlots.isEmpty) {
        _show('Selected slot not available');
        return;
      }

      final slot = matchedSlots.first;

      final discount = widget.promo.toInt();

      final request = CreateScheduledOrderRequest(
        addressId: selectedAddress!['id']!,
        deliveryType: 'SCHEDULED',
        deliverySlot: slot.time,
        deliveryDate: _getSelectedDate(selectedDay),
        warehouseId: warehouseId,
        orderStatus: 'PLACED',
        specialInstructions: widget.instruction,
        couponCode: widget.couponCode,
        discount: discount,
      );

      context.read<CreateScheduledOrderBloc>().add(
        SubmitCreateScheduledOrder(request: request),
      );
    }
  }

  bool isSlotExpired(String slotTime) {
    try {
      final now = DateTime.now();

      // Example: "09:00 AM - 10:00 AM"
      final startTimeStr = slotTime.split('-').first.trim();

      final parsedTime = DateFormat('hh:mm a').parse(startTimeStr);

      final slotDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      return slotDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }
}
