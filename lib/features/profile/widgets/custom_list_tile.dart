import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/app_typography.dart';
import 'package:villag_kart/core/theme/colors.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor; // ✅ optional text color

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? AppColors.black,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.subHeading.copyWith(
                  fontSize: 15,
                  color: textColor ?? AppColors.black, // ✅ controlled by prop
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}