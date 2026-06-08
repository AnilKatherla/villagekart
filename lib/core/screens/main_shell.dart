// lib/presentation/main_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/core/widgets/ripple_dot/ripple_effect.dart';
import 'package:villag_kart/features/shop/view/shop_screen.dart';

import '../../features/home/view/home_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/search/view/pages/search_screen.dart';
import '../widgets/bottombar/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    this.address,
    this.orderInfo,
    this.tabIndex, // Add optional tabIndex
  });

  final String? address;
  final Map<String, dynamic>? orderInfo;
  final int? tabIndex; // Optional index to force tab switch

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.tabIndex ?? 0;
    _screens = <Widget>[
      HomeScreen(address: widget.address),
      SearchScreen(onCancel: () => _onItemTapped(0)),
      ShopScreen(
        onStartShopping: () => _onItemTapped(1), // Example: navigate to search
      ),
      const ProfileScreen(),
    ];
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != null && widget.tabIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.tabIndex!;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// Expanded main content (tabs)
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),

          /// === ORDER STATUS BANNER ABOVE BOTTOM BAR ===
          if (widget.orderInfo != null)
            _OrderStatusBanner(data: widget.orderInfo!),
        ],
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _OrderStatusBanner extends StatelessWidget {
  const _OrderStatusBanner({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          const RippleDot(),
          const SizedBox(width: 14),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['message'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (data['eta'] != null)
                  Text(data['eta'], style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),

          // Track button - View order
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // 🔥 background color
              foregroundColor: Colors.white, // text/icon color
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            onPressed: () {
              final orderId = data['orderId'];

              if (orderId != null) {
                debugPrint(
                  '✅ Navigating to order tracking for orderId: $orderId',
                );
                context.pushNamed('orderHistory', extra: orderId);
              } else {
                debugPrint('❌ orderId missing');
              }
            },
            child: const Text(
              'View Order',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
