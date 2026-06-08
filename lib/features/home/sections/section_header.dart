import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';

class SectionHeader extends StatelessWidget {

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
