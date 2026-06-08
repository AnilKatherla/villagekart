import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:villag_kart/core/theme/colors.dart';
import 'package:villag_kart/features/location/bloc/location_bloc.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';

class LocationSearchBar extends StatefulWidget {
  const LocationSearchBar({super.key});

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize controllers in initState so they survive widget rebuilds
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // for suffix icon

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        context.read<LocationBloc>().add(SearchPlacesEvent(value.trim()));
      }
      // Don't call ClearSearchEvent - causes parent rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔍 Search Bar (NEVER in BlocBuilder - always persistent)
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search location',
              hintStyle: const TextStyle(
                color: Color(0xFF000000),
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Segoe UI',
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.black,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _debounce?.cancel();
                        setState(() {
                          _searchController.clear();
                        });
                        context.read<LocationBloc>().add(ClearSearchEvent());
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // 📍 Search Results (Only this rebuilds)
        BlocBuilder<LocationBloc, LocationState>(
          buildWhen: (p, c) => c is SearchResultsState,
          builder: (context, state) {
            final bool showResults = state is SearchResultsState;
            final predictions = showResults
                ? state.predictions
                : <PlacePrediction>[];

            if (!showResults || predictions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: predictions.length > 5 ? 5 : predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.green,
                      size: 20,
                    ),
                    title: Text(
                      prediction.mainText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      prediction.secondaryText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _debounce?.cancel();
                      _searchController.text = prediction.description;
                      _focusNode.unfocus();

                      context.read<LocationBloc>().add(
                        SelectPlaceEvent(
                          placeId: prediction.placeId,
                          description: prediction.description,
                        ),
                      );

                      context.read<LocationBloc>().add(ClearSearchEvent());
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
