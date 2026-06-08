import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0XFF000000),
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
