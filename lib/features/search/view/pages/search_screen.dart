// lib/features/search/view/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_service.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/products_service.dart';

import '../../bloc/search_bloc.dart';
import '../../bloc/search_event.dart';
import '../../bloc/search_service.dart';
import '../../bloc/search_state.dart';
import '../../bloc/search_storage.dart';
import '../widgets/browse_group_wise.dart';
import '../widgets/recent_searches.dart';
import '../widgets/search_header.dart';
import '../widgets/top_moving_section.dart';
import 'search_result.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.onCancel});
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        localStorage: SearchLocalStorage(),
        repository: SearchRepository(
          popularProductsService: PopularProductsService(),
          categoryService: CategoryService(),
        ),
      )
        ..add(FetchRecentSearches())
        ..add(FetchTopMovingProducts())
        ..add(FetchBrowseGroups()),
      child: SearchScreenView(onCancel: onCancel), 
    );
  }
}

class SearchScreenView extends StatefulWidget { // 👈 change to StatefulWidget
  const SearchScreenView({super.key, this.onCancel});
  final VoidCallback? onCancel;

  @override
  State<SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<SearchScreenView> {
  String? _searchText; 
  
@override
  void initState() {
    super.initState();
    _searchText=null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            //  NEVER REBUILDS → keyboard safe
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchHeader(
                initialValue: _searchText, 
                onSearch: (query) {
                  if (query.trim().isNotEmpty) {
                    context.read<SearchBloc>().add(SearchProducts(query));
                  }
                },
                onClear: () {
                  context.read<SearchBloc>().add(ClearSearchResults());
                },
                 onCancel: widget.onCancel,
              ),
            ),

            //  ONLY THIS PART REBUILDS
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  // SEARCH RESULTS
                  if (state is SearchResultsState) {
                    if (state.isLoading) {
                      return _buildLoadingShimmer();
                    }

                    if (state.results.isEmpty) {
                      return _buildEmptyResults(state.query);
                    }

                    return SearchResultsList(products: state.results,query: state.query,);
                  }

                  // MAIN SEARCH HOME
                  return _buildMainSearchContent(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HOME CONTENT ----------
  Widget _buildMainSearchContent(BuildContext context, SearchState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16 ,vertical:1 ),
      children: [
        // Recent Searches
        if (state is SearchLoaded && state.recentSearches.isNotEmpty)...[
        
          RecentSearches(
            searches: state.recentSearches,
            onSearchTap: (query) {
              setState(() => _searchText = query);
              context.read<SearchBloc>().add(SearchProducts(query));
            },
            onClear: () {
              context.read<SearchBloc>().add(ClearRecentSearches());
            },
          ),
          const SizedBox(height: 17),
        ],

        // Top Moving
        if (state is SearchLoaded)
          TopMovingSection(products: state.topMovingProducts)
        else
          const TopMovingSection(products: []),

        const SizedBox(height: 20),

        // Browse Groups
        if (state is SearchLoaded)
          BrowseGroupWise(categories: state.browseGroups)
        else
          const BrowseGroupWise(categories: []),
      ],
    );
  }

  // ---------- LOADING ----------
  Widget _buildLoadingShimmer() {
   
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 12,
      childAspectRatio: 0.80,
    ),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Offer Tag
              Container(
                height: 10,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 8),

              /// Product Image
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 10),

              /// Product Name
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 6),

              /// Weight
              Container(
                height: 8,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 8),

              /// Price Row
              Row(
                children: [
                  Container(
                    height: 10,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 10,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
  

  Widget _shimmerLine(double width) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ---------- EMPTY ----------
  Widget _buildEmptyResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
