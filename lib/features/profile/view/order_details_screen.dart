import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/chatSupport/chatSupport.dart';
import 'package:villag_kart/features/profile/bloc/invoice/invoice_bloc.dart';
import 'package:villag_kart/features/profile/bloc/invoice/invoice_event.dart';
import 'package:villag_kart/features/profile/bloc/invoice/invoice_state.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/view/invoice_screen.dart';
import 'package:villag_kart/features/profile/view/repeate_order_screen.dart';
import 'package:villag_kart/features/profile/bloc/order_details/order_details_bloc.dart';
import 'package:villag_kart/features/profile/bloc/order_details/order_details_event.dart';
import 'package:villag_kart/features/profile/bloc/order_details/order_details_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order; // Changed from OrderModel to Order
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Separate invoice listener
  void _setupInvoiceListener(BuildContext context) {
    // Listen for invoice states from InvoiceBloc
    context.read<InvoiceBloc>().stream.listen((state) {
      if (state is InvoiceDownloadedState) {
        _showDownloadSuccess(state.filePath);
      } else if (state is InvoiceErrorState) {
        _showInvoiceError(state.error);
      }
    });
  }

  void _showInvoiceError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDownloadSuccess(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice downloaded to: $filePath'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _getInvoice() {
    // Navigate to InvoiceScreen
   context.pushNamed(
  'invoice',
  extra: {
    'orderId': widget.order.id,
    'orderNumber': widget.order.orderNumber,
  },
);
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot make phone call')),
    );
  }
}

Future<void> _sendMessage(String phoneNumber) async {
  final Uri url = Uri(
    scheme: 'sms',
    path: phoneNumber,
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot send message')),
    );
  }
}

  // void _downloadInvoice() {
  //   context.read<InvoiceBloc>().add(
  //     DownloadInvoiceEvent(orderId: widget.order.id),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Calculate totals from new Order model
    final double itemTotal = widget.order.taxableAmount;
    final double discountAmount = widget.order.discount + widget.order.couponDiscount;
    final double deliveryCharge = widget.order.deliveryCharge;
    final double taxAmount = widget.order.taxAmount;
    final double finalTotal = widget.order.totalAmount;

    return MultiBlocProvider(
    providers: [
  BlocProvider<InvoiceBloc>(
    create: (context) => InvoiceBloc(),
  ),

  BlocProvider<OrderDetailsBloc>(
    create: (_) => OrderDetailsBloc()
      ..add(
        FetchOrderDetails(
          orderId: widget.order.id,
        ),
      ),
  ),
],
      child: Builder(
        builder: (context) {
          // Setup listener once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setupInvoiceListener(context);
          });

          return BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
  builder: (context, orderState) {

    Order order = widget.order;

    if (orderState is OrderDetailsLoaded) {
      order = orderState.order;
    }

    if (orderState is OrderDetailsLoading) {
    debugPrint('delname${order.delivery.name}');
debugPrint(order.delivery.phone);
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (orderState is OrderDetailsError) {
      return Scaffold(
        body: Center(
          child: Text(orderState.errorMessage),
        ),
      );
    }

          return BlocListener<CartBloc,CartState>(
            listener:(context,state){
              if(state is CartLoadedState){
                Navigator.of(context,rootNavigator: true).pop();
                context.pushNamed('reviewitem');
              }
              if(state is CartLoading){
             showDialog(context: context,
             barrierDismissible: false,
              builder: (_){
                return const Center(child: CircularProgressIndicator(),);

              });
              }
              if(state is CartError){
                Navigator.of(context,rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message),));
              }
            } ,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F8F8),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                shadowColor:const Color(0xFFDBDBDB),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(context),
                ),
                title: Text(
                  'Order#${widget.order.orderNumber}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height:26,
                      width:55,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:const Color(0xFF00A600),
                          width:0.7,
                        ),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>const LagroceSupportScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          
                          backgroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                         
                        ),
                        child:const Center(
                          child: Text(
                            'Help',
                            style: TextStyle(
                              color: Color(0xFF00A600),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: BlocListener<InvoiceBloc, InvoiceState>(
                listener: (context, state) {
                  if (state is InvoiceDownloadingState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloading invoice for order #${state.orderId}...',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Section
                            Container(
                             
                              width:double.infinity,
                            
                                color:const Color(0xFFFFFFFF),
                              
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child:Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.order.isDelivered?
                const  Icon(Icons.check_circle,
                  size: 20,
                  color: Color(0xFF00891D),)
                    :
                    Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(widget.order.status)
                  .withOpacity(0.2),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(widget.order.status),
                ),
              ),
            ),
                    ),
            
                    const SizedBox(width: 12),
                    
                    Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
             
                
                 Text(
                  widget.order.isDelivered?
                  'Order Successfully delivered':
                  'Order Details',
                  style: TextStyle(
                    fontFamily: 'Seoge UI',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
            
                const SizedBox(height: 4),
            
               
                Row(
                  children: [
                    Text(
                      widget.order.formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontFamily: 'Seoge UI',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            
                    const SizedBox(width: 15),
            
                    Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
            
                    const SizedBox(width: 6),
            
                    Text(
                      order.status,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
                    ),
                  ],
                ),
               const SizedBox(height:12),
                Row(
                    children: [
                //    const CircleAvatar(
                //    radius: 20.5, // half of 41
                //    backgroundImage: NetworkImage(
                //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnnxcov-khlPpm2_Losk7F4DPv83G3XWY-ecvWOPzP1lNzOqstNIJRJrJ2Hhycl6dW6XYZ&s',
                //    ),
                 
                //  ),
                //  const SizedBox(width:16),
                 
                Expanded(
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                    Text('Delivered partner',style:TextStyle(
            fontFamily: 'Seoge UI',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
                    )),
                   Text( order.delivery.name?.trim().isNotEmpty == true
     ? order.delivery.name!
     : "Not Assigned",style:TextStyle(fontFamily: 'Seoge UI',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black
                    ))
                     ],
                   ),
                ),
            
                IconButton(
  onPressed: () {
    final phone = order.delivery.phone;

    if (phone != null && phone.isNotEmpty) {
      _sendMessage(phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  },
  icon: const Icon(Icons.messenger_outline_sharp, size: 24, color: Color(0xFF292D32)),
),
                const  SizedBox(width:24),
                 
           IconButton(
  onPressed: () {
    final phone = order.delivery.phone;

    if (phone != null && phone.isNotEmpty) {
      _makePhoneCall(phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  },
  icon: const Icon(Icons.phone, size: 24, color: Color(0xFF292D32)),
),
                    ],
                  ),
               
              ],
            )
                              ),
                            ),
                            const SizedBox(height: 12),
            
                            // Address Section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [ 
                                  Container(
                                  
                                    decoration:const BoxDecoration(
                                     color: Color(0xFFFFFFFF) 
                                    ),
                                    child:Padding(
                                      padding:  const EdgeInsets.all(14.0),
                                      child: Column(
                                        
                                        children: [
                                        Row(
  children: [
    const Column(
      children: [
        Icon(Icons.location_pin, size: 16, color: Color(0xFFEF5A06)),
        SizedBox(
          height: 60,
          child: DottedLine(
            direction: Axis.vertical,
            lineThickness: 1,
            dashColor: Color(0xFFBEBEBE),
            dashLength: 3,
            dashGapLength: 3,
          ),
        ),
        Icon(Icons.location_pin, size: 16, color: Color(0xFFEF5A06)),
      ],
    ),

    const SizedBox(width: 16),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.order.storeName,
            style: const TextStyle(
              fontFamily: 'Seoge UI',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 40),

          Text(
            widget.order.address.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: 'Seoge UI',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),

          Text( 
            widget.order.address.fullAddress,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'Seoge UI',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  ],
)
                                        ],
                                      ),
                                    ) ,
                                  ),
                               
                            
                              const SizedBox(height: 14),
                              
                        
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       const Text(
                                  'Item Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                                              ),
                                      for (int i = 0; i < widget.order.items.length; i++)
                                        Column(
                                          children: [
                                            _buildItemRow(widget.order.items[i]),
                                            if (i < widget.order.items.length - 1)
                                             const Divider(color: Color(0xFFFFFFFF),),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 14),
                              
                              
                              
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     const Text(
                                'Bill Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 15),
                                    // Item Total
                                    _billRow(
                                      'Items Total',
                                      '₹${itemTotal.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 4),
                              
                                    // Discount
                                    if (widget.order.discount > 0)
                                      _billRow(
                                        'Discount',
                                        '-₹${widget.order.discount.toStringAsFixed(2)}',
                                      ),
                                    if (widget.order.discount > 0)
                                      const SizedBox(height: 4),
                              
                                    // Coupon Discount
                                    if (widget.order.couponDiscount > 0)
                                      _billRow(
                                        'Coupon Discount',
                                        '-₹${widget.order.couponDiscount.toStringAsFixed(2)}',
                                      ),
                                    if (widget.order.couponDiscount > 0)
                                      const SizedBox(height: 4),
                              
                                    // Delivery Charge
                                    if (deliveryCharge > 0)
                                      _billRow(
                                        'Delivery Fee',
                                        '₹${deliveryCharge.toStringAsFixed(2)}',
                                      ),
                                    if (deliveryCharge > 0)
                                      const SizedBox(height: 4),
                              
                                    // Tax
                                    if (taxAmount > 0)
                                      _billRow(
                                        'Tax (GST)',
                                        '₹${taxAmount.toStringAsFixed(2)}',
                                      ),
                                    if (taxAmount > 0) const SizedBox(height: 4),
                              
                                    const Divider(),
                              
                                    // Final Total
                                    _billRow(
                                      'To Paid',
                                      '₹${finalTotal.toStringAsFixed(2)}',
                                      isTotal: true,
                                    ),
                                    const SizedBox(height: 4),
                              
                                    // Payment Status
                                    // _billRow(
                                    //   'Payment Status',
                                    //   widget.order.payment.isPaid ? 'Paid' : 'Pending',
                                    //   valueColor: widget.order.payment.isPaid
                                    //       ? Colors.green
                                    //       : Colors.orange,
                                    // ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              // Invoice Buttons Section
                              // const SizedBox(height: 14),
                              // Container(
                              //   padding: const EdgeInsets.all(14),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     borderRadius: BorderRadius.circular(10),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Expanded(
                              //         child: ElevatedButton.icon(
                              //           onPressed: _downloadInvoice,
                              //           style: ElevatedButton.styleFrom(
                              //             backgroundColor: const Color(0xFF4CAF50),
                              //             padding: const EdgeInsets.symmetric(
                              //               vertical: 12,
                              //               horizontal: 16,
                              //             ),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(8),
                              //             ),
                              //           ),
                              //           icon: const Icon(
                              //             Icons.download,
                              //             color: Colors.white,
                              //             size: 18,
                              //           ),
                              //           label: const Text(
                              //             'Download Invoice',
                              //             style: TextStyle(
                              //               color: Colors.white,
                              //               fontSize: 14,
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       const SizedBox(width: 12),
                              //       Expanded(
                              //         child: ElevatedButton.icon(
                              //           onPressed: _getInvoice,
                              //           style: ElevatedButton.styleFrom(
                              //             backgroundColor: const Color(0xFF2196F3),
                              //             padding: const EdgeInsets.symmetric(
                              //               vertical: 12,
                              //               horizontal: 16,
                              //             ),
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(8),
                              //             ),
                              //           ),
                              //           icon: const Icon(
                              //             Icons.visibility,
                              //             color: Colors.white,
                              //             size: 18,
                              //           ),
                              //           label: const Text(
                              //             'View Invoice',
                              //             style: TextStyle(
                              //               color: Colors.white,
                              //               fontSize: 14,
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              
                              const SizedBox(height: 20),
                                                      ],
                                                    ),
                            ),
                         ],
                            ),
                      ),
                    ),
                    if(widget.order.isDelivered || widget.order.isCancelled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child:PrimaryButton( 
                        onPressed: () {              
                                context.read<CartBloc>().add(
                                  ReorderItemsEvent(orderId: widget.order.id.toString())
                                );     
                              },
                              label: 'Repeat Order',
                              )
                    ),
                  ],
                ),
              ),
            ),
          );
        },);
      }
          )
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${item.quantity}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                // Text(
                //   'Unit: ${item.product.unit}',
                //   style: const TextStyle(fontSize: 11, color: Colors.grey),
                // ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.mrp != null && item.mrp! > item.unitPrice)
                Text(
                  '₹${item.mrp!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                '₹${item.unitPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              // Text(
              //   'Total: ₹${item.totalPrice.toStringAsFixed(2)}',
              //   style: const TextStyle(fontSize: 11, color: Colors.grey),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'PLACED':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PROCESSING':
        return Colors.blue;
      case 'READY_FOR_PICKUP':
      case 'OUT_FOR_DELIVERY':
        return Colors.blue;
      case 'RETURN_INITIATED':
        return Colors.orange;
      case 'DELIVERED':
        return Colors.green;
      case 'RETURNED':
        return Colors.teal;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _billRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;
  const _billRow(
    this.label,
    this.value, {
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color:
                valueColor ??
                (isTotal ? const Color(0xFF2C9E19) : Colors.black),
          ),
        ),
      ],
    );
  }
}