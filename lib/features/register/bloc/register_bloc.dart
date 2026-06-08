import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/register/bloc/register_event.dart';
import 'package:villag_kart/features/register/bloc/register_service.dart';
import 'package:villag_kart/features/register/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitialState()) {
    on<RegisterUserEvent>(_handleRegisterUserEvent);
  }

  /// Handle user registration
  Future<void> _handleRegisterUserEvent(
  RegisterUserEvent event,
  Emitter<RegisterState> emit,
) async {
  emit(RegisteringState());

  try {
    await RegisterService.registerUser(
      name: event.name,
      email: event.email,
      referralCode: event.referralCode,
      onSuccess: (Map<String, dynamic> data) {
        emit(RegisterSuccessState(
          userId: data['userId']?.toString() ?? '',
          token: data['token']?.toString() ?? '',
          message: data['message']?.toString(),
        ));
      },
      onError: (String error) {
        emit(RegisterErrorState(error));
      },
    );
  } catch (e) {
    // 🔐 Safety net (VERY IMPORTANT)
    emit(
      RegisterErrorState(
        e.toString().replaceAll('Exception:', '').trim(),
      ),
    );
  }
}

}