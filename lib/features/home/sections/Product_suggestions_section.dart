import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestion_model.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_bloc.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_event.dart';
import 'package:villag_kart/features/home/bloc/suggestions/Product_suggestions_state.dart';
import 'package:villag_kart/features/home/sections/section_header.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';
import 'package:villag_kart/features/search/view/pages/product_detail_page.dart';
import 'package:villag_kart/features/search/view/widgets/product_card.dart';

class ProductSuggestionsSection extends StatefulWidget {
  final String title;
  final String? query; // null = cart mode (home), set = product mode (detail)

  const ProductSuggestionsSection({
    super.key,
    this.title = 'Although brought together',
    this.query,
  });

  @override
  State<ProductSuggestionsSection> createState() => _ProductSuggestionsSectionState();
}

class _ProductSuggestionsSectionState extends State<ProductSuggestionsSection> {

  bool get _isProductMode =>
      widget.query != null && widget.query!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    final savedLocation = await LocationService.getSavedLocation();
    final pincode = savedLocation?['pincode'] as String? ?? '';

    if (pincode.isEmpty || !mounted) return;

    if (_isProductMode) {
      // product detail page — use product name as query
      context.read<SuggestionsBloc>().add(
        FetchSuggestions(
          pincode: pincode,
          query: widget.query!.split(' ').first,
        ),
      );
    } else {
      // home page — bloc fetches cart internally
      context.read<SuggestionsBloc>().add(
        FetchSuggestionsFromCart(pincode: pincode),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<SuggestionsBloc, SuggestionsState>(
      builder: (context, state) {
        if (state is SuggestionsEmpty) return const SizedBox.shrink();

        if (state is SuggestionsInitial || state is SuggestionsLoading) {
          return _buildLoadingState();
        }

        if (state is SuggestionsError) {
          return _buildErrorState(state.errorMessage);
        }

        if (state is SuggestionsLoaded) {
          final inStock = state.suggestions
              .where((s) => s.stock > 0)
              .toList();

          if (inStock.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              const SizedBox(height: 8),
              _buildSuggestionsList(inStock, state.warehouseId),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );

    // CartBlocListener only needed on home page
    if (_isProductMode) return content;

    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          current is CartLoadedState &&
          current.cartItems.length >
              (previous is CartLoadedState ? previous.cartItems.length : 0),
      listener: (context, state) => _fetchSuggestions(),
      child: content,
    );
  }

  Widget _buildSuggestionsList(
    List<SuggestionProduct> suggestions,
    String warehouseId,
  ) {
    return SizedBox(
      height: 210.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = suggestions[index].toProduct();
          return SizedBox(
            width: 130,
            child: ProductCard(
              product: product,
              warehouseId: warehouseId,
              onTap: () => _navigateToDetail(context, suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(
  BuildContext context,
  SuggestionProduct suggestion,
) {
  final pincode = context.read<HomeBloc>().state.pincode ?? '';

  context.pushNamed(
    'proddetail',
    extra: {
      'prod': suggestion.toProduct(),
      'pincode': pincode,
    },
  );
}

  Widget _buildLoadingState() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 60, height: 12, color: Colors.grey.shade200),
                const SizedBox(height: 4),
                Container(width: 40, height: 10, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 30, height: 12, color: Colors.grey.shade200),
                    const Spacer(),
                    Container(width: 25, height: 10, color: Colors.grey.shade200),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 8),
            Text(
              'Failed to load products',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}