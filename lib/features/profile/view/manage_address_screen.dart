import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/utils/distance_utils.dart';
import '../bloc/manage_address/manage_address_bloc.dart';
import '../bloc/manage_address/manage_address_event.dart';
import '../bloc/manage_address/manage_address_state.dart';
import '../model/order_history_model.dart';
import 'add_address.dart';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  late AddressBloc _addressBloc;
  double? _warehouseLat;
  double? _warehouseLng;

  @override
  void initState() {
    super.initState();
    _addressBloc = AddressBloc();

    // Fetch addresses when screen loads
    _addressBloc.add(FetchAddresses());
    _loadWarehouse();
  }

  @override
  void dispose() {
    _addressBloc.close();
    super.dispose();
  }

  Future<void> _loadWarehouse() async {
    final warehouse = await SharedPrefs.getWarehouse();
    if (warehouse != null && mounted) {
      setState(() {
        _warehouseLat = warehouse.location.latitude;
        _warehouseLng = warehouse.location.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressBloc>(
      create: (context) => _addressBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(context),
          ),
          title: const Text(
            'Manage Address',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return _buildLoadingState();
            }

            if (state is AddressError) {
              return _buildErrorState(state.errorMessage);
            }

            if (state is AddressEmpty) {
              return _buildEmptyStateWithAddButton();
            }

            if (state is AddressLoaded ||
                state is AddressRefreshing ||
                state is AddressDeleted ||
                state is AddressDeleting) {
              // Extract addresses from different state types
              List<Address> addresses = [];
              String? deletingAddressId;

              if (state is AddressLoaded) {
                addresses = state.addresses;
              } else if (state is AddressRefreshing) {
                addresses = state.addresses;
              } else if (state is AddressDeleted) {
                addresses = state.addresses;
              } else if (state is AddressDeleting) {
                addresses = state.addresses;
                deletingAddressId = state.deletingAddressId;
              }

              // If addresses list is empty, show empty state with add button
              if (addresses.isEmpty) {
                return _buildEmptyStateWithAddButton();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AddressBloc>().add(RefreshAddresses());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ...addresses.map((address) {
                          final isDeleting = deletingAddressId == address.id;
                          // Calculate distance
                          String? distance;
                          if (_warehouseLat != null &&
                              _warehouseLng != null &&
                              address.location != null) {
                            final km = DistanceUtils.calculateKm(
                              _warehouseLat!,
                              _warehouseLng!,
                              address.location!.lat,
                              address.location!.lng,
                            );
                            distance = DistanceUtils.formatDistance(km);
                          }
                          return _buildAddressCard(
                            address: address,
                            isDeleting: isDeleting,
                            distance: distance,
                            onDelete: () {
                              _showDeleteConfirmation(context, address);
                            },
                          );
                        }).toList(),
                        // Add new address button
                        _buildAddAddressButton(),
                      ],
                    ),
                  ),
                ),
              );
            }

            return _buildEmptyStateWithAddButton();
          },
        ),
      ),
    );
  }

  // ============================= ADD ADDRESS BUTTON =============================
  Widget _buildAddAddressButton() {
    return GestureDetector(
      onTap: () async {
        final result = await context.pushNamed('addAddress');

        if (result is Address) {
          _addressBloc.add(FetchAddresses()); // Refresh
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '+Add new address',
          style: TextStyle(
            color: Colors.green,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================= LOADING STATE =============================
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 12,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 15,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================= EMPTY STATE WITH ADD BUTTON =============================
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

  // ============================= ERROR STATE =============================
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _addressBloc.add(FetchAddresses());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================= ADDRESS CARD =============================
  Widget _buildAddressCard({
    required Address address,
    required bool isDeleting,
    String? distance,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location icon + distance
              Column(
                children: [
                  const ImageIcon(
                    AssetImage('assets/icons/location-tick.png'),
                    size: 30,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 4),
                  if (distance != null)
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),

              // Address details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await context.pushNamed(
                              'addAddress',
                              extra: address,
                            );

                            if (result is Address) {
                              _addressBloc.add(FetchAddresses());
                            }
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          /* onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share feature coming soon'),
                              ),
                            );
                          },*/
                          onTap: () {
                            try {
                              Share.share(
                                'Here is my address:\n${address.fullAddress}',
                                subject: 'My Address',
                              );
                            } catch (e) {
                              debugPrint('Share failed: $e');
                            }
                          },

                          child: const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Deleting overlay
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================= DELETE CONFIRMATION DIALOG =============================
  void _showDeleteConfirmation(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: Text(
            'Are you sure you want to delete "${address.label}" address?',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop(context);
                // Delete the address
                _addressBloc.add(DeleteAddress(addressId: address.id));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}



//                 // Delete the address
//                 _addressBloc.add(DeleteAddress(addressId: address.id));
//               },
//               child: const Text(
//                 'Delete',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }



// class ManageAddressScreen extends StatefulWidget {
//   const ManageAddressScreen({super.key});

//   @override
//   State<ManageAddressScreen> createState() => _ManageAddressScreenState();
// }

// class _ManageAddressScreenState extends State<ManageAddressScreen> {
//   late AddressBloc _addressBloc;

//   @override
//   void initState() {
//     super.initState();
//     _addressBloc = AddressBloc();
    
//     // Fetch addresses when screen loads
//     _addressBloc.add(FetchAddresses());
//   }

//   @override
//   void dispose() {
//     _addressBloc.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<AddressBloc>(
//       create: (context) => _addressBloc,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF2F2F2),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => context.pop(context),
//           ),
//           title: const Text(
//             "Manage Address",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         body: BlocBuilder<AddressBloc, AddressState>(
//           builder: (context, state) {
//             if (state is AddressLoading) {
//               return _buildLoadingState();
//             }

//             if (state is AddressError) {
//               return _buildErrorState(state.errorMessage);
//             }

//             if (state is AddressEmpty) {
//               return _buildEmptyState(state.message);
//             }

//             if (state is AddressLoaded ||
//                 state is AddressRefreshing ||
//                 state is AddressDeleted ||
//                 state is AddressDeleting) {
//               // Extract addresses from different state types
//               List<Address> addresses = [];
//               String? deletingAddressId;

//               if (state is AddressLoaded) {
//                 addresses = state.addresses;
//               } else if (state is AddressRefreshing) {
//                 addresses = state.addresses;
//               } else if (state is AddressDeleted) {
//                 addresses = state.addresses;
//               } else if (state is AddressDeleting) {
//                 addresses = state.addresses;
//                 deletingAddressId = state.deletingAddressId;
//               }

//               return RefreshIndicator(
//                 onRefresh: () async {
//                   context.read<AddressBloc>().add(RefreshAddresses());
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       children: [
//                         ...addresses.map((address) {
//                           final isDeleting = deletingAddressId == address.id;
//                           return _buildAddressCard(
//                             address: address,
//                             isDeleting: isDeleting,
//                             onDelete: () {
//                               _showDeleteConfirmation(
//                                 context,
//                                 address,
//                               );
//                             },
//                           );
//                         }).toList(),
//                         // Add new address button
//                         GestureDetector(
//                           onTap: ()
//                           {

//                                           // Add new address
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AddAddressScreen(),
//                           ),
//                         ).then((result) {
//                           if (result is Address) {
//                             _addressBloc.add(FetchAddresses()); // Refresh
//                           }
//                           });

//                           // Edit existing address
                       
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(top: 4, bottom: 20),
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Text(
//                               "+Add new address",
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }

//             return _buildEmptyState('No data available');
//           },
//         ),
//       ),
//     );
//   }

//   // ============================= LOADING STATE =============================
//   Widget _buildLoadingState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         children: List.generate(3, (index) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       width: 40,
//                       height: 12,
//                       color: Colors.grey.shade300,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 15,
//                         color: Colors.grey.shade300,
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: double.infinity,
//                         height: 40,
//                         color: Colors.grey.shade300,
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: 200,
//                         height: 12,
//                         color: Colors.grey.shade300,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   // ============================= EMPTY STATE =============================
//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.location_off_outlined,
//               size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               _addressBloc.add(FetchAddresses());
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Retry',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================= ERROR STATE =============================
//   Widget _buildErrorState(String errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 64, color: Colors.red),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               'Error: $errorMessage',
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               _addressBloc.add(FetchAddresses());
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Retry',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================= ADDRESS CARD =============================
//   Widget _buildAddressCard({
//     required Address address,
//     required bool isDeleting,
//     required VoidCallback onDelete,
//   }) {
//     return Stack(
//       children: [
//         Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Location icon + distance
//               Column(
//                 children: [
//                   const Icon(Icons.location_on_outlined,
//                       color: Colors.black54, size: 20),
//                   const SizedBox(height: 4),
//                   if (address.isDefault)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: const Text(
//                         'Default',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(width: 10),

//               // Address details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       address.label,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       address.fullAddress,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         height: 1.4,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                          Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddAddressScreen(
//                                 existingAddress: address,
//                               ),
//                             ),
//                           );

//                           },
//                           child: const Text(
//                             "Edit",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//                         GestureDetector(
//                           onTap: onDelete,
//                           child: const Text(
//                             "Delete",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//                         GestureDetector(
//                           onTap: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Share feature coming soon'),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Share",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Deleting overlay
//         if (isDeleting)
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Center(
//                 child: SizedBox(
//                   width: 30,
//                   height: 30,
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 3,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================= DELETE CONFIRMATION DIALOG =============================
//   void _showDeleteConfirmation(BuildContext context, Address address) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Address'),
//           content: Text(
//             'Are you sure you want to delete "${address.label}" address?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => context.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 context.pop(context);import 'package:flutter/material.dart';


