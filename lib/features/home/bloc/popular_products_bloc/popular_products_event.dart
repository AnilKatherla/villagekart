abstract class PopularProductsEvent {}

class FetchPopularProducts extends PopularProductsEvent {
  final String pincode;
  final int page;
  final int limit;

  FetchPopularProducts({
    required this.pincode,
    this.page = 1,
    this.limit = 20,
  });
}

class RefreshPopularProducts extends PopularProductsEvent {
  final String pincode;
  final int limit;

  RefreshPopularProducts({
    required this.pincode,
    this.limit = 20,
  });
}

class LoadMorePopularProducts extends PopularProductsEvent {
  final String pincode;
  final int limit;

  LoadMorePopularProducts({
    required this.pincode,
    this.limit = 20,
  });
}