// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:villag_kart/core/theme/colors.dart';
// import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_bloc.dart';
// import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
// import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_state.dart';
// import 'package:villag_kart/features/home/model/coupons_model.dart';
// import 'package:villag_kart/features/home/sections/section_header.dart';
// import 'package:villag_kart/features/location/bloc/location_service.dart';

// class CouponsSection extends StatefulWidget {
//   const CouponsSection({super.key});

//   @override
//   State<CouponsSection> createState() => _CouponsSectionState();
// }

// class _CouponsSectionState extends State<CouponsSection> {
//   @override
//   void initState() {
//     super.initState();
//     _fetchCoupons();
//   }

//   void _fetchCoupons() async {
//     final userId = await LocationService.getUserId();
//     final savedLocation = await LocationService.getSavedLocation();

//     if (savedLocation == null) {
//       debugPrint('⚠️ No saved location found');
//       return;
//     }

//     final pincode = savedLocation['pincode'] as String? ?? '';

//     if (pincode.isEmpty) {
//       debugPrint('⚠️ Invalid pincode');
//       return;
//     }

//     final cartValue = 1000.0; // You can make this dynamic based on cart state

//     if (mounted) {
//       context.read<CouponsBloc>().add(FetchCoupons(
//         userId: userId ?? '',
//         pincode: pincode,
//         cartValue: cartValue,
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CouponsBloc, CouponsState>(
//       builder: (context, state) {
//         debugPrint('🔄 CouponsSection State: $state');

//         // Hide the ENTIRE section (including title) if no coupons
//         if (state is CouponsEmpty ||
//             (state is CouponsLoaded && state.coupons.isEmpty)) {
//           debugPrint('🚫 Coupons section completely hidden - no coupons');
//           return const SizedBox.shrink();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top info banner (always show this part)
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.local_shipping_outlined, color: AppColors.accent),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Free delivery on your VillagKart daily order',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Only show coupons section if we have coupons
//             if (state is CouponsLoading ||
//                 state is CouponsLoaded ||
//                 state is CouponsRefreshing ||
//                 state is CouponsError) ...[
//               const SectionHeader(title: 'Coupons for you', onSeeAll: null),
//               const SizedBox(height: 10),
//               _buildCouponsContent(state),
//             ],
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCouponsContent(CouponsState state) {
//     if (state is CouponsLoading) {
//       return _buildLoadingState();
//     }

//     if (state is CouponsError) {
//       return _buildErrorState(state.errorMessage);
//     }

//     if (state is CouponsLoaded || state is CouponsRefreshing) {
//       final coupons = state is CouponsLoaded
//           ? (state as CouponsLoaded).coupons
//           : (state as CouponsRefreshing).coupons;

//       // Double check if coupons are empty
//       if (coupons.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       return _buildCouponsList(
//         coupons,
//         state is CouponsRefreshing,
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   Widget _buildLoadingState() {
//     return SizedBox(
//       height: 67,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: 2,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           return Container(
//             width: 250,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 12,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: 80,
//                           height: 10,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: 60,
//                           height: 10,
//                           color: Colors.grey.shade300,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(String errorMessage) {
//     return Container(
//       height: 67,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Center(
//         child: Text(
//           'Failed to load coupons: $errorMessage',
//           style: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildCouponsList(List<Coupon> coupons, bool isLoading) {
//     if (coupons.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Stack(
//       children: [
//         SizedBox(
//           height: 67,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: coupons.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               final coupon = coupons[index];
//               return _buildCouponCard(coupon);
//             },
//           ),
//         ),
//         if (isLoading)
//           Positioned.fill(
//             child: Container(
//               color: Colors.white.withOpacity(0.7),
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildCouponCard(Coupon coupon) {
//     return Container(
//       width: 250,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.grey.shade300,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Coupon Icon
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.orange.shade100,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               Icons.local_offer,
//               color: Colors.orange.shade600,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Coupon Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   coupon.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: AppColors.primary,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   coupon.description,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: AppColors.secondary,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   coupon.formattedMinCart,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.green,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Coupon Code
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 color: Colors.orange.shade200,
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               coupon.code,
//               style: TextStyle(
//                 color: Colors.orange.shade700,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// coupons_section.dart
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_bloc.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_events.dart';
import 'package:villag_kart/features/home/bloc/coupons_bloc/coupons_state.dart';
import 'package:villag_kart/features/home/model/coupons_model.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';

class CouponsSection extends StatefulWidget {
  const CouponsSection({super.key});

  @override
  State<CouponsSection> createState() => _CouponsSectionState();
}

class _CouponsSectionState extends State<CouponsSection> {
  final ScrollController _CouponsController = ScrollController();
  int _totalCoupons = 1;
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _CouponsController.addListener(() {
      if (!_CouponsController.hasClients) return;

      const double itemWidth = 270; // 258 + spacing
      final currentIndex = (_CouponsController.offset / itemWidth).round();

      if (_totalCoupons == 0) return;

      setState(() {
        _scrollProgress = ((currentIndex + 1) / _totalCoupons);
      });
    });
    _fetchCoupons();
  }

  void _fetchCoupons() async {
    final userId = await LocationService.getUserId();
    final savedLocation = await LocationService.getSavedLocation();

    if (savedLocation == null) {
      debugPrint('⚠️ No saved location found');
      return;
    }

    final pincode = savedLocation['pincode'] as String? ?? '';

    if (pincode.isEmpty) {
      debugPrint('⚠️ Invalid pincode');
      return;
    }

    final cartValue = 1000.0; // Make this dynamic based on actual cart

    if (mounted) {
      context.read<CouponsBloc>().add(
        FetchCoupons(
          userId: userId ?? '',
          pincode: pincode,
          cartValue: cartValue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CouponsBloc, CouponsState>(
      builder: (context, state) {
        debugPrint('🔄 CouponsSection State: $state');

        // Hide entire section if no coupons
        if (state is CouponsEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top info banner (always show this part)
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Colors.orange.shade50,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: const Row(
            //     children: [
            //       Icon(Icons.local_shipping_outlined, color: AppColors.accent),
            //       SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           'Free delivery on your VillagKart daily order',
            //           style: TextStyle(
            //             color: AppColors.primary,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 16),

            // Only show coupons section if we have coupons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Coupons for you'),

                // 🔹 Top-right scroll indicator
                Container(
                  width: 36,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _totalCoupons <= 4
                          ? 1
                          : (_scrollProgress).clamp(0.2, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildCouponsContent(state),
          ],
        );
      },
    );
  }

  Widget _buildCouponsContent(CouponsState state) {
    if (state is CouponsLoading) {
      return _buildLoadingState();
    }

    if (state is CouponsError) {
      return _buildErrorState(state.errorMessage);
    }

    if (state is CouponsLoaded || state is CouponsRefreshing) {
      final coupons = state is CouponsLoaded
          ? (state as CouponsLoaded).coupons
          : (state as CouponsRefreshing).coupons;

      if (coupons.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildCouponsList(coupons, state is CouponsRefreshing);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 67,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 10,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 10,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      height: 67,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          'Failed to load coupons: $errorMessage',
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCouponsList(List<Coupon> coupons, bool isLoading) {
    return Stack(
      children: [
        SizedBox(
          height: 67,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.maxScrollExtent > 0) {
                final progress =
                    (notification.metrics.pixels /
                            notification.metrics.maxScrollExtent)
                        .clamp(0.0, 1.0);

                setState(() {
                  _scrollProgress = progress;
                });
              }
              return true;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return _buildCouponCard(coupon);
              },
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔹 DOTTED BORDER CARD
        DottedBorder(
          color: const Color(0xFFE5E5E5),
          strokeWidth: 1.8,
          dashPattern: const [6, 4], // 👈 cut effect
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: Container(
            width: 258,
            height: 74,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Coupon Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFFFF9800),
                  ),
                ),

                const SizedBox(width: 12),

                // Coupon Text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            coupon.code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.circle, size: 4, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              coupon.formattedMinCart,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
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
        ),
      ],
    );
  }
}
