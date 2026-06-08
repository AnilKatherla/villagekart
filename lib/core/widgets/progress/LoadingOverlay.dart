/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/material.dart';
import 'package:villag_kart/core/widgets/progress/AppLoader.dart';


class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({super.key, required this.isLoading, required this.child});
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: AppLoader(text: 'Please wait...'),
            ),
          ),
      ],
    );
  }
}
