import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DailyDeals extends StatelessWidget {
  const DailyDeals({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0.5,
                      automaticallyImplyLeading: false,
                      titleSpacing: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.pop(),
                      ),
                      title: const Text(
                        'Today Deals',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),),
      body: Center(child: Text('Coming soon')),
    );
  }
}