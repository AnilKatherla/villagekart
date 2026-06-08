import 'package:villag_kart/features/profile/model/aboutus_model.dart';

abstract class AboutusState {}

class AboutusInitial extends AboutusState{}

class Aboutusloading extends AboutusState{}

class AboutusLoaded extends AboutusState{
  final AboutusModel about;

  AboutusLoaded(this.about);
}

class AboutusError extends AboutusState{
  final String message;

  AboutusError(this.message);
}