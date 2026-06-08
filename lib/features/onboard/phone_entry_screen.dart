/// **************************************************************
/// @author:
/// @date: 12 November 2025
/// @project: VillagKart
/// @description: Entry screen handling phone input & OTP input with proper keyboard behavior
/// **************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/navigation/route_names.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/onboard/bloc/login_bloc.dart';
import 'package:villag_kart/features/onboard/bloc/login_event.dart';
import 'package:villag_kart/features/onboard/bloc/login_state.dart';
import 'package:villag_kart/features/onboard/otp_entry_widget.dart';
import 'package:villag_kart/features/onboard/phone_entry_widget.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  String _phoneNumber = '';
  bool _isEditingPhone = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      // LISTENER: Handle all side effects
      listener: (context, state) {
        if (state is ValidationSuccessState) {
          // Navigate on success
          Future.microtask(() async {
            final isNewUser = await SharedPrefs.isNewUser();
            if (context.mounted) {
              if (isNewUser) {
                context.pushReplacementNamed(RouteNames.register);
              } else {
                context.pushReplacementNamed(RouteNames.serviceability);
              }
            }
          });
        } else if (state is OtpErrorState) {
          // Show send OTP error
          _showError(context, state.error);
          if (state.error.contains('wait') && _isEditingPhone) {
            _showRateLimitError(context, state.error);
          }
        }
      },

      // BUILDER: UI updates only - FIXED to handle all OTP-related states
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStaticContent(context),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            state is ValidationSuccessState
                                ? _buildLoadingIndicator()
                                : _shouldShowOtpScreen(state)
                                    ? _buildOtpEntryWidget()
                                    : _buildPhoneEntryWidget(),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper method to determine when to show OTP screen
  bool _shouldShowOtpScreen(LoginState state) {
    return state is OtpReceivedState ||
        state is ValidatingOtpState ||
        state is ValidationFailedState;
    // Note: ValidationSuccessState is excluded - navigation happens immediately
  }

  void _showRateLimitError(BuildContext context, String message) {
    final regex = RegExp(r'wait\s+(\d+)\s+seconds');
    final match = regex.firstMatch(message);
    final waitTime = match?.group(1) ?? '114';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Requests'),
        content: Text(
          'You need to wait $waitTime seconds before requesting a new OTP with the same number.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method for showing errors
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // STATIC HEADER - Responsive to keyboard
  // Widget _buildStaticContent(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

  //   return Column(
  //     children: [
  //       SizedBox(height: keyboardVisible ? 25 : 25),

  //       // Hide or shrink image when keyboard is visible
  //       // if (!keyboardVisible) ...[
  //         SizedBox(height: 80.h),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 24),
  //           child: SvgPicture.asset('assets/images/villagekart_logo.svg',height:168.h,width:168.w),
  //         ),
  //          SizedBox(height: 0.h),
  //     //   ] else ...[
  //     //     const SizedBox(height: 16),
  //     //   ],
  //     // ]
  //     ]
  //   );
  // }

  // STATIC HEADER - Responsive to keyboard
  Widget _buildStaticContent(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        SizedBox(height: keyboardVisible ? 16 : 25),
        Text(
          'Fill your kitchen needs',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            text: 'from your ',
            style: TextStyle(fontSize: 25, color: Colors.black),
            children: [
              TextSpan(
                text: 'favourite store',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ),
        // Hide or shrink image when keyboard is visible
        if (!keyboardVisible) ...[
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SvgPicture.asset('assets/images/onboarding.svg'),
          ),
          const SizedBox(height: 20),
        ] else ...[
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // OTP ENTRY WIDGET
  Widget _buildOtpEntryWidget() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final receivedOtp = (state is OtpReceivedState) ? state.otp : '';

        return OtpEntryWidget(
          key: const ValueKey('otp-entry'),
          phoneNumber: _phoneNumber,
          receivedOtp: receivedOtp,
          onBack: () {
            FocusScope.of(context).unfocus(); // close keyboard

            Future.delayed(const Duration(milliseconds: 120), () {
              if (!mounted) return;

              setState(() {
                _isEditingPhone = true;
              });

              context.read<LoginBloc>().add(ClearOtpStateEvent());
            });
          },
          onVerify: (otp) {
            debugPrint('Verifying OTP: $otp');
            context.read<LoginBloc>().add(
              VerifyOtpEvent(phoneNumber: _phoneNumber, otpCode: otp),
            );
          },
        );
      },
    );
  }

  // LOADING INDICATOR (shown during navigation after successful validation)
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(48.0),
      child: Center(child: CircularProgressIndicator(color: AppColors.green)),
    );
  }

  // PHONE ENTRY WIDGET
  Widget _buildPhoneEntryWidget() {
    return PhoneEntryWidget(
      key: const ValueKey('phone'),
      initialPhone: _phoneNumber,
      isEditing: _isEditingPhone,
      onSendOtp: (phone) {
        setState(() {
          _phoneNumber = phone;
          _isEditingPhone = false;
        });
      },
    );
  }
}
