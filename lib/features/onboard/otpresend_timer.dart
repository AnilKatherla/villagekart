/**
 * **************************************************************
 * @author: Venkat Phanitapu
 * @date: 12 November 2025
 * @project: VillagKart
 * @description: [Widget or ViewModel description]
 * **************************************************************
 */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:villag_kart/core/theme/colors.dart';

class OtpResendTimer extends StatefulWidget {
  const OtpResendTimer({super.key, required this.onResend});
  final VoidCallback onResend;

  @override
  State<OtpResendTimer> createState() => _OtpResendTimerState();
}

class _OtpResendTimerState extends State<OtpResendTimer> {
  Timer? _timer; // Changed from 'late' to nullable to avoid the error
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Safely cancel the timer if it exists.
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer before starting a new one.
    _remainingSeconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        // Check if the widget is still mounted before calling setState.
        // This prevents the "setState() called after dispose()" error.
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      } else {
        timer.cancel();
        // Also check if mounted for the final state update.
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void _onResendPressed() {
    if (_remainingSeconds == 0) {
      widget.onResend(); // Trigger callback
      _startTimer();    // Restart countdown, which also handles setState.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canResend = _remainingSeconds == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: canResend ? _onResendPressed : null, // disabled while counting
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: 6.w),
            foregroundColor:
            canResend ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
          child: Text(
            canResend
                ? 'Resend OTP'
                : 'Resend: ${_remainingSeconds.toString().padLeft(2, '0')}S',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: canResend ? AppColors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}