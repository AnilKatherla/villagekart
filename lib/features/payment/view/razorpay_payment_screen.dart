import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:villag_kart/environmental_variables.dart';

import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_event.dart';
import 'package:villag_kart/features/payment/bloc/payment_bloc.dart';
import 'package:villag_kart/features/payment/bloc/paymentevent.dart';
import 'package:villag_kart/features/payment/bloc/paymentstate.dart';
import 'package:villag_kart/features/payment/view/payment_options.dart'
    hide PaymentState;

class RazorpayPaymentScreen extends StatefulWidget {
  const RazorpayPaymentScreen({
    super.key,
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
  });

  final String orderId;
  final String razorpayOrderId;
  final double amount;

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    // Auto-open Razorpay after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openRazorpayCheckout();
    });
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openRazorpayCheckout() {
    final options = {
      'key': EnvironmentalVariables.razorpayKey,
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'VillagKart',
      'order_id': widget.razorpayOrderId,
      'description': 'Order Payment',
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#2C9E19'},
      'retry': {'enabled': false},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      _showErrorDialog('Failed to open payment gateway');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');

    setState(() {
      _isProcessing = true;
    });

    context.read<PaymentBloc>().add(
      VerifyPaymentEvent(
        orderId: widget.orderId,
        razorpaypaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    _razorpay.clear();

    if (!mounted) return;

    context.pushReplacement('/failure');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    _showErrorDialog('External wallet not supported');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/failure');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccessState) {
          // Payment successful, clear cart and navigate to success screen
          //context.read<CartBloc>().add(const ClearCartEvent());
          context.go('/success', extra: widget.orderId);
        } else if (state is PaymentErrorState) {
          // Failed to update transaction status
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Processing Payment',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(color: Color(0xFFFC6022)),
                const SizedBox(height: 24),
                const Text(
                  'Verifying payment...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ] else ...[
                const Icon(Icons.payment, size: 80, color: Color(0xFFFC6022)),
                const SizedBox(height: 24),
                const Text(
                  'Processing your payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Please complete the payment in the Razorpay window',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel Payment'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
