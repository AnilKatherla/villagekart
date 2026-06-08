import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Small badge (e.g., "Top Seller", "New") used inside product cards.
/// Lightweight and customizable.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
  });
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.grey;
    final txt = textColor ?? Colors.deepOrange;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Up to ${label}',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: txt),
      ),
    );
  }
}
