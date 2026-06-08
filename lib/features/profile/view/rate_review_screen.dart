import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:intl/intl.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import '../bloc/rate_review/rate_review_bloc.dart';
import '../bloc/rate_review/rate_review_event.dart';
import '../bloc/rate_review/rate_review_state.dart';
import '../model/rate_review_model.dart';

class RateAndReviewScreen extends StatefulWidget {
  final String productId;
  final String orderNumber;

  const RateAndReviewScreen({
    Key? key,
    required this.productId,
    required this.orderNumber,
  }) : super(key: key);

  @override
  State<RateAndReviewScreen> createState() => _RateAndReviewScreenState();
}

class _RateAndReviewScreenState extends State<RateAndReviewScreen> {
  double _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final FocusNode _reviewFocus = FocusNode();
  final FocusNode _deliveryFocus = FocusNode();
  bool _hasExistingReview = false;

  final List<bool> maskSelection = [false, false];
  final List<bool> uniformSelection = [false, false];
  final List<bool> contactSelection = [false, false];

  @override
  void initState() {
    super.initState();
    // Fetch existing ratings
    context.read<RatingBloc>().add(
      FetchProductRatings(productId: widget.productId),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _deliveryController.dispose();
    _reviewFocus.dispose();
    _deliveryFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _reviewFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }
          ],
        ),
        KeyboardActionsItem(
          focusNode: _deliveryFocus,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  void _submitReview() {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<RatingBloc>().add(
      SubmitProductRating(
        status: 'approved',
        productId: widget.productId,
        rating: _userRating,
        review: _reviewController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(context),
        ),
        title: const Text(
          'Rate and review',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFDBDBDB)),
        ),
        centerTitle: false,
      ),
      body: BlocListener<RatingBloc, RatingState>(
        listener: (context, state) {
          if (state is RatingSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _reviewController.clear();
            _userRating = 0;
          } else if (state is RatingSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<RatingBloc, RatingState>(
          builder: (context, state) {
            return KeyboardActions(
              config: _buildConfig(context),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID ${widget.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy,HH:mm').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'Rate your Order',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Align(
                          child: Container(
                            height: 2,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF5A06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 27),
                        _buildRatingStars(
                          currentRating: _userRating,
                          onRatingChanged: (ratings) {
                            setState(() => _userRating = ratings);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Good',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),

                        const SizedBox(height: 17),

                        Container(
                          height: 189,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 0.3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 6,
                                color: Color(0x3CE3E3E3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tell us your suggestions..',
                                  style: TextStyle(
                                    fontFamily: 'Seoge UI',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                SizedBox(
                                  height: 101,
                                  width: double.infinity,
                                  child: TextField(
                                    controller: _reviewController,
                                    focusNode: _reviewFocus,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: 'Tell us your suggestions..',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 12,

                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 9),
                                const Text(
                                  'your word make VillagKart a better place, you are the influence',
                                  style: TextStyle(
                                    fontFamily: 'Seoge UI',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'Delivery experience',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Align(
                          child: Container(
                            height: 2,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF5A06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 27),
                        _buildRatingStars(
                          currentRating: _userRating,
                          onRatingChanged: (ratings) {
                            setState(() => _userRating = ratings);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Average',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),

                        const SizedBox(height: 17),

                        Container(
                          height: 189,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 0.3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 6,
                                color: Color(0x3CE3E3E3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tell us your suggestions..',
                                  style: TextStyle(
                                    fontFamily: 'Seoge UI',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                SizedBox(
                                  height: 101,
                                  width: double.infinity,
                                  child: TextField(
                                    controller: _deliveryController,
                                    focusNode: _deliveryFocus,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: 'Tell us your suggestions..',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 12,

                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 9),
                                const Text(
                                  'your word make VillagKart a better place, you are the influence',
                                  style: TextStyle(
                                    fontFamily: 'Seoge UI',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 131,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                        width: 0.3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 6,
                          color: Color(0x3CE3E3E3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuestion(
                            question:
                                "Was the delivery partner wearing a mask?",
                            selection: maskSelection,
                          ),

                          _buildQuestion(
                            question:
                                "Was the delivery partner wearing a VillaKart uniform?",
                            selection: uniformSelection,
                          ),
                          _buildQuestion(
                            question: "Was the delivery No-Contact?",
                            selection: contactSelection,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  PrimaryButton(
                     onPressed: _submitReview,
                     label: 'your feedback',
                  )
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildRatingStars({
    required double currentRating,
    required Function(double) onRatingChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged((index + 1).toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              _userRating >= (index + 1) ? Icons.star : Icons.star_border,
              color: _userRating >= (index + 1)
                  ? Color(0xFFEF5A06)
                  : Color(0xFF5F5868),
              size: 32,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExistingReviews(List<ProductRating> ratings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Existing Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...ratings.map(
          (rating) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < rating.rating.toInt()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rating.rating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rating.review,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQuestion({
    required String question,
    required List<bool> selection,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Seoge UI',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        ToggleButtons(
          selectedColor: Colors.white,
          fillColor: Colors.green,
          borderRadius: BorderRadius.circular(8),
          borderColor: const Color(0xFFA5A5A5),
          constraints: const BoxConstraints(minHeight: 18, minWidth: 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          children: const [
            Text(
              'Yes',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Seoge UI',
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'No',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Seoge UI',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          isSelected: selection,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < selection.length; i++) {
                selection[i] = i == index;
              }
            });
          },
        ),
      ],
    );
  }
}
