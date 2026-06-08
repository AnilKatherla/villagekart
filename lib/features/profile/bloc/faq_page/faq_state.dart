
import 'package:villag_kart/features/profile/model/faq_model.dart';

abstract class DeliveryFaqState{}

class DeliveryFaqInitial extends DeliveryFaqState{}

class DeliveryFaqLoading extends DeliveryFaqState{}

class DeliveryFaqLoaded extends DeliveryFaqState{
  final List<DeliveryFaq> faqs;

  DeliveryFaqLoaded({required this.faqs});
}

class DeliveryFaqError extends DeliveryFaqState{
  final String message;
  DeliveryFaqError(this.message);
}