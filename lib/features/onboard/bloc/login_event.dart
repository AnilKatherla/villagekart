abstract class LoginEvent {}

class SendOtpEvent extends LoginEvent {
  SendOtpEvent(this.phoneNumber);
  final String phoneNumber;
}

class ResendOtpEvent extends LoginEvent {
  ResendOtpEvent(this.phoneNumber);
  final String phoneNumber;
}

class VerifyOtpEvent extends LoginEvent {
  VerifyOtpEvent({required this.phoneNumber, required this.otpCode});

  final String phoneNumber;
  final String otpCode;
}