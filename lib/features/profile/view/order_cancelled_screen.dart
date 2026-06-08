import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';

class OrderCancelledScreen extends StatefulWidget {
  final Order order;
   OrderCancelledScreen({super.key,required this.order});

  @override
  State<OrderCancelledScreen> createState() => _OrderCancelledScreenState();
 
}

class _OrderCancelledScreenState extends State<OrderCancelledScreen> {

 final  List<bool> _isSelected =[true,false];
  @override
  Widget build(BuildContext context) {

     final double itemTotal = widget.order.taxableAmount;
    final double discountAmount = widget.order.discount + widget.order.couponDiscount;
    final double deliveryCharge = widget.order.deliveryCharge;
    final double taxAmount = widget.order.taxAmount;
    final double finalTotal = widget.order.totalAmount;

    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          onPressed: () { 
            context.pop();
           }, icon: const
           Icon(Icons.arrow_back,size: 24,color: Colors.black,)),
        title: Text('#${widget.order.orderNumber}',
        style:const TextStyle(
          color: Colors.black,
          fontFamily: 'Seoge UI',
          fontSize: 18,
          fontWeight: FontWeight.w400
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${widget.order.status}',
                 style:const TextStyle(
            color: Color(0xFF333333),
            fontFamily: 'Seoge UI',
            fontSize: 12,
            fontWeight: FontWeight.w400
                    )),
              
                    Text('${widget.order.items.length}items,Rs${widget.order.totalAmount}',
                     style:const TextStyle(
            color: Color(0xFF333333),
            fontFamily: 'Seoge UI',
            fontSize: 12,
            fontWeight: FontWeight.w400
                    )),
                  
            
                  ],
                ),
          )
            ],
            elevation: 1,
            shadowColor:const Color(0xFFDBDBDB),
            backgroundColor:Colors.white ,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
              // ❌ REMOVE fixed height
              // height: 131,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 0.3,
                  color: Colors.white.withOpacity(0.20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ important
                  children: [
                    const Column(
            children: [
              Icon(Icons.location_on, color: Color(0xFFEF5A06)),
              SizedBox(
                height: 44,
                child: DottedLine(
                  lineThickness: 1,
                  direction: Axis.vertical,
                  dashGapColor: Color(0xFFBEBEBE),
                ),
              ),
              Icon(Icons.location_on, color: Color(0xFFEF5A06)),
            ],
                    ),
            
                    const SizedBox(width: 20),
            
                    /// ✅ FIX: Constrain width
                    Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle( fontFamily: 'Seoge UI', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF000000) )
                ),
            
                Text(
                  widget.order.address.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle(
                     fontFamily: 'Seoge UI', 
                     fontSize: 12, 
                     fontWeight: FontWeight.w400, 
                     color: Color(0xFF000000) )
                ),
            
                const SizedBox(height: 30),
            
                Text(
                  widget.order.address.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle( 
                    fontFamily: 'Seoge UI', 
                    fontSize: 12, 
                    fontWeight: FontWeight.w400, 
                    color: Color(0xFF000000) )
                ),
            
                /// ✅ FULL ADDRESS FIX
                Text(
                  widget.order.address.fullAddress,
                  maxLines: 2, // or 3 if needed
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle( 
                    fontFamily: 'Seoge UI', 
                    fontSize: 12, fontWeight: 
                    FontWeight.w400, 
                    color: Color(0xFF000000) )
                ),
              ],
            ),
                    ),
                  ],
                ),
              ),
            ),
                const  SizedBox(height:9),
            
                  Container(
                   
                    width: double.infinity,
                  
                    decoration: BoxDecoration(
                    color:const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top:16.0,left: 16,right: 16,bottom: 10),
                      child: Column(
                        children: [
                        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT SIDE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            const Text(
              'Refund Completed',
              style: TextStyle(
                color: Color(0xFF333333),
                fontFamily: 'Seoge UI',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Rs.${widget.order.totalAmount}',
              style: const TextStyle(
                color: Color(0xFF00891D),
                fontFamily: 'Seoge UI',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
                    ],
                  ),
                ),
            
                const SizedBox(width: 10),
            
                /// RIGHT SIDE
              const  Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end, // align right nicely
                    children:[
            Text(
              'To UPI',
              style: TextStyle(
                fontFamily: 'Seoge UI',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333333),
              ),
            ),
            
            SizedBox(height: 4),
            
            /// IMPORTANT: Wrap long text
            Text(
              'EXPECTED BY : June 15th, 10:30 AM',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Seoge UI',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
               ),
               ],
             ),
             ),
              ],
               ),
                        const  SizedBox(height: 5),
                         const Divider(
                            color:Color(0xFFE5E5E5) ,
                          thickness: 0.5,
                          ),
            
                         const SizedBox(height:20),
            
                          
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                /// LEFT SIDE (DOT + LINE)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dot(),
                    _dottedLine(40),
                    _dot(),
                    _dottedLine(50),
                    _dot(),
                  ],
                ),
            
                const SizedBox(width: 12),
            
                /// RIGHT SIDE (TEXT)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            _twoTexts(
              'Canceled on',
              'June 15th, 10:30 AM',
            ),
            const SizedBox(height: 20),
            
            _twoTexts(
              'Your bank has processed your refund',
              'Completed on June 15th, 12:30 AM',
            ),
            const SizedBox(height: 20),
            
            _twoTexts(
              'Refund credited to your account',
              'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet sed diam nonummy nibh euismod tincidunt ut laoreet ',
            ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10,),
                const Divider(
                  height: 1,
                 thickness: 0.5,
                color: Color(0xFFE5E5E5),
                ),
            
                
            
                Row(
                  children: [
                   const Expanded(child: Text('Did you receive your refund')),
                    ToggleButtons(
            isSelected: _isSelected,
            onPressed: (int index){
              setState(() {
                for (int i = 0; i < _isSelected.length; i++) {
                  _isSelected[i] = i == index;
                }
              });
            },
            selectedBorderColor:const Color(0xFFEF5A06) ,
            selectedColor:const Color(0xFFFFFFFF),
                     borderRadius: BorderRadius.circular(8),
                     borderColor:const Color(0xFF000000),
                     constraints:const BoxConstraints(
            maxHeight: 18,
            minWidth: 40
                     ),
            
            children:const [
               Text('yes',style: TextStyle(
                fontFamily: 'Seoge UI',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFFEF5A06)
              ),),
            
               Text('No',style: TextStyle(
                fontFamily: 'Seoge UI',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFFEF5A06)
              ),),
            
            ],
                    )
                  ],
                ),
                
                         
                          
                        ],
                      ),
                    ),
                  ),
            
               const   SizedBox(height: 10,),
            
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
                                        'To Pay',
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
                ],
              ),
            ),
          ),
       
    );
  }

Widget _dot(){
  return Container(
    height:11,
    width: 11,
    decoration:const BoxDecoration(
      color: Color(0xFF00891D),
      shape: BoxShape.circle
    ),
  );
}

Widget _dottedLine(double height){
  return SizedBox(
    height: height,
    child:const DottedLine(
      direction: Axis.vertical,
      dashColor: Color(0xFFBEBEBE),
      dashGapLength: 3,
      dashLength: 3,
  ));
}

Widget _twoTexts(String text1,String text2){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text1,
      style:const TextStyle(
      fontFamily: 'Seogo UI',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: Colors.black 
      ),),

       Text(text2,
      style:const TextStyle(
      fontFamily: 'Seogo UI',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: Color(0xFF7C7C7C) 
      ),)


    ],
  );
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
  }}