abstract class RegisterState {}

/// Initial state
class RegisterInitialState extends RegisterState {}

/// Loading state (during API call)
class RegisteringState extends RegisterState {}

/// Success state
class RegisterSuccessState extends RegisterState {
  RegisterSuccessState({
    required this.userId,
    required this.token,
    this.message,
  });

  final String userId;
  final String token;
  final String? message;
}

/// Error state
class RegisterErrorState extends RegisterState {
  RegisterErrorState(this.error);
  
  final String error;
}
