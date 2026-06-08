import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:villag_kart/core/widgets/custom_appbar/custom_app_bar.dart';
import 'package:villag_kart/features/cart/view/view_cart_bar.dart';
import 'package:villag_kart/features/home/bloc/product_bloc/product_bloc.dart';
import 'package:villag_kart/features/home/bloc/subcategory_bloc/subcategory_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';
import 'package:villag_kart/features/search/view/pages/search_screen.dart';
import '../../controller/search_controller.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/product_grid.dart';

// Updated SearchProductRail with BLoC
class SearchProductRail extends StatelessWidget {
  // Categories for sidebar

  const SearchProductRail({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.pincode,
    required this.allCategories,
  });
  final String categoryId;
  final String categoryName;
  final String pincode;
  final List<CategoryModel> allCategories;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc()
            ..add(
              FetchProductsByCategory(categoryId: categoryId, pincode: pincode),
            ),
        ),
        // Add SubCategoryBloc for filters
        BlocProvider(
          create: (_) => SubCategoryBloc()
            ..add(FetchSubCategories(categoryId: categoryId, pincode: pincode)),
        ),
        // Add SearchViewController provider with categories data
        BlocProvider(
          create: (_) => SearchViewController(
            initialCategories: allCategories, // Categories for sidebar
            initialProducts: [],
          ),
         ),
      ],
      child: _SearchPageView(
        categoryId: categoryId,
        categoryName: categoryName,
        pincode: pincode,
        allCategories: allCategories, // Categories for sidebar
      ),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  // Add this

  const _SearchPageView({
    required this.categoryId,
    required this.categoryName,
    required this.pincode,
    required this.allCategories, // Add this
  });
  final String categoryId;
  final String categoryName;
  final String pincode;
  final List<CategoryModel> allCategories;

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  String _selectedFilter = 'All';
  String? _selectedCategoryId;
  String _selectedCategoryName = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedCategoryName = widget.categoryName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<SearchViewController>();
      controller.selectCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _selectedCategoryName,
        showBackButton: true,
        onSearchTap: () {
          context.push('/search');
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildFilterChips(), // This will use subcategories
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 82,
                          child: CategorySidebar(
                            categories: widget.allCategories, // Categories API
                            pincode: widget.pincode,
                            selectedCategoryId: _selectedCategoryId,
                            onCategorySelected: _onCategorySelected,
                          ),
                        ),
                        // const SizedBox(width: ),
                        Expanded(
                          child: _ProductGridWithBloc(
                            onProductTap: (p) {
                              context.pushNamed(
                                'proddetail',
                                extra: {'prod': p, 'pincode': widget.pincode},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ViewCartBar(),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategorySelected(String categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedFilter = 'All';
      _selectedCategoryName = categoryName;
    });

    final productBloc = context.read<ProductBloc>();
    final subCategoryBloc = context.read<SubCategoryBloc>();
    final controller = context.read<SearchViewController>();

    // Fetch products for the new category
    productBloc.add(
      FetchProductsByCategory(categoryId: categoryId, pincode: widget.pincode),
    );

    // Fetch subcategories for the new category (for filters)
    subCategoryBloc.add(
      FetchSubCategories(categoryId: categoryId, pincode: widget.pincode),
    );

    controller.selectCategory(categoryId);
  }

  Widget _buildFilterChips() {
    return BlocBuilder<SubCategoryBloc, SubCategoryState>(
      builder: (context, state) {
        List<String> filters = ['All'];

        if (state is SubCategoryLoaded && state.subcategories.isNotEmpty) {
          // Use subcategories for filters
          filters = ['All', ...state.subcategories.map((e) => e.name ?? '')];
        } else if (state is SubCategoryLoading) {
          return _FilterChipsShimmer(context);
        } else if (state is SubCategoryError) {
          // Fallback to categories if subcategories fail
          if (widget.allCategories.isNotEmpty) {
            filters = ['All', ...widget.allCategories.map((e) => e.name ?? '')];
          }
        }

        return SizedBox(
          height: 40,
          child: FilterChipsRow(
            filters: filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
              _handleFilterSelection(context, filter, state);
            },
          ),
        );
      },
    );
  }

  void _handleFilterSelection(
    BuildContext context,
    String filter,
    SubCategoryState subCategoryState,
  ) {
    final productBloc = context.read<ProductBloc>();
    final controller = context.read<SearchViewController>();

    if (filter == 'All') {
      // Fetch all products for the current category
      productBloc.add(
        FetchProductsByCategory(
          categoryId: _selectedCategoryId ?? widget.categoryId,
          pincode: widget.pincode,
        ),
      );
      controller.selectCategory(_selectedCategoryId);
      setState(() {
        // Keep the current category selected in sidebar
      });
    } else {
      // Handle subcategory filter
      if (subCategoryState is SubCategoryLoaded) {
        final subCategory = subCategoryState.subcategories.firstWhere(
          (subcat) => subcat.name == filter,
          orElse: () => SubCategory(id: '', name: ''),
        );

        if (subCategory.id?.isNotEmpty ?? false) {
          // Fetch products by subcategory
          productBloc.add(
            FetchProductsBySubCategory(
              subCategoryId: subCategory.id ?? '',
              pincode: widget.pincode,
            ),
          );
          // Don't change sidebar selection for subcategory filters
          // Keep the current category highlighted
        }
      } else {
        // Fallback: try to find in categories
        final category = widget.allCategories.firstWhere(
          (cat) => cat.name == filter,
          orElse: () =>
              CategoryModel(id: '', name: '', image: '', itemCount: 0),
        );

        if (category.id.isNotEmpty) {
          productBloc.add(
            FetchProductsByCategory(
              categoryId: category.id,
              pincode: widget.pincode,
            ),
          );
          setState(() {
            _selectedCategoryId = category.id;
          });
          controller.selectCategory(category.id);
        }
      }
    }
  }
}

class _ProductGridWithBloc extends StatelessWidget {
  // Change to Product

  const _ProductGridWithBloc({this.onProductTap});
  final void Function(Product)? onProductTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return _ProductGridShimmer(context);
        }

        if (state is ProductError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }

        if (state is ProductLoaded) {
          // Convert Product to Product for the grid

          final warehouseId = state.warehouse.id;

          return ProductGrid(
            products: state.products,
            onProductTap: (prod) {
              // Pass the Product directly
              onProductTap?.call(prod);
            },
            warehouseId: warehouseId,
          );
        }

        return const Center(child: Text('No products found'));
      },
    );
  }
}

Widget _ProductGridShimmer(BuildContext context) {
  final productlength = context.read<ProductBloc>().state;

  return GridView.builder(
    itemCount: 6,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.65,
    ),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Container(
              height: 168,

              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      );
    },
  );
}

Widget _FilterChipsShimmer(BuildContext context) {
  return SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 80,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    ),
  );
}
