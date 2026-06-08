

// import 'package:flutter/material.dart';
// import 'package:villag_kart/features/profile/model/order_history_model.dart';

// class RepeatOrderScreen extends StatelessWidget {
//   final Order order;
  
//   const RepeatOrderScreen({super.key, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     final deliveryBoyName = order.items.isNotEmpty ? 'Delivery Partner' : 'Store';
//     final sellerName = 'VillagKart Store';
//     final deliveryAddress = order.deliveryAddressText;
//     final finalTotal = order.formattedAmount;
    
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.3,
//         centerTitle: false,
//         titleSpacing: 0.0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => context.pop(context),
//         ),
//         title: Text(
//           'Order #${order.orderNumber}',
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: Chip(
//               label: Text(
//                 'Help',
//                 style: TextStyle(
//                   color: Color(0xFF2C9E19),
//                   fontSize: 12,
//                   
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               backgroundColor: Color(0xFFE8F5E9),
//               visualDensity: VisualDensity.compact,
//             ),
//           ),
//         ],
//       ),

//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       order.isDelivered ? Icons.check_circle : Icons.access_time,
//                       color: order.isDelivered 
//                           ? const Color(0xFF2C9E19) 
//                           : Colors.orange,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       order.isDelivered 
//                           ? 'Order Successfully delivered' 
//                           : 'Order ${order.status}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                         
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 26),
//                   child: Text(
//                     order.formattedDate,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF7C7C7C),
//                       
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),
//           _infoTile(Icons.store, sellerName, 'VillagKart Store, City Center'),
//           const SizedBox(height: 10),
//           _infoTile(Icons.home, 'Home', deliveryAddress),
//           const SizedBox(height: 10),

//           const Padding(
//             padding: EdgeInsets.only(left: 4, bottom: 6),
//             child: Text(
//               'Item Details',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           _itemBox(order),

//           const SizedBox(height: 10),
//           _billBox(order),

//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             height: 44,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2C9E19),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 // Add to cart logic here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('All items added to cart'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               },
//               child: const Text(
//                 'Repeat Order',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoTile(IconData icon, String title, String subtitle) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: const Color(0xFF2C9E19), size: 18),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     
//                     color: Colors.black,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: Color(0xFF5E5E5E),
//                     
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _itemBox(Order order) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: order.items.map((item) {
//           return _itemRow(
//             item.image,
//             item.product.name,
//             '${item.quantity} ${item.product.unit.toLowerCase()}',
//             '₹ ${item.totalPrice.toStringAsFixed(2)}',
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _itemRow(String img, String name, String qty, String price) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.grey[200],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: Image.network(
//                     img,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Colors.grey[200],
//                         child: const Icon(
//                           Icons.shopping_bag,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.black,
//                       
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     qty,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                       
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Text(
//             price,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black,
//               
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _billBox(Order order) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           _billRow('Items Total', '₹${order.taxableAmount.toStringAsFixed(2)}'),
//           if (order.discount > 0)
//             _billRow('Discount', '-₹${order.discount.toStringAsFixed(2)}'),
//           if (order.deliveryCharge > 0)
//             _billRow('Delivery Fee', '₹${order.deliveryCharge.toStringAsFixed(2)}'),
//           if (order.taxAmount > 0)
//             _billRow('Taxes', '₹${order.taxAmount.toStringAsFixed(2)}'),
//           const Divider(),
//           _billRow('Total Amount', order.formattedAmount, bold: true, green: true),
//         ],
//       ),
//     );
//   }
// }

// class _billRow extends StatelessWidget {
//   final String title, value;
//   final bool bold;
//   final bool green;

//   const _billRow(this.title, this.value, {this.bold = false, this.green = false});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
//               
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
//               
//               color: green ? const Color(0xFF2C9E19) : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }