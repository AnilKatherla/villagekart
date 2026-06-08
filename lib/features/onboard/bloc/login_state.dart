import 'package:villag_kart/features/onboard/model/login_response_model.dart';

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class SendingOtpState extends LoginState {}

class OtpReceivedState extends LoginState {
  OtpReceivedState(this.otp);
  final String otp;
}

class OtpErrorState extends LoginState {
  OtpErrorState(this.error);
  final String error;
}


class ValidatingOtpState extends LoginState {}

class ValidationSuccessState extends LoginState {
  ValidationSuccessState(this.authResponse);
  final AuthResponseModel authResponse;
}

class ValidationFailedState extends LoginState {
  ValidationFailedState(this.error);
  final String error;
}
