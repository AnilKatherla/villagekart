class Endpoints {
  //Authentication
  static const String sendOtp = 'user/send-otp';
  static const String verifyOtp = 'user/verify-otp';
  static const String resendOtp = 'user/resend-otp';

  //profile
  static const String profile = 'user/me';
  static const String updateProfile = 'user/update-profile';

  //Location checks
  static const String checkServiceAvailability = 'serviceability';

  static String isServiceAvailable({
    required String pinCode,
    required String latitude,
    required String longitude,
    required String userId,
  }) =>
      'serviceability?pincode=$pinCode&latitude=$latitude&longitude=$longitude&userId=$userId';

  static String getCart({String? warehouseId}) =>
      warehouseId != null ? 'cart?warehouseId=$warehouseId' : 'cart';

  // DELETE /api/v1/cart?warehouseId=... (clear cart)
  static String clearCart({String? warehouseId}) =>
      warehouseId != null ? 'cart?warehouseId=$warehouseId' : 'cart';

  // POST /api/v1/cart/items
  static const String addToCartItem = 'cart/items';

  // PATCH /api/v1/cart/items/{cartItemId}
  static String updateCartItem(String cartItemId) => 'cart/items/$cartItemId';

  // DELETE /api/v1/cart/items/{cartItemId}
  static String removeCartItem(String cartItemId) => 'cart/items/$cartItemId';
  //paymentMode
  static const String initiatePayment = 'payments/initiate';
  //verify
  static const String verifyPayment = 'payments/verify';
  //Categories
  static String categories({required String pinCode}) =>
      'categories?pincode=$pinCode';

  static String subCategories({
    required String categoryId,
    required String pinCode,
    required String latitude,
    required String longitude,
    required String userId,
  }) =>
      'subcategories?categoryId=$categoryId&pincode=$pinCode&latitude=$latitude&longitude=$longitude&userId=$userId';

  //Products
  static String productsByCategory({
    required String categoryId,
    required String pinCode,
    required String latitude,
    required String longitude,
    required String userId,
    int page = 1,
    int limit = 20,
    bool inStock = true,
    bool isFeatured = false,
    String sortBy = 'price',
    String sortOrder = 'asc',
  }) =>
      'products/category/:$categoryId?pincode=$pinCode&latitude=$latitude&longitude=$longitude&page=$page&limit=$limit&search=&minPrice=&maxPrice=&brand=&inStock=$inStock&isFeatured=$isFeatured&sortBy=$sortBy&sortOrder=$sortOrder';

  //Products by sub category
  static String productsBySubCategory({
    required String subCategoryId,
    required String pinCode,
    required String latitude,
    required String longitude,
    required String userId,
    int page = 1,
    int limit = 20,
    bool inStock = true,
    bool isFeatured = false,
    String sortBy = 'price',
    String sortOrder = 'asc',
  }) =>
      'products/subcategory/:$subCategoryId?pincode=$pinCode&latitude=$latitude&longitude=$longitude&page=$page&limit=$limit&search=&minPrice=&maxPrice=&brand=&inStock=$inStock&isFeatured=$isFeatured&sortBy=$sortBy&sortOrder=$sortOrder';

  //Products offers
  static String productsOffers({
    required String pinCode,
    int page = 1,
    int limit = 20,
  }) => 'products/offers?pincode=$pinCode&page=$page&limit=$limit';

  //Coupons
  static String coupons({
    required String pinCode,
    required String userId,
    required String cartValue,
  }) => 'coupons?userId=$userId&pincode=$pinCode&cartValue=$cartValue';

  //App

  static String introScreens = 'app/intro-screens';

  static String healthCheck = 'check';

  // Delivery

  static String getDeliveryTypes(String warehouseId) =>
      'delivery/types?warehouseId=$warehouseId';

  // POST /api/v1/orders
  static const String createOrder = 'orders';

  // static String getDeliverySlots({
  //   required String warehouseId,
  //   required String date, // yyyy-MM-dd
  // }) =>
  //     'delivery/slots?warehouseId=$warehouseId&date=$date';

  static String getPickupSlots({required String warehouseId}) {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return 'delivery/stores/$warehouseId/pickup-slots?date=$formattedDate';
  }

  static String getDeliverySlots({
    required String warehouseId,
    required String deliveryDate,
  }) => 'delivery/slots?warehouseId=$warehouseId&date=$deliveryDate';

  static String reorder(String orderId) => 'orders/$orderId/reorder';

  static const deliveryFaq = 'deliveryrelque';
}
