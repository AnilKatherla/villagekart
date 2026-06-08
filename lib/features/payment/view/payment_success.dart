import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/order_status/order_status_cubit.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/view/order_history_screen.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String orderId;
  const PaymentSuccessPage({super.key,required this.orderId});

  @override
  Widget build(BuildContext context) {
    context.read<CartBloc>().add( ClearCartEvent());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/success.png', height: 180),

            const SizedBox(height: 20),

            const Text(
              'Congratulations!!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your order has been placed successfully.\nThank you for ordering.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 30),

            /// View Order Button
          PrimaryButton(
             onPressed: () {
                context.pushNamed('orderHistory');
              },
              label: 'View Order',

          ),

            const SizedBox(height: 16),

            /// Back to Home
            TextButton(
              onPressed: () {
                context.read<OrderStatusCubit>().setOrderPreparing('30 min');
                context.goNamed(
                  'home',
                  extra: {
                    'orderInfo': {
                      'orderId':orderId,
                      'message': 'Preparing your order',
                      'eta': '30min',
                    },
                  },
                );
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}