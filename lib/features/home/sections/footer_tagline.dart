import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';

class FooterTagline extends StatelessWidget {
  const FooterTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'With ',
                    style: TextStyle(
                      fontSize: 45,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  Image.asset(
                    'assets/icons/footerpageicon.png',
                    width: 43, // Increase this
                    height: 43,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
             const  Text(
                'for savings',
                style: TextStyle(
                  fontSize: 45,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
