import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/environmental_variables.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_bloc.dart';
import 'package:villag_kart/features/home/bloc/banner_bloc/banner_events.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_bloc.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_events.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_event.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_bloc.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_event.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_state.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_event.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_event.dart';
import 'package:villag_kart/features/home/bloc/product_bloc/product_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/sections/banner_section.dart';
import 'package:villag_kart/features/home/sections/category_product_scection.dart';
import 'package:villag_kart/features/home/sections/offer_banner.dart';
import 'package:villag_kart/features/home/sections/quick_actions_card.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart'
    as location_model;
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_bloc.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_event.dart';
import 'package:villag_kart/features/profile/bloc/manage_address/manage_address_state.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';

import 'package:villag_kart/features/search/view/pages/search_product_rail.dart';

import '../../../core/widgets/custom_appbar/custom_app_bar.dart';
import '../../location/bloc/location_service.dart';
import '../bloc/home_bloc/home_bloc.dart';
import '../sections/brands_section.dart';
import '../sections/categories_section.dart';
import '../sections/coupons_section.dart';
import '../sections/footer_tagline.dart';
import '../sections/offers_section.dart';
import '../sections/popular_section.dart';
import '../sections/suggestion_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.address});
  final String? address;

  @override
  Widget build(BuildContext context) {
    return _HomeScreenContent(address: address);
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({this.address});
  final String? address;

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  LatLng? selectedLatLng;
  String? selectedAddress;
  // bool _isHomeLoaded = false;

  @override
  void initState() {
    super.initState();

    context.read<CartBloc>().add(FetchCartItemsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(GetCurrentLocationEvent());
      loadDataOnInit();
    });
    // Handle address passed from service check screen or navigation
    if (widget.address != null && widget.address!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get saved location data if available
        _loadAndUpdateLocationFromServiceCheck();
      });
    }
  }

  void loadDataOnInit() {
    final homeState = context.read<HomeBloc>().state;

    if (homeState.pincode == null || homeState.pincode!.isEmpty) {
      return;
    }

    final pincode = homeState.pincode!;

    context.read<PopularProductsBloc>().add(
      FetchPopularProducts(pincode: pincode, limit: 10),
    );

    context.read<OffersBloc>().add(FetchOffers(pincode: pincode, limit: 10));

    context.read<CategoryBloc>().add(
      FetchCategories(
        pincode: pincode,
        latitude: homeState.latitude ?? 0.0,
        longitude: homeState.longitude ?? 0.0,
        userId: homeState.userId ?? '',
      ),
    );

    context.read<BrandsBloc>().add(
      FetchBrands(
        pincode: pincode,
        latitude: homeState.latitude ?? 0.0,
        longitude: homeState.longitude ?? 0.0,
        userId: homeState.userId ?? '',
      ),
    );

    context.read<BannerBloc>().add(FetchBannersEvent());

    context.read<CouponsBloc>().add(
      FetchCoupons(
        userId: homeState.userId ?? '',
        pincode: pincode,
        cartValue: 1000,
      ),
    );

    context.read<AddressBloc>().add(FetchAddresses());
  }

  Future<void> _loadAndUpdateLocationFromServiceCheck() async {
    // Get the saved location data from SharedPrefs
    final savedLocation = await SharedPrefs.getUserLocation();

    if (savedLocation != null) {
      context.read<HomeBloc>().add(
        UpdateHomeLocation(
          address: widget.address ?? savedLocation['address'] ?? '',
          pincode: savedLocation['pincode'] ?? '',
          latitude: savedLocation['latitude'] ?? 0.0,
          longitude: savedLocation['longitude'] ?? 0.0,
          label: 'Location',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return CustomAppBar(
              title: state.label,
              pincode: state.pincode,
              location: state.address ?? 'Location',
              onLocationTap: () {
                //  Fetch saved addresses FIRST
                context.read<AddressBloc>().add(FetchAddresses());

                context.read<LocationBloc>().add(GetCurrentLocationEvent());

                _showAddressSelectionSheet(
                  context,
                  selectedLatLng,
                  selectedAddress,
                );
                debugPrint('Location tapped!');
              },
            );
          },
        ),
      ),
      body: MultiBlocProvider(
        providers: [BlocProvider(create: (_) => ProductBloc())],
        child: MultiBlocListener(
          listeners: [
            BlocListener<HomeBloc, HomeState>(
              listenWhen: (previous, current) =>
                  (previous.pincode != current.pincode ||
                      previous.latitude != current.latitude ||
                      previous.longitude != current.longitude ||
                      previous.warehouse != current.warehouse) &&
                  current.pincode != null &&
                  current.pincode!.isNotEmpty,
              listener: (context, state) async {
                debugPrint('🔁 Pincode changed → reload everything');
                context.read<CartBloc>().add(FetchCartItemsEvent());

                context.read<ProductBloc>().add(ClearProducts());

                loadDataOnInit();

                final categoryState = context.read<CategoryBloc>().state;

                if (categoryState is CategoryLoaded) {
                  final categoryIds = categoryState.categories
                      .map((e) => e.id)
                      .toList();

                  context.read<ProductBloc>().add(
                    FetchAllCategoryProducts(
                      categoryIds: categoryIds,
                      pincode: state.pincode!,
                    ),
                  );
                }
              },
            ),

            /// CATEGORY LOADED
            BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategoryLoaded) {
                  final pincode = context.read<HomeBloc>().state.pincode;

                  if (pincode == null || pincode.isEmpty) return;

                  final categoryIds = state.categories
                      .map((e) => e.id)
                      .toList();

                  context.read<ProductBloc>().add(
                    FetchAllCategoryProducts(
                      categoryIds: categoryIds,
                      pincode: pincode,
                    ),
                  );

                  /// LISTEN PINCODE CHANGE
                }
              },
            ),
          ],

          child: Stack(
            children: [
              _HomeBody(
                onRefresh: () async {
                  loadDataOnInit();
                  await Future.delayed(const Duration(seconds: 1));
                },
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSelectionSheet(
    rootContext,
    LatLng? selectedLatLng,
    String? selectedAddress,
  ) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.40,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
                  List<Address> savedAddress = [];

                  if (state is AddressLoaded) {
                    savedAddress = state.addresses;
                  } else {
                    savedAddress = context.read<AddressBloc>().userAddresses;
                  }

                  return SingleChildScrollView(
                    controller: scrollController, //  IMPORTANT
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom,
                      left: 8,
                      right: 8,
                      top: 12,
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          height: 4,
                          width: 47,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose from below options',
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          spacing: 16,
                          children: [
                            Expanded(child: _buildCurrentLocationCard(ctx)),
                            Expanded(
                              child: _buildChooseFromMapCard(ctx, rootContext),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: _buildStoreListCard(ctx, rootContext),
                            ),
                            if (savedAddress.isNotEmpty)
                              Expanded(
                                child: _buildAddressListCard(ctx, rootContext),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentLocationCard(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () async {
          final locationState = await _waitForLocation(ctx);
          if (locationState == null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Could not get location. Check permissions.'),
              ),
            );
            return;
          }
          final latLng = locationState.latLng;
          final pincode = locationState.pincode;
          final address = locationState.address;

          if (pincode.isEmpty) return;

          final userId = await SharedPrefs.getUserId() ?? 'guest_user';

          final response = await checkServiceabilityWithDialog(
            context: ctx,
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            pincode: pincode,
            userId: userId,
          );

          if (response == null) return;

          if (response.data.serviceable) {
            final warehouse = response.data.warehouse;

            ctx.read<HomeBloc>().add(
              UpdateHomeLocation(
                address: address,
                pincode: pincode,
                latitude: latLng.latitude,
                longitude: latLng.longitude,
                label: 'Location',
                warehouse: warehouse,
              ),
            );
            context.pop(ctx);
          } else {
            context.pop(ctx);
            _showServiceNotAvailableDialog(context);
          }
        },

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LocationBloc, LocationState>(
            buildWhen: (previous, current) =>
                current is LocationLoadingState ||
                current is LocationFetchedState ||
                current is LocationUpdatedState ||
                current is ServiceableLocationState,
            builder: (context, state) {
              String subtitle = 'Detecting location...';

              if (state is LocationFetchedState ||
                  state is LocationUpdatedState ||
                  state is ServiceableLocationState) {
                subtitle = (state as dynamic).address;
              }
              if (state is LocationErrorState) {
                subtitle = 'Unable to detect location';
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location-tick.svg',
                    height: 30,
                    width: 33.15,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChooseFromMapCard(BuildContext ctx, rootContext) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(rootContext).pop();
          // Handle choose from map selection
          context.push('/location');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/location-map.svg',
                height: 30,
                width: 33.15,
              ),
              const SizedBox(height: 6),
              const Text(
                'Map',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'Pick location on map',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreListCard(BuildContext ctx, rootContext) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () async {
          Navigator.of(rootContext).pop();
          // Navigate to AvailableStoresScreen
          // context.push('/availablestores');
          fetchStoresAndShowBottomSheet(
            context: context,
            latitude: 0.0,
            longitude: 0.0,
            pincode: '000000',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location-store.svg',
                    height: 30,
                    width: 33.15,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Other Store',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Explore other stores',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressListCard(BuildContext ctx, rootContext) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(rootContext).pop();
          // Handle Choose from saved address selection
          _showManagedAddressBottomSheet(
            rootContext,
            selectedLatLng,
            selectedAddress,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location-tick 1.svg',
                    height: 30,
                    width: 33.15,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Previously used addresses',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManagedAddressBottomSheet(
    rootContext,
    LatLng? selectedLatLng,
    String? selectedAddress,
  ) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // if (state is AddressEmpty) {
            //   return const Center(child: Text('No saved addresses'));
            // }

            if (state is AddressLoaded) {
              final saved = state.addresses;

              return DraggableScrollableSheet(
                expand: false,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Note: Changing location will clear your cart items.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Saved Addresses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        /// 🔹 REAL ADDRESSES LIST
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: saved.length + 1,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              if (index < saved.length) {
                                final addr = saved[index];

                                final fullAddress =
                                    '${addr.line1}, ${addr.line2}, '
                                    '${addr.city}, ${addr.state}, ${addr.pincode}';

                                return _AddressCard(
                                  title: addr.label,
                                  subtitle: fullAddress,
                                  leading: Icons.location_on,
                                  onTap: () async {
                                    // 1. Capture the router before popping the bottom sheet
                                    final router = GoRouter.of(rootContext);

                                    // 2. Safely close the bottom sheet
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }

                                    // 3. Validate location data
                                    if (addr.location == null) {
                                      ScaffoldMessenger.of(
                                        rootContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Invalid address location',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // 4. Navigate to serviceability check screen
                                    router.pushNamed(
                                      'serviceability',
                                      extra: {
                                        'initialLatLng': LatLng(
                                          addr.location!.lat,
                                          addr.location!.lng,
                                        ),
                                        'address': addr.fullAddress,
                                        'pincode': addr.pincode,
                                        'label': addr.label,
                                      },
                                    );
                                  },
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Something went wrong'));
          },
        );
      },
    );
  }

  void showAvailableStoresBottomSheet({
    required BuildContext context,
    required List<location_model.Warehouse> stores,
  }) {
    // Filter stores that have pincodes
    final storesWithPincodes = stores
        .where((store) => store.servicePincodes.isNotEmpty ?? false)
        .toList();

    // Don't show bottom sheet if no stores have pincodes
    if (storesWithPincodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stores available in your area')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Drag handle
                    Container(
                      height: 4,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Other Stores',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ///  Scrollable Grid
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              (MediaQuery.of(context).size.width / 2 - 28) /
                              164,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: storesWithPincodes.length,
                        itemBuilder: (context, i) =>
                            _buildWarehouseCard(context, storesWithPincodes[i]),
                      ),
                    ),
                    PrimaryButton(
                      onPressed: () => context.pop(),
                      label: 'Continue',
                    ),

                    const SizedBox(height: 27),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWarehouseCard(
    BuildContext context,
    location_model.Warehouse store,
  ) {
    final pincode = store.servicePincodes.first ?? '';
    final imageUrl = store.imageUrl ?? '';

    return SizedBox(
      width: double.infinity,

      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final area = store.location.colony ?? store.location.label ?? '';
          final city = store.location.city ?? '';
          //final pin = store.location.pincode ?? pincode;

          List<String> addressParts = [];
          if (area.isNotEmpty) addressParts.add(area);
          if (city.isNotEmpty) addressParts.add(city);
          // if (pin.isNotEmpty) addressParts.add(pin);

          final String customAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : store.address;

          await SharedPrefs.saveUserLocation(
            address: customAddress,
            pincode: pincode,
            latitude: store.location.latitude,
            longitude: store.location.longitude,
          );
          await SharedPrefs.saveWarehouse(store);
          context.read<CartBloc>().add(FetchCartItemsEvent());
          context.read<HomeBloc>().add(
            UpdateHomeLocation(
              address: customAddress,
              pincode: pincode,
              latitude: store.location.latitude,
              longitude: store.location.longitude,
              label: store.name,
              warehouse: store,
            ),
          );

          if (context.mounted) {
            context.pop(context);
          }
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
              Expanded(
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
                          pincode,
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

  Future<location_model.LocationResponseModel?> checkServiceabilityWithDialog({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String pincode,
    required String userId,
  }) async {
    // 🔹 Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await LocationService.checkServiceability(
        latitude: latitude,
        longitude: longitude,
        pincode: pincode,
        userId: userId,
      );
      debugPrint('Serviceability response: ${response.data.serviceable}');
      // 🔹 Close loader
      if (!context.mounted) {
        return null;
      }

      Navigator.pop(context);

      // 🔹 Result dialog

      return response;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => context.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return null;
    }
  }

  Future<void> fetchStoresAndShowBottomSheet({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String pincode,
  }) async {
    try {
      final userId = await SharedPrefs.getUserId() ?? 'guest_user';

      final response = await checkServiceabilityWithDialog(
        context: context,
        latitude: latitude,
        longitude: longitude,
        pincode: pincode,
        userId: userId,
      );

      if (response == null) {
        return;
      }

      //  API response structure
      final List<location_model.Warehouse> stores =
          response.data.availableWarehouses ??
          (response.data.warehouse != null ? [response.data.warehouse!] : []);

      // ✅ Bottom Sheet open
      showAvailableStoresBottomSheet(context: context, stores: stores);
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    }
  }

  void _showServiceNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/feelsad.svg', height: 64),
            const SizedBox(height: 24),
            const Text(
              'Sorry!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We regret to inform you that service is not available for this location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF747474)),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => context.pop(context),
            child: Container(
              height: 36,
              width: 86,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<LocationFetchedState?> _waitForLocation(BuildContext ctx) async {
    final bloc = ctx.read<LocationBloc>();

    if (bloc.state is LocationFetchedState) {
      return bloc.state as LocationFetchedState;
    }

    bloc.add(GetCurrentLocationEvent());

    try {
      final state = await bloc.stream
          .firstWhere(
            (state) =>
                state is LocationFetchedState ||
                state
                    is LocationErrorState, // add your actual error state class
          )
          .timeout(const Duration(seconds: 15));

      return state is LocationFetchedState ? state : null;
    } catch (e) {
      debugPrint('Location fetch timeout: $e');
      return null;
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.totalItems == 0) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.totalItems} items',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '₹${state.totalPrice.toStringAsFixed(2)}   ₹${state.totalSaved.toStringAsFixed(2)} Saved',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    context.pushNamed('reviewitem');
                  },
                  child: const Text(
                    'View cart',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,

                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.green,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Error loading categories: ${state.errorMessage}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SuggestionCard(),
                        const SizedBox(height: 16),
                        const FooterTagline(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColors.green,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  const BannerSection(),
                  const CouponsSection(),
                  const SizedBox(height: 24),
                  // if (EnvironmentalVariables.appName == 'Villagkart Dev')
                  //   const QuickActionsCard(),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection(context),

                      const SizedBox(height: 24),
                      const PopularSection(),
                      const SizedBox(height: 16),
                      // if (EnvironmentalVariables.appName == 'Villagkart Dev')
                      //   const OfferBanner(),
                      const SizedBox(height: 16),
                      const OffersSection(),
                      const SizedBox(height: 16),
                      const BrandsSection(),

                      const SizedBox(height: 16),
                      const CategoryProductSection(),
                      const SizedBox(height: 16),

                      // const BrandsSection(),
                      // const SizedBox(height: 16),

                      // const SuggestionCard(),
                      // const SizedBox(height: 16),
                      // const FooterTagline(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  CategoriesSection _buildCategorySection(BuildContext context) {
    return CategoriesSection(
      onCategoryTap: (CategoryModel categoryData) {
        final homeState = context.read<HomeBloc>().state;
        final pincode = homeState.pincode!;

        final categoryState = context.read<CategoryBloc>().state;
        final List<CategoryModel> allCategories = [
          if (categoryState is CategoryLoaded) ...categoryState.categories,
        ];

        //TODO: Change to named routing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchProductRail(
              categoryId: categoryData.id,
              categoryName: categoryData.name,
              pincode: pincode,
              allCategories: allCategories,
            ),
          ),
        );
      },
    );
  }

  //   Color _getCategoryColor(String categoryName) {
  //     switch (categoryName.toLowerCase()) {
  //       case 'vegetables':
  //         return AppColors.catGreen;
  //       case 'fruits':
  //         return AppColors.catPeach;
  //       case 'beverages':
  //         return AppColors.catLavender;
  //       case 'dairy':
  //         return AppColors.catBlonde;
  //       case 'coffee & tea':
  //         return AppColors.catMint;
  //       case 'snacks':
  //         return AppColors.catPeriwinkle;
  //       case 'personal care':
  //         return AppColors.catPink;
  //       case 'household':
  //         return AppColors.catMagnolia;
  //       default:
  //         final hash = categoryName.hashCode;
  //         return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.2);
  //     }
  //   }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.leading,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  leading ?? Icons.location_on,
                  color: AppColors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
