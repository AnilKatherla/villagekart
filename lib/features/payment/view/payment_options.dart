// payment_options_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/progress/LoadingOverlay.dart';
import 'package:villag_kart/features/payment/Service/payment_api_service.dart';

/// Example production-style Payment Options Page
/// - Uses a simple PaymentCubit to manage selection & state
/// - Replace mocked handlers (showDialog / Navigator) with real SDK calls

enum PaymentMethodType {
  googlePay,
  upiApp,
  card,
  upi,
  wallet,
  netBanking,
  cod,
  RAZORPAY_UPI,
}

class PaymentSelection {
  // optional saved id (card id / upi id etc)

  PaymentSelection({required this.type, this.id});
  final PaymentMethodType type;
  final String? id;
}

class PaymentState {
  PaymentState({this.selected, this.processing = false, this.message});
  final PaymentSelection? selected;
  final bool processing;
  final String? message;

  PaymentState copyWith({
    PaymentSelection? selected,
    bool? processing,
    String? message,
  }) {
    return PaymentState(
      selected: selected ?? this.selected,
      processing: processing ?? this.processing,
      message: message,
    );
  }
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentState());

  void select(PaymentSelection sel) => emit(state.copyWith(selected: sel));

  Future<void> startPayment(double amount) async {
    final sel = state.selected;
    if (sel == null) {
      emit(state.copyWith(message: 'Please select a payment method'));
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(state.copyWith());
      return;
    }

    emit(state.copyWith(processing: true));

    // MOCK flows: In production call SDKs or backend.
    await Future.delayed(const Duration(milliseconds: 700));

    switch (sel.type) {
      case PaymentMethodType.googlePay:
      case PaymentMethodType.RAZORPAY_UPI:
      case PaymentMethodType.upiApp:
        // Mock UPI flow
        await Future.delayed(const Duration(seconds: 1));
        emit(
          state.copyWith(processing: false, message: 'UPI payment succeeded'),
        );
        break;
      case PaymentMethodType.card:
        // Mock card processing
        await Future.delayed(const Duration(seconds: 2));
        emit(
          state.copyWith(processing: false, message: 'Card payment succeeded'),
        );
        break;
      case PaymentMethodType.upi:
      case PaymentMethodType.wallet:
      case PaymentMethodType.netBanking:
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(processing: false, message: 'Payment succeeded'));
        break;
      case PaymentMethodType.cod:
        emit(
          state.copyWith(
            processing: false,
            message: 'Order placed with Cash on Delivery',
          ),
        );
        break;
    }

    // optionally clear message after 2s
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith());
  }
}

// ---------- UI Page ----------
class PaymentOptionsPage extends StatelessWidget {
  const PaymentOptionsPage({
    super.key,
    required this.amount,
    required this.orderId,
  });

  final double amount;
  final String orderId;

  // Mock saved data (in production fetch from server or secure storage)
  // static final savedCards = [
  //   {'id': 'card_1', 'label': 'Visa •••• 3452', 'holder': 'David Smith'},
  // ];
  // static final savedUPIs = [
  //   {'id': 'upi_1', 'label': 'paytm@upi'},
  // ];
  // static final wallets = [
  //   {'id': 'wallet_paytm', 'label': 'Paytm'},
  //   {'id': 'wallet_mobikwik', 'label': 'MobiKwik'},
  //   {'id': 'wallet_freecharge', 'label': 'Freecharge'},
  // ];
  // static final banks = [
  //   {'id': 'bank_1', 'label': 'HDFC Bank'},
  //   {'id': 'bank_2', 'label': 'ICICI Bank'},
  //   {'id': 'bank_3', 'label': 'State Bank of India'},
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Options',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Pay through'),
                    const SizedBox(height: 8),

                    PaymentListTile(
                      title: 'Razorpay',
                      subtitle: '',
                      leading: Image.asset(
                        'assets/icons/razorpay.png',
                        width: 48,
                        height: 32,
                      ),
                      onTap: () => context.read<PaymentCubit>().select(
                        PaymentSelection(
                          type: PaymentMethodType
                              .RAZORPAY_UPI, // or your razorpay type
                          id: 'razorpay',
                        ),
                      ),
                      selectedChecker: (state) =>
                          state.selected?.id == 'razorpay',
                    ),

                    const SizedBox(height: 24),

                    // Cash on delivery
                    const SectionTitle('Pay On Delivery'),
                    const SizedBox(height: 8),
                    PaymentListTile(
                      title: 'Cash On Delivery',
                      subtitle: 'Pay with cash',
                      leading: const Icon(Icons.money, color: Colors.brown),
                      onTap: () => context.read<PaymentCubit>().select(
                        PaymentSelection(type: PaymentMethodType.cod),
                      ),
                      selectedChecker: (state) =>
                          state.selected?.type == PaymentMethodType.cod,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // bottom bar
            BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'To Pay',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rs.${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: (state.processing || state.selected == null)
                            ? null
                            : () async {
                                final cubit = context.read<PaymentCubit>();
                                final selected = cubit.state.selected;

                                if (selected == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select payment method',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // =========================
                                // RAZORPAY PAYMENT
                                // =========================
                                if (selected.type ==
                                    PaymentMethodType.RAZORPAY_UPI) {
                                  try {
                                    final response = await PaymentApiService()
                                        .initiateRazorpayPayment(orderId);

                                    final razorpayOrderId =
                                        response['razorpayOrderId'];
                                    final amount = response['amount'];

                                    if (context.mounted) {
                                      context.push(
                                        '/razorpay',
                                        extra: {
                                          'orderId': orderId,
                                          'razorpayOrderId': razorpayOrderId,
                                          'amount': amount,
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) context.go('/failure');
                                  }
                                  return;
                                }

                                // =========================
                                // COD PAYMENT
                                // =========================
                                if (selected.type == PaymentMethodType.cod) {
                                  try {
                                    await PaymentApiService().createCODPayment(
                                      orderId,
                                    );

                                    if (context.mounted) context.go('/success',extra: orderId);
                                  } catch (e) {
                                    if (context.mounted) context.go('/failure');
                                  }
                                  return;
                                }

                                // =========================
                                // OTHER PAYMENTS
                                // =========================
                                await cubit.startPayment(amount);

                                final updatedState = cubit.state;
                                if (updatedState.message != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(updatedState.message!),
                                    ),
                                  );
                                }
                              },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state.processing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper to open add card form (mock)
  // void _openAddCard(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Add Card (mock)',
  //               style: TextStyle(fontWeight: FontWeight.w700),
  //             ),
  //             const SizedBox(height: 12),
  //             const TextField(
  //               decoration: InputDecoration(labelText: 'Card number'),
  //             ),
  //             const SizedBox(height: 8),
  //             ElevatedButton(
  //               onPressed: () => context.pop(context),
  //               child: const Text('Save'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // // Helper to open add UPI (mock)
  // void _openAddUpi(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Add UPI id (mock)',
  //               style: TextStyle(fontWeight: FontWeight.w700),
  //             ),
  //             const SizedBox(height: 12),
  //             const TextField(
  //               decoration: InputDecoration(
  //                 labelText: 'UPI id (example: your@upi)',
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             ElevatedButton(
  //               onPressed: () => context.pop(context),
  //               child: const Text('Save'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // static Widget _buildImagePlaceholder(String label) {
  //   return Container(
  //     width: 48,
  //     height: 32,
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade200,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Center(
  //       child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  //     ),
  //   );
  // }
}

/// Small reusable widgets below (you can move to separate files in production)
class PreferredCardRow extends StatelessWidget {
  const PreferredCardRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.onTap,
    required this.selectedChecker,
    this.showRadio = false,
  });
  final String title;
  final String subtitle;
  final String badge;
  final Widget icon;
  final VoidCallback onTap;
  final bool showRadio;
  final bool Function(PaymentState) selectedChecker;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final selected = selectedChecker(state);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.black : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (badge.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (showRadio)
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? Colors.green : Colors.grey,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }
}

class PaymentListTile extends StatelessWidget {
  const PaymentListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    required this.onTap,
    this.trailingAction,
    required this.selectedChecker,
  });
  final String title;
  final String subtitle;
  final Widget? leading;
  final VoidCallback onTap;
  final void Function()? trailingAction;
  final bool Function(PaymentState) selectedChecker;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final selected = selectedChecker(state);
        return InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (leading != null) leading!,
                if (leading != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailingAction != null)
                  IconButton(
                    onPressed: trailingAction,
                    icon: const Icon(Icons.more_vert),
                  ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
