import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_event.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_service.dart';
import 'package:villag_kart/features/profile/bloc/faq_page/faq_state.dart';


class DeliveryFaqBloc extends Bloc<DeliveryFaqEvent, DeliveryFaqState> {
  final DeliveryFaqApiService apiService;

  DeliveryFaqBloc(this.apiService) : super(DeliveryFaqInitial()) {
    on<FetchDeliveryFaqs>(_onFetchDeliveryFaqs);
  }

  Future<void> _onFetchDeliveryFaqs(
    FetchDeliveryFaqs event,
    Emitter<DeliveryFaqState> emit,
  ) async {
    emit(DeliveryFaqLoading());

    try {
      final faqs = await apiService.fetchDeliveryFaqs();

      emit(DeliveryFaqLoaded(faqs:faqs));
    } catch (e) {
      emit(DeliveryFaqError(e.toString()));
    }
  }
}