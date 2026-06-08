import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/core/widgets/custom_appbar/custom_app_bar.dart';
import 'package:villag_kart/features/map/widget/route_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map_route_bloc.dart';
import '../bloc/map_route_evet.dart';
import '../bloc/map_route_state.dart';
import '../model/map_route_model.dart';

// Sample points (replace with actual delivery route)
final samplePoints = <LatLng>[
  const LatLng(17.443, 78.391),
  const LatLng(17.444, 78.392),
  const LatLng(17.446, 78.395),
  const LatLng(17.448, 78.398),
  const LatLng(17.451, 78.402),
];

class MapRouteScreen extends StatefulWidget {
  final String orderId;

  const MapRouteScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  late OrderTrackingBloc _trackingBloc;

  @override
  void initState() {
    super.initState();
    _trackingBloc = OrderTrackingBloc();
    
    // Fetch tracking data when screen loads
    _trackingBloc.add(FetchOrderTracking(orderId: widget.orderId));
  }

  @override
  void dispose() {
    _trackingBloc.close();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderTrackingBloc>(
      create: (context) => _trackingBloc,
      child: Scaffold(
        // appBar: const CustomAppBar(
        //   title: 'Track Order',
        //   showBackButton: true,
        // ),
        body: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
          builder: (context, state) {
            return Stack(
              children: [

                /// GOOGLE MAP (TOP AREA)
                Container(
                  height:550.h,
                    width: double.infinity,
                  child: _buildMapView(),
                ),

                /// BOTTOM PANEL (Tracking Info)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomPanel(context, state),
                ),
                
              ]
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return RouteMap(
      routePoints: samplePoints,
      startLabel: 'VillagKart',
      endLabel: 'Customer',
    );
  }

  // ============================= BOTTOM PANEL =============================
  Widget _buildBottomPanel(BuildContext context, OrderTrackingState state) {
    if (state is OrderTrackingLoading) {
      return _buildLoadingPanel();
    }

    if (state is OrderTrackingError) {
      return _buildErrorPanel(state.errorMessage);
    }

    if (state is OrderTrackingLoaded || state is OrderTrackingRefreshing) {
      final trackingData = state is OrderTrackingLoaded
          ? state.trackingData
          : (state as OrderTrackingRefreshing).trackingData;

      return _buildTrackingPanel(context, trackingData);
    }

    return _buildEmptyPanel();
  }

  // ============================= LOADING PANEL =============================
  Widget _buildLoadingPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFE46A0A),
          ),
          SizedBox(height: 12),
          Text('Loading tracking information...'),
        ],
      ),
    );
  }

  // ============================= ERROR PANEL =============================
  Widget _buildErrorPanel(String errorMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _trackingBloc.add(FetchOrderTracking(orderId: widget.orderId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ============================= EMPTY PANEL =============================
  Widget _buildEmptyPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Text('No tracking information available'),
    );
  }

  // ============================= TRACKING PANEL =============================
  Widget _buildTrackingPanel(
    BuildContext context,
    OrderTrackingData trackingData,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<OrderTrackingBloc>().add(
              RefreshOrderTracking(orderId: widget.orderId),
            );
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Handle bar
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ORDER NUMBER + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${trackingData.orderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trackingData.currentStatus,
                            style: TextStyle(
                              fontSize: 13,
                              color: _getStatusColor(trackingData.currentStatus),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          trackingData.currentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor:
                            _getStatusColor(trackingData.currentStatus),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// DELIVERY ADDRESS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                trackingData.deliveryAddress.fullAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ESTIMATED DELIVERY
                  if (trackingData.estimatedDelivery != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimated Delivery',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(trackingData.estimatedDelivery!),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  /// TIMELINE HEADER
                  const Text(
                    'Order Timeline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// TIMELINE
                  _buildTimeline(trackingData.timeline),
                  const SizedBox(height: 16),
                ],
              ),
            )
          ),
        );
      },
    );
  }

  // ============================= TIMELINE =============================
  Widget _buildTimeline(List<TimelineEvent> timeline) {
    return Column(
      children: List.generate(
        timeline.length,
        (index) {
          final event = timeline[index];
          final isLast = index == timeline.length - 1;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Timeline dot + line
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.statusColor.withOpacity(0.2),
                          border: Border.all(
                            color: event.statusColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          event.statusIcon,
                          size: 18,
                          color: event.statusColor,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  /// Timeline content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.statusLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.message,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  // ============================= HELPER FUNCTIONS =============================

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ORDER_CONFIRMED':
        return Colors.blue;
      case 'PREPARING':
        return Colors.purple;
      case 'READY_FOR_DELIVERY':
        return Colors.indigo;
      case 'OUT_FOR_DELIVERY':
        return Colors.cyan;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}


// // sample points (replace with decode of Google Directions in production)
// final samplePoints = <LatLng>[
//   const LatLng(17.443, 78.391),
//   const LatLng(17.444, 78.392),
//   const LatLng(17.446, 78.395),
//   const LatLng(17.448, 78.398),
//   const LatLng(17.451, 78.402),
// ];

// class MapRouteScreen extends StatelessWidget {
//   const MapRouteScreen({super.key});


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Track Order',
//         showBackButton: true,
//       ),
//       body: Stack(
//         children: [

//           /// ---------------------------
//           /// GOOGLE MAP (TOP AREA)
//           /// ---------------------------
//           Positioned.fill(
//             child: _buildMapView(),
//           ),

//           /// ---------------------------
//           /// BOTTOM PANEL (Driver + Order)
//           /// ---------------------------
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: _buildBottomPanel(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMapView() {
//     return RouteMap(
//       routePoints: samplePoints,
//       startLabel: 'villarKart',
//       endLabel: 'Customer',
//     );
//   }

//   Widget _buildBottomPanel(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, -3),
//           )
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           /// DRIVER INFO
//           Row(
//             children: [
//               /// Driver image
//               ClipOval(
//                 child: Image.network(
//                   'https://i.pravatar.cc/100',
//                   height: 48,
//                   width: 48,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(width: 12),

//               /// Name + designation
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'George Underson',
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 3),
//                     Text(
//                       'Delivery Partner',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               /// Chat + Call icons
//               const Row(
//                 children: [
//                   Icon(Icons.chat_bubble_outline, size: 24),
//                   SizedBox(width: 14),
//                   Icon(Icons.call, size: 24),
//                 ],
//               )
//             ],
//           ),

//           const SizedBox(height: 16),

//           /// ORDER STATUS CARD
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFFEFFBEF),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 /// Animated green dot
//                 Container(
//                   height: 20,
//                   width: 20,
//                   decoration: const BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 /// Status + subtitle
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Preparing your order',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Assigned delivery partner',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           /// ORDER ITEMS + BUTTON
//           Row(
//             children: [
//               /// Item details
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '3 items • Paid',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'Beet root 1Kg|Onion 1Kg|Milk 1L',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               /// Order Details Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding:
//                   const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4)),
//                 ),
//                 onPressed: () {},
//                 child: const Text(
//                   'Order Details',
//                   style: TextStyle(fontSize: 15, color: Colors.white),
//                 ),
//               )
//             ],
//           ),

//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }
