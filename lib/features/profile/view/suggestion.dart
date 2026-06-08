import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:villag_kart/core/widgets/buttons/primary_button.dart';
import '../bloc/suggestion/suggestion_bloc.dart';
import '../bloc/suggestion/suggestion_event.dart';
import '../bloc/suggestion/suggestion_state.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final TextEditingController _suggestionController = TextEditingController();

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  // FIX: Accept a BuildContext that is UNDER the BlocProvider
  void _submitSuggestion(BuildContext blocContext) {
    if (_suggestionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a suggestion'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Use the context that actually has access to the SuggestionBloc
    blocContext.read<SuggestionBloc>().add(
      SubmitSuggestion(suggestion: _suggestionController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SuggestionBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(context),
          ),
          title: const Text(
            'I have a suggestion',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: false,
        ),
        // FIX: Wrap body in a Builder to get a context below BlocProvider
        body: Builder(
          builder: (builderContext) {
            return BlocListener<SuggestionBloc, SuggestionState>(
              listener: (context, state) {
                if (state is SuggestionSuccess) {
                  _suggestionController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  // FIX: Pop immediately using the listener's context
                  Navigator.of(context).pop();
                } else if (state is SuggestionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tell us your suggestions..',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _suggestionController,
                            maxLines: 8,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Tell us your suggestions..',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your word make VillagKart a better place. You are the influence.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: BlocBuilder<SuggestionBloc, SuggestionState>(
                      builder: (context, state) {
                        final isLoading = state is SuggestionLoading;

                        return PrimaryButton(
                          onPressed: isLoading
                              ? null
                              : () => _submitSuggestion(context),
                          label: 'Submit your Suggestion',
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
