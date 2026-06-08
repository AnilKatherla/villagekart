abstract class RegisterEvent {}

/// Event to register a new user
class RegisterUserEvent extends RegisterEvent {
  RegisterUserEvent({required this.name, this.email, this.referralCode});

  final String name;
  final String? email;
  final String? referralCode;
}
