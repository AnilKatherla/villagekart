import 'package:flutter/material.dart';

class OutOfStockBanner extends StatelessWidget {
  final String text;
  const OutOfStockBanner({super.key, this.text = '1 Item is Out of stock'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600))),
          Icon(Icons.expand_more, color: Colors.red.shade700),
        ],
      ),
    );
  }
}
