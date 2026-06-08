import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/navigation/app_router.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_bloc.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_event.dart';
import 'package:villag_kart/features/profile/bloc/edit_profile/edit_profile_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Permission request moved to service check screen
  // This ensures the native popup shows when service check screen loads

  @override
  void initState() {
    super.initState();
    _handleRedirection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listenWhen: (previous, current) =>
            current is UserProfileLoaded || current is UserProfileError,
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            // User exists and registered, navigate to home
            if (state.userProfile.name.isEmpty) {
              context.goNamed('register');
              return;
            }
            context.goNamed('serviceability');
          } else if (state is UserProfileError) {
            // If fetching profile fails (e.g., stale/expired token),
            // clear local storage and redirect to OTP screen
            SharedPrefs.clearAll().then((_) {
              if (context.mounted) {
                context.goNamed('otp');
              }
            });
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(child: _buildContent()),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    return SizedBox.expand(
      child: AspectRatio(
        aspectRatio: 286 / 581,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/splashImage.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.25, 0),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(0, 255, 255, 255), Color(0xFF000000)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const Spacer(),
        // // Logo
        // Image.asset(
        //   'assets/images/logo.png',
        //   width: 200.w,
        //   height: 200.h,
        //   errorBuilder: (context, error, stackTrace) {
        //     return Container(
        //       width: 141.sp,
        //       height: 111.sp,
        //       color: Colors.transparent,
        //       child: Icon(
        //         Icons.shopping_cart,
        //         color: Colors.white,
        //         size: 50.sp,
        //       ),
        //     );
        //   },
        // ),

        // SizedBox(height: 20.h),
        SvgPicture.asset(
          'assets/images/villagekart_logo.svg',
          width: 168.w,
          height: 168.h,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 141.sp,
              height: 111.sp,
              color: Colors.transparent,
              child: Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 50.sp,
              ),
            );
          },
        ),

        SizedBox(height: 37.h),

        Text(
          'Choose your\nWay to shop',
          style: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D1D1B),
          ),
        ),
        SizedBox(height: 36.h),

        SizedBox(
          height: 249.h,
          width: 299.w,
          child: SvgPicture.asset(
            'assets/images/splashimage.svg',
            fit: BoxFit.cover,
          ),
        ),

        // Get Started Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
          child: PrimaryButton(
            onPressed: _handleRedirection,
            label: 'Get Started',
          ),
        ),
      ],
    );
  }

  Future<void> _handleRedirection() async {
    // Check if access token and user ID exist
    final accessToken = await SharedPrefs.getAccessToken();
    final userId = await SharedPrefs.getUserId();

    // If both exist, skip authentication and go directly to location screen
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty) {
      if (context.mounted) {
        context.read<UserProfileBloc>().add(FetchUserProfile());
      }
    } else {
      // Otherwise, go to OTP/authentication flow
      if (context.mounted) {
        context.pushNamed('otp');
      }
    }
  }
}
