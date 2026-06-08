import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/theme/colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import 'package:villag_kart/features/cart/bloc/cart_bloc.dart';
import 'package:villag_kart/features/cart/bloc/cart_state.dart';
import 'package:villag_kart/features/cart/view/review_items_page.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_bloc.dart';
import 'package:villag_kart/features/home/bloc/category_bloc/category_state.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/search/view/pages/search_product_rail.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, this.onStartShopping});

  final VoidCallback? onStartShopping;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.totalItems > 0) {
          return ReviewItemsPage(
            onBack: () => context.goNamed(
              'home',
              extra: {'address': 'Current Location', 'tabIndex': 0},
            ),
          );
        }

        // Otherwise show Empty Basket state
        return Scaffold(
          appBar: AppBar(
            title: const Text('Review Basket'),
            centerTitle: true,
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// --- IMAGE ---
                          SizedBox(
                            height: 240,
                            child: Image.asset(
                              'assets/images/empty-basket.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 32),

                          /// --- TITLE ---
                          Text(
                            'Your basket empty',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          /// --- SUBTITLE ---
                          Text(
                            'Explore our ever-going selection of products and exciting new offers today',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          /// --- CTA BUTTON ---
                           PrimaryButton(
                 onPressed: () {
                  final homeState = context.read<HomeBloc>().state;
                  final pincode = homeState.pincode!;

                  final categoryState = context.read<CategoryBloc>().state;
                  final List<CategoryModel> allCategories = [
                    if (categoryState is CategoryLoaded)
                      ...categoryState.categories,
                  ];

                  if (allCategories.isNotEmpty) {
                    final firstCategory = allCategories.first;
                    context.pushNamed(
                      'searchrail',
                      extra: {
                        'categoryId': firstCategory.id,
                        'categoryName': firstCategory.name,
                        'pincode': pincode,
                        'allCategories': allCategories,
                      },
                    );
                  } else {
                    debugPrint('Categories not loaded yet');
                  }
                },
                label:'Start Shopping'
              ),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
