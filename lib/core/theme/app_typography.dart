import 'package:flutter/material.dart';
import 'package:villag_kart/core/theme/colors.dart';

class AppTypography {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
