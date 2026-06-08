import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchHeader extends StatefulWidget {
  const SearchHeader({
    super.key,
    required this.onSearch,
    this.onClear,
    this.onCancel,
    this.initialValue,
  });
  final ValueChanged<String> onSearch;
  final VoidCallback? onClear;
  final String? initialValue;
  final VoidCallback? onCancel;

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    _showClearButton = _searchController.text.isNotEmpty;
    _searchController.addListener(_onTextChanged);

    // Auto focus when screen opens
    Future.delayed(Duration.zero, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(SearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _searchController.text = widget.initialValue ?? '';
    }
  }

  void _onTextChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    // Debounce to reduce API calls
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      // Only clear when EMPTY
      if (query.isEmpty) {
        widget.onClear?.call();
      }
      // Only search when meaningful
      else if (query.length >= 3) {
        widget.onSearch(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Search products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  widget.onCancel?.call();
                }
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 19),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,

            // Manual search button on keyboard
            onSubmitted: (value) {
              final query = value.trim();
              if (query.length >= 3) {
                widget.onSearch(query);
              }
            },

            decoration: InputDecoration(
              hintText: 'Search for vegetables, groceries...',
              hintStyle: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF292D32),
                size: 28,
              ),

              suffixIcon: _showClearButton
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        widget.onClear?.call();
                        _focusNode.requestFocus(); // keep keyboard open
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
