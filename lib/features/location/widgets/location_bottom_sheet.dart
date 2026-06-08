/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:villag_kart/core/theme/colors.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({
    super.key,
    required this.address,
    required this.pincode,
    required this.onConfirm,
    required this.onChangeLocation,
    required this.isServiceable,
    required this.isChecking,
  });

  final String address;
  final String pincode;
  final VoidCallback onConfirm;
  final VoidCallback onChangeLocation;
  final bool isServiceable;
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    String fullAddress = address;

    List<String> parts = fullAddress.split(',');
    String city;

    if (parts.length > 2) {
      city = parts[1].trim();
    } else {
      city = fullAddress;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your location to serve you',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Current location',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/location-tick 3.svg',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (pincode.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          address + '.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'SegoeUI',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // TextButton(
                //   onPressed: onChangeLocation,
                //   style: TextButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(horizontal: 8),
                //   ),
                //   child: const Text(
                //     'Change',
                //     style: TextStyle(
                //       color: AppColors.green,
                //       fontSize: 12,
                //
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 16),

            // Serviceability Status
            if (isChecking)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Checking serviceability...',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),

            if (!isChecking && !isServiceable)
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.red.shade50,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.error_outline,
              //         color: Colors.red.shade700,
              //         size: 20,
              //       ),
              //       const SizedBox(width: 8),
              //       const Expanded(
              //         child: Text(
              //           'Sorry, we don\'t deliver to this location yet',
              //           style: TextStyle(fontSize: 12, color: Colors.red),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              if (!isChecking && isServiceable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Great! We deliver to your location',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 16),

            // Confirm Button (enabled only if serviceable)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (isServiceable && !isChecking) ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: !isServiceable ? 2 : 0,
                ),
                child: Text(
                  'Confirm Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: !isServiceable ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
