import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';

class SavingsBanner extends StatelessWidget {
  
  const SavingsBanner({super.key });

  @override
  Widget build(BuildContext context) {
     final cartState = context.watch<CartBloc>().state;
     double savingAmount = cartState.totalSaved ?? 0.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green),
          const SizedBox(width: 8),
          Text('Saved ₹ ${savingAmount} on this order', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
