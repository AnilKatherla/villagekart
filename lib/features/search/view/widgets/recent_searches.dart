import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'chip.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    this.searchValue,
    required this.searches,
    required this.onSearchTap,
    this.onClear,
  });

  final String? searchValue;
  final List<String> searches;
  final Function(String query) onSearchTap;
  final VoidCallback? onClear;

  final List<String> _chips = const [
    'Detergents',
    'Tomato',
    'Banana',
    'Banana',
    'Flours',
    'Oils',
    'Rice',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent searches',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: searches.map((label) => AppChip(
            label: label,
            backgroundColor: AppColors.white,
            onTap: () => onSearchTap(label),
          )).toList(),
        ),
      ],
    );
  }
}