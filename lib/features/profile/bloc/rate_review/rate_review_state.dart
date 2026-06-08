
import '../../model/rate_review_model.dart';

abstract class RatingState {}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingLoaded extends RatingState {
  final RatingsResponse ratingsResponse;
  RatingLoaded({required this.ratingsResponse});
}

class RatingError extends RatingState {
  final String errorMessage;
  RatingError({required this.errorMessage});
}

class RatingSubmitting extends RatingState {}

class RatingSubmitSuccess extends RatingState {
  final String message;
  RatingSubmitSuccess({required this.message});
}

class RatingSubmitError extends RatingState {
  final String errorMessage;
  RatingSubmitError({required this.errorMessage});
}
