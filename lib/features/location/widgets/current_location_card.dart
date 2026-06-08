/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */

import 'package:flutter/material.dart';

class CurrentLocationCard extends StatelessWidget {

  const CurrentLocationCard({
    super.key,
    required this.location,
    required this.onChange,
  });
  final String location;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.my_location, color: Colors.green),
        title: const Text('Current location',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: TextButton(
          child: const Text('Change', style: TextStyle(color: Colors.green)), onPressed: () {
          },
        ),
        onTap: onChange,
      ),
    );
  }
}
