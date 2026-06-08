import 'package:flutter/material.dart';

class BillDetailsCard extends StatelessWidget {
  final double itemsTotal;
  final double promo;
  final double delivery;
  final double taxes;
  const BillDetailsCard({
    super.key,
    required this.itemsTotal,
    this.promo = 0,
    this.delivery = 0,
    this.taxes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = itemsTotal - promo + delivery + taxes;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row('Items', '₹ ${itemsTotal.toStringAsFixed(2)}'),
          if (promo > 0)
            _row('Promocode Applied', '₹ -${promo.toStringAsFixed(2)}'),
          if (delivery > 0)
            _row('Delivery', '₹ ${delivery.toStringAsFixed(2)}'),
          if (taxes > 0)
            _row('Taxes & Charges', '₹ ${taxes.toStringAsFixed(2)}'),
          const Divider(),
          _row('SUB TOTAL', '₹ ${subtotal.toStringAsFixed(2)}', bold: true),
        ],
      ),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
