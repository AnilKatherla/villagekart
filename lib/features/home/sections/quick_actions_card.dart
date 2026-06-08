import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF0D423F);

    return ClipPath(
      clipper: _ScallopedClipper(),
      child: Container(
        color: const Color(0xFFC5EAE8),
        padding:  EdgeInsets.only(top: 15.h, bottom: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          SizedBox(height: 15.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionItem(
                    imagepath: 'assets/icons/cuponaction_icon.svg',
                    label: 'Offers and\nPromos',
                    Tap: (){
                    context.push('/offersAndPromo');
                    }
                  ),
                  _buildActionItem(
                      imagepath: 'assets/icons/cartshare_Icon.svg',
                    label: 'Cart\nShare',
                    Tap: (){
                      context.push('/ShareCart');
                    }
                  ),
                  _buildActionItem(
                    imagepath: 'assets/icons/assistant.svg',
                    label: 'Assistant\nHelp',
                    Tap: (){
                       context.push('/AssistantHelp');
                    }
                  ),
                  _buildActionItem(
                     imagepath: 'assets/icons/weeklyspecial.svg',
                    label: 'Weekly\nSpecial',
                    Tap: (){
                       context.push('/weeklyMarket');
                    }
                  ),
                  _buildActionItem(
                   imagepath: 'assets/icons/todaysdeal.svg',
                    label: 'Today\nDeals',
                    Tap: (){
                       context.push('/dailyDeals');
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String imagepath,
    required String label,
    required VoidCallback Tap,
  }) {
    return Expanded(
      child: InkWell(
        onTap:Tap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54.w,
              height: 54.h,
              decoration: const BoxDecoration(
                color: Color(0xB2FFFFFF),
                shape: BoxShape.circle,
              ),
              child:SizedBox(
                height:34.h,
                width:34.w,
                child: SvgPicture.asset(imagepath,fit: BoxFit.scaleDown,)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style:const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D423F),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScallopedClipper extends CustomClipper<Path> {
  _ScallopedClipper({this.scallopSize = 12.0});
  final double scallopSize;

  @override
  Path getClip(Size size) {
    final path = Path();
    final int numScallops = (size.width / scallopSize).floor();
    final double remainingSpace = size.width - (numScallops * scallopSize);
    final double startX = remainingSpace / 2;

    // Top edge (left to right)
    path.moveTo(0, scallopSize);
    path.lineTo(startX, scallopSize);
    for (int i = 0; i < numScallops; i++) {
      final double x2 = startX + (i + 1) * scallopSize;
      path.arcToPoint(
        Offset(x2, scallopSize),
        radius: Radius.circular(scallopSize / 2),
        clockwise: true, // bulge upwards
      );
    }
    path.lineTo(size.width, scallopSize);

    // Right edge
    path.lineTo(size.width, size.height - scallopSize);

    // Bottom edge (right to left)
    path.lineTo(size.width - startX, size.height - scallopSize);
    for (int i = 0; i < numScallops; i++) {
      final double x2 = size.width - startX - (i + 1) * scallopSize;
      path.arcToPoint(
        Offset(x2, size.height - scallopSize),
        radius: Radius.circular(scallopSize / 2),
        clockwise: true, // bulge downwards
      );
    }

    // Left edge
    path.lineTo(0, size.height - scallopSize);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
