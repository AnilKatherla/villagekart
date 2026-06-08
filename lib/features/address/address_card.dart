/// **************************************************************
/// @author: Venkat Phanitapu
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: [Widget or ViewModel description]
/// **************************************************************
library;

import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/address/address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    address.address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  // Text(
                  //   '${address.distanceKm.toStringAsFixed(1)} km away',
                  //   style: const TextStyle(fontSize: 12, color: Colors.black54),
                  // ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionButton('Edit', onEdit),
                      _actionButton('Delete', onDelete),
                      _actionButton('Share', onShare),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
