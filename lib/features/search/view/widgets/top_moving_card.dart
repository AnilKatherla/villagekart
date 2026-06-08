import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class TopMovingCard extends StatelessWidget {
  const TopMovingCard({
    super.key,
    required this.name,
    required this.bgColor,
    required this.icon,
    required this.imagePath,
  });

  final String name;
  final String imagePath;
  final Color bgColor;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 81,
      height: 91,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey, width: 2),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,

                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
