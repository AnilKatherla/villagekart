/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {

  const AppLoader({
    super.key,
    this.size = 50.0,
    this.color,
    this.text,
  });
  final double size;
  final Color? color;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              color: color ?? theme.primaryColor,
              strokeWidth: 4.0,
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: 12),
            Text(
              text!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
