import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Small square/circular icon button used across product cards.
/// Keeps consistent sizes, paddings and hit targets for accessibility.
class AppIconButton extends StatelessWidget {

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 20,
    this.color,
    this.background,
    this.padding = const EdgeInsets.all(6),
    this.shape = BoxShape.circle, required Color borderColor,
  });
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final Color? background;
  final EdgeInsets padding;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.transparent;
    final iconColor = color ?? AppColors.green;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape == BoxShape.circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: bg, shape: shape),
          child: Icon(icon, size: size, color: iconColor),
        ),
      ),
    );
  }
}
