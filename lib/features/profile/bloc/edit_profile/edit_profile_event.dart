// ============================================================================
// USER PROFILE EVENTS (user_profile_events.dart)
// ============================================================================



abstract class UserProfileEvent {}

class FetchUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final String name;
  final String email;

  UpdateUserProfile({
    required this.name,
    required this.email,
  });
}

