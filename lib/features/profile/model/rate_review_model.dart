class RatingsResponse {
  final bool status;
  final String response;
  final RatingsData data;

  RatingsResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory RatingsResponse.fromJson(Map<String, dynamic> json) {
    return RatingsResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: RatingsData.fromJson(json['data'] ?? {}),
    );
  }
}

class RatingsData {
  final List<ProductRating> ratings;
  final PaginationInfo pagination;

  RatingsData({
    required this.ratings,
    required this.pagination,
  });

  factory RatingsData.fromJson(Map<String, dynamic> json) {
    return RatingsData(
      ratings: (json['ratings'] as List?)
              ?.map((e) => ProductRating.fromJson(e))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class ProductRating {
  final String id;
  final String userId;
  final String productId;
  final double rating;
  final String review;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductRating({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.review,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class SubmitRatingResponse {
  final bool status;
  final String response;
  final ProductRating? data;

  SubmitRatingResponse({
    required this.status,
    required this.response,
    this.data,
  });

  factory SubmitRatingResponse.fromJson(Map<String, dynamic> json) {
    return SubmitRatingResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: json['data'] != null ? ProductRating.fromJson(json['data']) : null,
    );
  }
}