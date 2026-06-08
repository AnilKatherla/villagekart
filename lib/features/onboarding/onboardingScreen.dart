import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Shop on Wheels',
      'subtitle': 'Shop directly from vehicle at your street',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'App Ordering',
      'subtitle': 'Order Groceries from your mobile App',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'WhatsApp Ordering',
      'subtitle': 'order via WhatsApp Easily',
      'image': 'assets/images/onboarding3.svg',
    },
    {
      'title': 'Assistant',
      'subtitle': 'Village Assistant Will Help You',
      'image': 'assets/images/onboarding4.svg',
    },
    {
      'title': 'Wholesale',
      'subtitle': 'Get Wholesale Prices in Your Village',
      'image': 'assets/images/onboarding5.svg',
    },
    {
      'title': 'Schedule',
      'subtitle': 'Vehicle Comes Every Alternate Day',
      'image': 'assets/images/onboarding6.svg',
    },
  ];

  @override
  void initState() {
    super.initState();

    _checkFirstTimerUser();

    // 🔁 Auto Slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < _pages.length - 1) {
        _currentIndex++;

        _controller.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        setState(() {});
      } else {
        timer.cancel(); // ✅ clean stop
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            // 🔹 Skip
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await SharedPrefs.setNotFirstTime();
                  if (context.mounted) {
                    context.goNamed('splash');
                  }
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: 9.h),
            SizedBox(
              height: 168.h,
              width: 168.w,
              child: SvgPicture.asset(
                'assets/images/villagekart_logo.svg',
                height: 168.h,
                width: 168.w,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 37.h),

            // 🔹 Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // _timer?.cancel();
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    index: index,
                    currentIndex: _currentIndex,
                  );
                },
              ),
            ),

            // 🔹 Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentIndex == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFFEF5A06)
                        : const Color(0xFFC1C1C1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Future<void> _checkFirstTimerUser() async {
    final bool isFirstTime = await SharedPrefs.isFirstTime();
    if (!isFirstTime) {
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.goNamed('splash');
        });
      }
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.currentIndex,
  });
  final Map<String, String> data;
  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    final fromRight = index % 2 == 0;

    return Column(
      children: [
        Text(
          data['title']!,
          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w600),
        ),

        SizedBox(height: 10.h),

        Text(data['subtitle']!, textAlign: TextAlign.center),

        SizedBox(height: 60.h),

        AnimatedSlide(
          offset: isActive ? Offset.zero : Offset(fromRight ? 1 : -1, 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: _buildImage(data['image']!, 240.h),
          ),
        ),
      ],
    );
  }
}

Widget _buildImage(String path, double height) {
  if (path.endsWith('.svg')) {
    return SvgPicture.asset(path, height: height);
  } else {
    return Image.asset(path, height: height, fit: BoxFit.contain);
  }
}
