import 'package:flutter/material.dart';


class AppWrapper extends StatelessWidget {

  const AppWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: child,
    );
  }
}