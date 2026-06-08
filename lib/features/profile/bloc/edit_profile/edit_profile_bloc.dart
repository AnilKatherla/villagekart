// ============================================================================
// USER PROFILE BLOC (user_profile_bloc.dart)
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_profile_event.dart';
import 'edit_profile_service.dart';
import 'edit_profile_state.dart';


class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  /// Fetch user profile
  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    try {
      final profileResponse =
          await UserProfileService.fetchUserProfile();

      emit(UserProfileLoaded(userProfile: profileResponse.data));
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }

  /// Update user profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating(userProfile: currentState.userProfile));

      try {
        // Validate inputs
        if (event.name.isEmpty) {
          throw Exception('Name cannot be empty');
        }
        if (event.email.isEmpty) {
          throw Exception('Email cannot be empty');
        }
        if (!_isValidEmail(event.email)) {
          throw Exception('Please enter a valid email');
        }

        final updateResponse =
            await UserProfileService.updateUserProfile(
          name: event.name,
          email: event.email,
        );

        emit(UserProfileSuccess(
          userProfile: updateResponse.data,
          message: 'Profile updated successfully',
        ));

        // Emit loaded state after showing success
        Future.delayed(const Duration(milliseconds: 500), () {
          emit(UserProfileLoaded(userProfile: updateResponse.data));
        });
      } catch (e) {
        emit(UserProfileError(errorMessage: e.toString()));
        // Revert to previous state on error
        emit(UserProfileLoaded(userProfile: currentState.userProfile));
      }
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}