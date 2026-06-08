import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    this.child,
    this.height = 52,
    this.width,
    this.borderRadius = 8,
    this.backgroundColor,
    this.isDisabled = false,
    this.isLoading = false,
    this.loader,
    this.label = 'Button',
    this.labelStyle,
    this.leadingIcon,
    this.trailingIcon,
  });
  final VoidCallback? onPressed;
  final Widget? child;
  final String label;
  final double height;
  final double? width;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isDisabled;
  final bool isLoading;
  final Widget? loader;
  final TextStyle? labelStyle;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        labelStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        );

    return Material(
      color: isDisabled
          ? Colors.grey.shade400
          : (backgroundColor ?? AppColors.primary),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: width ?? double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: isLoading
              ? (loader ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(label, style: style),
                      ],
                    ))
              : (child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: 8),
                        ],
                        Text(label, style: style),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon!,
                        ],
                      ],
                    )),
        ),
      ),
    );
  }
}
