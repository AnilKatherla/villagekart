import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class SearchViewController extends Cubit<void> {
  SearchViewController({
    required this.initialCategories,
    required this.initialProducts,
  }) : super(null) {
    categories = List.from(initialCategories);
    products = List.from(initialProducts);
    filteredProducts = List.from(products);
    selectedCategory = null; // ✅ Default to All (null means show all)
  }

  final List<CategoryModel> initialCategories;
  final List<Product> initialProducts;

  late final List<CategoryModel> categories;
  late List<Product> products;
  late List<Product> filteredProducts;

  String searchQuery = '';
  String? selectedCategory; // "All" means show everything

  /// ✅ Update search text and re-filter products
  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    _applyFilters();
  }

  /// ✅ Select category, but never empty products when “All”
  void selectCategory(String? categoryName) {
    if (categoryName == null || categoryName == 'All') {
      selectedCategory = null; // show all
    } else {
      // Match either by category name or id
      if (categories.isEmpty) {
        selectedCategory = null; // fallback to show all if no categories
      } else {
        final category = categories.firstWhere(
          (c) => c.id == categoryName || c.name == categoryName,
          orElse: () => categories.first,
        );
        selectedCategory = category.id;
      }
    }
    _applyFilters();
  }

  /// ✅ Toggle favorite
  void toggleFavorite(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updated = products[index].copyWith(
        isFavorite: !products[index].isFavorite,
      );
      products[index] = updated;
      _applyFilters();
    }
  }

  /// ✅ Increment cart count
  void incrementCart(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = products[index];
      final updated = product.copyWith(cartCount: (product.cartCount ?? 0) + 1);
      products[index] = updated;
      _applyFilters(); // ensures filtered list updates + UI rebuild
    } else {}
  }

  /// ✅ Decrement cart count
  void decrementCart(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = products[index];
      final currentCount = product.cartCount ?? 0;
      if (currentCount > 0) {
        final updated = product.copyWith(cartCount: currentCount - 1);
        products[index] = updated;
        _applyFilters();
      }
    }
  }

  /// ✅ Centralized filtering logic
  void _applyFilters() {
    filteredProducts = products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesCategory =
          selectedCategory == null || p.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    emit(null); // rebuild all dependent widgets
  }

  /// ✅ Helper: Get all items currently in cart
  List<Product> get cartProducts =>
      products.where((p) => (p.cartCount ?? 0) > 0).toList();

  /// ✅ Optional: Get total cart quantity
  int get totalCartCount =>
      products.fold<int>(0, (sum, p) => sum + (p.cartCount ?? 0));

  /// ✅ Optional: Get total cart value
  double get totalCartValue => products.fold<double>(
    0,
    (sum, p) => sum + (p.price * (p.cartCount ?? 0)),
  );
}
