import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138.h,
      width: double.infinity,
      child: SvgPicture.asset('assets/icons/offerbanner.svg'),
    );
  }
}
