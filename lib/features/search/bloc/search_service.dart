import 'package:villag_kart/features/home/bloc/category_bloc/category_service.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/products_service.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class SearchRepository {
  SearchRepository({
    required PopularProductsService popularProductsService,
    required CategoryService categoryService,
  }) : _popularProductsService = popularProductsService,
       _categoryService = categoryService;
  final PopularProductsService _popularProductsService;
  final CategoryService _categoryService;

  /// Fetch top moving products
  Future<List<Product>> getTopMovingProducts({
    required String pincode,
    int limit = 10,
  }) async {
    try {
      final response = await PopularProductsService.fetchPopularProducts(
        pincode: pincode,
        limit: limit,
      );

      // FIX 2: Access products through .data.products
      final products = response.data.products ?? [];

      return products;
    } catch (e) {
      throw Exception('Failed to fetch top moving products: $e');
    }
  }

  /// Fetch browse groups/categories
  Future<List<CategoryModel>> getBrowseGroups({
    required String pincode,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      final response = await CategoryService.fetchCategories(
        pincode: pincode,
        // latitude: latitude,
        // longitude: longitude,
        // userId: userId,
      );

      // FIX 3: Access categories through .data.categories
      final categories = response.data?.categories ?? [];

      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Search products by query
  Future<List<Product>> searchProducts({
    required String query,
    required String pincode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await PopularProductsService.searchProducts(
        pincode: pincode,
        query: query,
        page: page,
        limit: limit,
      );

      // Access products through .data.products
      final products = response.data.products ?? [];

      return products;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
  // Future<List<Category>> getBrowseGroups({
  //   required String pincode,
  //   required double latitude,
  //   required double longitude,
  //   required String userId,
  // }) async {
  //   try {
  //     debugPrint('🔍 Fetching categories for pincode: $pincode');
      
  //     // Call your existing categories API
  //     final response = await CategoryService.fetchCategories(
  //       pincode: pincode,
  //       latitude: latitude,
  //       longitude: longitude,
  //       userId: userId,
  //     );
      
  //     // Extract categories list from response
  //     final categories = response.categories ?? [];
      
  //     debugPrint('✅ Fetched ${categories.length} categories');
  //     return categories;
  //   } catch (e) {
  //     debugPrint('❌ Error fetching categories: $e');
  //     throw Exception('Failed to fetch categories: $e');
  //   }
  // }
  
  /// Search products by query
  /// TODO: Replace with your actual search API endpoint
  /// 

//   Future<List<Product>> searchProducts({
//     required String query,
//     required String pincode,
//   }) async {
//     try {
//       debugPrint('🔍 Searching for: $query in pincode: $pincode');
      
//       // TODO: Replace this with your actual search API call
//       // Example:
//       // final response = await dio.get(
//       //   '/api/v1/search/products',
//       //   queryParameters: {
//       //     'q': query,
//       //     'pincode': pincode,

//       //   },
//       // );
//       // return (response.data['data'] as List)
//       //     .map((p) => Product.fromJson(p))
//       //     .toList();
      
//       // For now, using popular products as search results
//       // This is a temporary solution - replace with actual search API
//       final response = await PopularProductsService.fetchPopularProducts(
//         pincode: pincode,
//         limit: 50,
//       );
      
//       final products = response.products ?? [];
      
//       // Filter products by query (client-side filtering as temporary solution)
//       final filteredProducts = products.where((product) {
//         return product.name.toLowerCase().contains(query.toLowerCase());
//       }).toList();
      
//       debugPrint('✅ Found ${filteredProducts.length} products matching "$query"');
//       return filteredProducts;
//     } catch (e) {
//       debugPrint('❌ Error searching products: $e');
//       throw Exception('Failed to search products: $e');
//     }
//   }
// }

// // lib/features/search/data/search_repository.dart
// import 'package:villag_kart/features/home/model/popular_product_model.dart';
// import '../../home/bloc/category_bloc/category_service.dart';
// import '../../home/bloc/popular_products_bloc/products_service.dart';
// import '../../home/model/category_model.dart';

// class SearchRepository {
//   final PopularProductsService _popularProductsRepo;
//   final CategoryService _categoryRepo;
  
//   SearchRepository({
//     required PopularProductsService popularProductsRepo,
//     required CategoryService categoryRepo,
//   })  : _popularProductsRepo = popularProductsRepo,
//         _categoryRepo = categoryRepo;
  
//   /// Fetch top moving products (reusing popular products API)
//   /// This uses your existing PopularProductsRepository
//   Future<List<PopularProductsResponse>> getTopMovingProducts({
//     required String pincode,
//     int limit = 10,
//   }) async {
//     try {
//       debugPrint('🔍 Fetching top moving products for pincode: $pincode');
      
//       // Call your existing popular products API
//       final products = await await PopularProductsService.fetchPopularProducts(
//         pincode: pincode,
//         limit: limit,
//       );
      
//       debugPrint('✅ Fetched ${products.length} top moving products');
//       return products;
//     } catch (e) {
//       debugPrint('❌ Error fetching top moving products: $e');
//       throw Exception('Failed to fetch top moving products: $e');
//     }
//   }
  
//   /// Fetch browse groups/categories
//   /// This uses your existing CategoryRepository
//   Future<List<Category>> getBrowseGroups({
//     required String pincode,
//     required double latitude,
//     required double longitude,
//     required String userId,
//   }) async {
//     try {
//       debugPrint('🔍 Fetching categories for pincode: $pincode');
      
//       // Call your existing categories API
//       final categories = await CategoryService.fetchCategories(
//         pincode: pincode,
//         latitude: latitude,
//         longitude: longitude,
//         userId: userId,
//       );
      
//       debugPrint('✅ Fetched ${categories.length} categories');
//       return categories;
//     } catch (e) {
//       debugPrint('❌ Error fetching categories: $e');
//       throw Exception('Failed to fetch categories: $e');
//     }
//   }
  
//   /// Search products by query
//   /// TODO: Replace with your actual search API endpoint
  
//   // Future<List<Product>> searchProducts({
//   //   required String query,
//   //   required String pincode,
//   // }) async {
//   //   try {
//   //     debugPrint('🔍 Searching for: $query in pincode: $pincode');
      
//   //     // TODO: Replace this with your actual search API call
//   //     // Example:
//   //     // final response = await dio.get(
//   //     //   '/api/v1/search/products',
//   //     //   queryParameters: {
//   //     //     'q': query,
//   //     //     'pincode': pincode,
//   //     //   },
//   //     // );
//   //     // return (response.data['data'] as List)
//   //     //     .map((p) => Product.fromJson(p))
//   //     //     .toList();
      
//   //     // For now, using popular products as search results
//   //     // This is a temporary solution - replace with actual search API
//   //     final products = await _popularProductsRepo.fetchPopularProducts(
//   //       pincode: pincode,
//   //       limit: 20,
//   //     );
      
//   //     // Filter products by query (client-side filtering as temporary solution)
//   //     final filteredProducts = products.where((product) {
//   //       return product.name.toLowerCase().contains(query.toLowerCase());
//   //     }).toList();
      
//   //     debugPrint('✅ Found ${filteredProducts.length} products matching "$query"');
//   //     return filteredProducts;
//   //   } catch (e) {
//   //     debugPrint('❌ Error searching products: $e');
//   //     throw Exception('Failed to search products: $e');
//   //   }
//   // }


// }
