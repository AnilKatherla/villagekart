// ============================================================================
// USER PROFILE STATES (user_profile_state.dart)
// ============================================================================


import '../../model/profile_model.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;

  UserProfileLoaded({required this.userProfile});
}

class UserProfileUpdating extends UserProfileState {
  final UserProfile userProfile;

  UserProfileUpdating({required this.userProfile});
}

class UserProfileSuccess extends UserProfileState {
  final UserProfile userProfile;
  final String message;

  UserProfileSuccess({
    required this.userProfile,
    required this.message,
  });
}

class UserProfileError extends UserProfileState {
  final String errorMessage;

  UserProfileError({required this.errorMessage});
}