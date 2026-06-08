import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:villag_kart/core/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.pincode,
    this.showBackButton = false,
    this.location,
    this.onBackTap,
    this.onLocationTap,
    this.onCartTap,
    this.onSearchTap,
  });

  final String? title;
  final String? pincode;
  final bool showBackButton;
  final String? location;
  final VoidCallback? onBackTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onSearchTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  String _formatLocationText(String? fullLocation, String? pincode) {
    if (fullLocation == null || fullLocation.isEmpty) {
      return pincode ?? '';
    }

    if (pincode != null && pincode.isNotEmpty && !fullLocation.contains(pincode)) {
      return '$fullLocation - $pincode';
    }

    return fullLocation;
  }

  @override
  Widget build(BuildContext context) {
    // 🧠 Case 1: Simple “Back + Title” layout
    if (showBackButton) {
      return AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button + Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.black,
                    ),
                    onPressed: onBackTap ?? () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Search Icon
              if (onSearchTap != null)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 24),
                  onPressed: onSearchTap,
                ),
            ],
          ),
        ),
      );
    }

    // 🧠 Case 2: Default Green “Home + Location” layout
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.green,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onLocationTap,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Vector.svg',
                      width: 31,
                      height: 27,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? 'Location',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            _formatLocationText(location, pincode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
