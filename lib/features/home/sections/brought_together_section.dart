// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
// import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_bloc.dart';
// import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_products_event.dart';
// import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_produts_state.dart';
// import 'package:villag_kart/features/home/model/product_response.dart';
// import 'package:villag_kart/features/home/sections/popular_product_screen.dart';
// import 'package:villag_kart/features/home/sections/section_header.dart';
// import 'package:villag_kart/features/location/bloc/location_service.dart';
// import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
// import 'package:villag_kart/features/search/view/widgets/product_card.dart';

// class ProductSuggestionsSection extends StatefulWidget {
//   const ProductSuggestionsSection({super.key});

//   @override
//   State<ProductSuggestionsSection> createState() => _PopularSectionState();
// }

// class _PopularSectionState extends State<ProductSuggestionsSection> {
  
//   @override
//   void initState() {
//     super.initState();

//   }

//   void _fetchPopularProducts() async {
//     final savedLocation = await LocationService.getSavedLocation();
//     final homeState = context.watch<HomeBloc>().state;
//     String _pincode = homeState.pincode ?? '';
//     if (savedLocation == null) {
//       debugPrint('⚠️ No saved location found');
//       return;
//     }

//     final pincode = savedLocation['pincode'] as String? ?? '';

//     if (pincode.isEmpty) {
//       debugPrint('⚠️ Invalid pincode');
//       return;
//     }

//     // Store pincode for navigation
//     setState(() {
//       _pincode = pincode;
//     });

//     if (mounted) {
//       context.read<PopularProductsBloc>().add(
//         FetchPopularProducts(pincode: pincode, limit: 10),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final homeState = context.watch<HomeBloc>().state;
//     final _pincode = homeState.pincode ?? '';
//     return BlocBuilder<PopularProductsBloc, PopularProductsState>(
//       builder: (context, state) {
//         debugPrint('🔄 PopularSection State: $state');
//         if (state is PopularProductsEmpty) {
//           return const SizedBox.shrink();
//         }
//         if (state is PopularProductsLoaded && state.products.isEmpty) {
//         return const SizedBox.shrink();
//       }
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SectionHeader(
//               title: 'Although brought together',
//               onSeeAll: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         PopularProductsScreen(pincode: _pincode),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 8),

//             // Show different states
//             _buildContent(state),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildContent(PopularProductsState state) {
//     if (state is PopularProductsError) {
//       return _buildErrorState(state.errorMessage);
//     }

//     if (state is PopularProductsLoaded) {
//       debugPrint('🎯 Products loaded: ${state.products.length}');
//       return _buildProductsList(state.products);
//     }

//     // if (state is PopularProductsEmpty) {
//     //   return _buildEmptyState();
//     // }

//     // Initial state - show loading
//     return _buildLoadingState();
//   }

//   Widget _buildLoadingState() {
//     return SizedBox(
//       height: 160,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: 4,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           return Container(
//             width: 120,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 70,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: 60,
//                         height: 12,
//                         color: Colors.grey.shade200,
//                       ),
//                       const SizedBox(height: 4),
//                       Container(
//                         width: 40,
//                         height: 10,
//                         color: Colors.grey.shade200,
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             width: 30,
//                             height: 12,
//                             color: Colors.grey.shade200,
//                           ),
//                           const Spacer(),
//                           Container(
//                             width: 25,
//                             height: 10,
//                             color: Colors.grey.shade200,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(String errorMessage) {
//     return Container(
//       height: 160,
//       padding: const EdgeInsets.all(16),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
//             const SizedBox(height: 8),
//             Text(
//               'Failed to load products',
//               style: TextStyle(color: Colors.red.shade700, fontSize: 12),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               errorMessage,
//               style: TextStyle(color: Colors.red.shade600, fontSize: 10),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _fetchPopularProducts,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//               ),
//               child: const Text('Retry', style: TextStyle(fontSize: 12)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       height: 160,
//       padding: const EdgeInsets.all(16),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.shopping_bag_outlined,
//               color: Colors.grey.shade400,
//               size: 40,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'No popular products',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'Check back later for updates',
//               style: TextStyle(color: Colors.grey, fontSize: 10),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductsList(List<Product> products) {
//     if (products.isEmpty) {
//       return _buildEmptyState();
//     }
//  final homeState = context.watch<HomeBloc>().state;
//     String warehouseId = homeState.warehouseId ?? '';
//     return SizedBox(
//       height: 160,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         physics: const BouncingScrollPhysics(),
//         itemCount: products.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           final product = products[index];

//           return SizedBox(
//             width: 120,
//             child: ProductCard(
//               product: product,
//               warehouseId: warehouseId,
//               onTap: () => _navigateToProductDetail(context, product),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _navigateToProductDetail(BuildContext context, Product product) {
//     final homeState = context.watch<HomeBloc>().state;
//     String _pincode = homeState.pincode ?? '';
//     // Navigate to product detail page
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             ProductDetailPage(product: product, pincode: _pincode),
//       ),
//     );
//   }
// }
