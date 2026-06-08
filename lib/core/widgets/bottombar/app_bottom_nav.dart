import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  Widget navIcon({
    required String asset,
    required bool selected,
    Widget? child,
    bool applyTint = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.green
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child ??
          SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: applyTint
                ? ColorFilter.mode(
                    selected
                        ? Colors.white
                        : Colors.black,
                    BlendMode.srcIn,
                  )
                : null,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      elevation: 8,

      items: [
        /// HOME (icon swap, no tint)
        BottomNavigationBarItem(
          icon: navIcon(
            asset: currentIndex == 0
                ? 'assets/icons/homeIcon.svg'
                : 'assets/icons/home_icon.svg',
            selected: currentIndex == 0,
            applyTint: false,
          ),
          label: 'Home',
        ),

        /// SEARCH
        BottomNavigationBarItem(
          icon: navIcon(
            asset: 'assets/icons/search svg.svg',
            selected: currentIndex == 1,
          ),
          label: 'Search',
        ),

        /// CART
        BottomNavigationBarItem(
          icon: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final count = state is CartLoadedState
                  ? state.cartItems.length
                  : 0;

              return navIcon(
                asset: '',
                selected: currentIndex == 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/cart icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 2
                            ? Colors.white
                            : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),

                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          label: 'Cart',
        ),

        /// PROFILE
        BottomNavigationBarItem(
          icon: navIcon(
            asset: 'assets/icons/profile icon.svg',
            selected: currentIndex == 3,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}