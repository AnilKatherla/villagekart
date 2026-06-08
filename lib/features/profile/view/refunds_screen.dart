import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/app_typography.dart';
import 'package:villag_kart/core/theme/colors.dart';

class RefundsScreen extends StatelessWidget {
  const RefundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refunds = [
      {
        'orderId': 'Order#TYU27435',
        'status': 'Refund Completed',
        'amount': 'Rs.210',
        'store': 'Lagroce Kakathiya..',
        'address': '8-2-415, 1-5, Rd Number 4, Green Valley...',
        'paymentMethod': 'UPI',
        'date': 'June 15th, 10:30 Am'
      },
      {
        'orderId': 'Order#TYU27435',
        'status': 'Refund Completed',
        'amount': 'Rs.210',
        'store': 'Lagroce Kakathiya..',
        'address': '8-2-415, 1-5, Rd Number 4, Green Valley...',
        'paymentMethod': 'UPI',
        'date': 'June 15th, 10:30 Am'
      },
      {
        'orderId': 'Order#TYU27435',
        'status': 'Refund Completed',
        'amount': 'Rs.210',
        'store': 'Lagroce Kakathiya..',
        'address': '8-2-415, 1-5, Rd Number 4, Green Valley...',
        'paymentMethod': 'UPI',
        'date': 'June 15th, 10:30 Am'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(context),
        ),
        title: const Text("Refunds", style: AppTypography.heading),
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: refunds.length,
        itemBuilder: (context, index) {
          final refund = refunds[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Order Header ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      refund['orderId']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontSize: 15,
                      ),
                    ),
                    // ✅ Refund status (black) with Rs. below in green
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          refund['status']!,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          refund['amount']!,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ✅ Divider line after header
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: AppColors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                ),

                // ---------- Order Details ----------
                Text(
                  refund['store']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  refund['address']!,
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "To: ${refund['paymentMethod']}",
                  style: const TextStyle(color: AppColors.black),
                ),
                const SizedBox(height: 3),

                // ✅ "Completed On BY:" with bold date/time
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Completed On BY: ",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: refund['date']!,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "More info",
                    style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
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