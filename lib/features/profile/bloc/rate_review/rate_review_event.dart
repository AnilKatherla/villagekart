


abstract class RatingEvent {}

class FetchProductRatings extends RatingEvent {
  final String productId;
  final int page;
  final int limit;

  FetchProductRatings({
    required this.productId,
    this.page = 1,
    this.limit = 20,
  });
}

class SubmitProductRating extends RatingEvent {
  final String productId;
  final double rating;
  final String review;
  final String status;

  SubmitProductRating({
    required this.productId,
    required this.rating,
    required this.review,
    required this.status
  });
}