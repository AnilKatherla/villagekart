import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/onboard/bloc/login_event.dart';
import 'package:villag_kart/features/onboard/bloc/login_service.dart';
import 'package:villag_kart/features/onboard/bloc/login_state.dart';

class ClearOtpStateEvent extends LoginEvent {}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<SendOtpEvent>(_handleSendOtpEvent);
    on<VerifyOtpEvent>(_handleVerifyOtpEvent);
    on<ResendOtpEvent>(_handleResendEvent);
    on<ClearOtpStateEvent>(_handleClearOtpState);
  }

  void _handleClearOtpState(
    ClearOtpStateEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitialState());
  }

  Future<void> _handleSendOtpEvent(
    SendOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(SendingOtpState());

    await LoginService.sendOtp(
      phoneNumber: event.phoneNumber,
      onSuccess: (String otp) {
        emit(OtpReceivedState(otp));
      },
      onError: (String error) {
        emit(OtpErrorState(error));
      },
    );
  }

  // VERIFY OTP HANDLER
  Future<void> _handleVerifyOtpEvent(
    VerifyOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(ValidatingOtpState());

    try {
      // Await the service call
      final authResponse = await LoginService.verifyOtp(
        phoneNumber: event.phoneNumber,
        otp: event.otpCode,
      );

      // Await saving to SharedPreferences
      await SharedPrefs.saveAuthResponse(authResponse);

      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        emit(ValidationSuccessState(authResponse));
      }
    } catch (e) {
      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        emit(ValidationFailedState(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  // RESEND OTP HANDLER
  Future<void> _handleResendEvent(
    ResendOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(SendingOtpState()); // Show loading

    await LoginService.resendOtp(
      phoneNumber: event.phoneNumber,
      onSuccess: (String otp) {
        emit(OtpReceivedState(otp)); // Success → stay on OTP screen
      },
      onError: (String error) {
        emit(OtpErrorState(error)); // Error → show error
      },
    );
  }
}
