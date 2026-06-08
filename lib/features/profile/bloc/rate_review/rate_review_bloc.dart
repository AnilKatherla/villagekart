import 'package:villag_kart/features/profile/bloc/rate_review/rate_review_state.dart' show RatingState, RatingInitial, RatingLoading, RatingLoaded, RatingError, RatingSubmitting, RatingSubmitSuccess, RatingSubmitError;

import 'rate_review_event.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'rate_review_service.dart';


class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc() : super(RatingInitial()) {
    on<FetchProductRatings>(_onFetchProductRatings);
    on<SubmitProductRating>(_onSubmitProductRating);
  }

  Future<void> _onFetchProductRatings(
    FetchProductRatings event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    try {
      final response = await RatingService.fetchProductRatings(
        productId: event.productId,
        page: event.page,
        limit: event.limit,
      );
      emit(RatingLoaded(ratingsResponse: response));
    } catch (e) {
      emit(RatingError(errorMessage: e.toString()));
    }
  }

Future<void> _onSubmitProductRating(
  SubmitProductRating event,
  Emitter<RatingState> emit,
) async {
  emit(RatingSubmitting());

  try {
    final response = await RatingService.submitProductRatings(
      productId: event.productId,
      rating: event.rating,
      review: event.review,
     status : event.status
    );

    emit(RatingSubmitSuccess(message: response.response));

    // Re-fetch ratings
    final updatedRatings = await RatingService.fetchProductRatings(
      productId: event.productId,
      page: 1,
      limit: 20,
    );

    emit(RatingLoaded(ratingsResponse: updatedRatings));
  } catch (e) {
    emit(RatingSubmitError(errorMessage: e.toString()));
  }
}
}